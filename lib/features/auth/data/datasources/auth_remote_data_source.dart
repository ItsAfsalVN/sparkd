import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/entities/user_profile.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String phoneNumber);
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> linkPhoneCredential({
    required String verificationID,
    required String smsCode,
    required String phoneNumber,
  });
  Future<void> saveUserProfile(UserProfile profile);
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});
  Future<UserCredential> signInWithGoogle();
}

class AuthRemoteDataSourceImplementation extends AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRemoteDataSourceImplementation({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<String> requestOtp(String phoneNumber) async {
    final completer = Completer<String>();

    String formattedPhoneNumber = phoneNumber;
    if (!formattedPhoneNumber.startsWith('+')) {
      formattedPhoneNumber = "+91$formattedPhoneNumber";
    }

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) {
        logger.i('Otp verification successfull');
        completer.complete("AUTO_VERIFIED");
      },
      verificationFailed: (error) {
        logger.e('OTP Verification Failed: ${error.code} - ${error.message}');
        completer.completeError(
          'OTP Request Failed: ${error.message ?? error.code}',
        );
      },
      codeSent: (verificationId, forceResendingToken) {
        logger.i('OTP Code Sent. Verification ID: $verificationId');
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        logger.e(
          'OTP Code Auto Retrieval Timeout. Verification ID: $verificationId',
        );
      },
    );

    return completer.future;
  }

  @override
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential tempUserCredential = await firebaseAuth
          .signInWithCredential(credential);

      logger.i(
        "OTP Verified Successfully! Temp User UID: ${tempUserCredential.user?.uid}",
      );

      await tempUserCredential.user?.delete();
      logger.i(
        "AuthRemoteDataSource: Deleted temporary phone user after verification.",
      );

      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      logger.e(
        "OTP Verification Failed (FirebaseAuthException): ${e.code} - ${e.message}",
      );
      throw Exception('Verification Failed: ${e.message ?? e.code}');
    } catch (e) {
      logger.e("OTP Verification Failed (Unknown Error): $e");
      throw Exception('An unexpected error occurred during verification.');
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      logger.i(
        "Email/Password account created successfully! User UID: ${userCredential.user?.uid}",
      );
      return userCredential;
    } on FirebaseAuthException catch (error) {
      throw Exception(
        'Failed to create account: ${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception('Error creating user: $error');
    }
  }

  @override
  Future<void> linkPhoneCredential({
    required String verificationID,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationID,
        smsCode: smsCode,
      );

      if (firebaseAuth.currentUser == null) {
        throw Exception(
          "Cannot link credential: No user is currently signed in.",
        );
      }

      await firebaseAuth.currentUser!.linkWithCredential(credential);
      logger.i(
        "Phone credential linked successfully to user: ${firebaseAuth.currentUser!.uid}",
      );
    } on FirebaseAuthException catch (error) {
      logger.e(
        "Error linking phone credential: ${error.code} - ${error.message}",
      );
      throw Exception(
        'Error linking phone credential: ${error.message ?? error.code}',
      );
    } catch (error) {
      logger.e("Error linking phone credential: $error");
      throw Exception('Error linking phone credential with auth: $error');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toFirestore());
      logger.i("Firestore: User profile saved for UID: ${profile.uid}");
    } catch (e) {
      logger.e("Firestore: Failed to save user profile.", error: e);
      throw Exception('Database error: Failed to save profile.');
    }
  }

  @override
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      logger.i(
        "User logged in successfully! User UID: ${userCredential.user?.uid}",
      );
      return userCredential;
    } on FirebaseAuthException catch (error) {
      throw Exception('Failed to login: ${error.message ?? error.code}');
    } catch (error) {
      throw Exception('Error logging in user: $error');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) {
    try {
      return firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw Exception(
        'Failed to send password reset email: ${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception('Error sending password reset email: $error');
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      logger.i('Initiating Google Sign-In');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google Sign-In was canceled by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      logger.i(
        'Google Sign-In successful for user: ${userCredential.user?.email}',
      );

      return userCredential;
    } on FirebaseAuthException catch (error) {
      logger.e('Firebase Auth error during Google Sign-In: ${error.message}');
      throw Exception(
        'Failed to sign in with Google: ${error.message ?? error.code}',
      );
    } catch (error) {
      logger.e('Error during Google Sign-In: $error');
      throw Exception('Error signing in with Google: $error');
    }
  }
}
