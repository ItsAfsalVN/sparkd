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
      // Check if there's already a signed-in user (e.g., from Google Sign-In)
      final existingUser = firebaseAuth.currentUser;
      final wasAlreadySignedIn = existingUser != null;

      logger.i(
        "AuthRemoteDataSource: Verifying OTP. User already signed in: $wasAlreadySignedIn (UID: ${existingUser?.uid ?? 'null'})",
      );

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (wasAlreadySignedIn) {
        // User already signed in (Google Sign-In flow)
        // Link the phone credential directly to the existing user
        try {
          await existingUser.linkWithCredential(credential);
          logger.i(
            "AuthRemoteDataSource: Phone credential linked to existing user (UID: ${existingUser.uid})",
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            logger.i(
              "AuthRemoteDataSource: Phone number already linked to this user. Continuing...",
            );
            // This is fine, phone is already linked
          } else if (e.code == 'credential-already-in-use') {
            logger.w(
              "AuthRemoteDataSource: Phone number is already in use by another account.",
            );
            throw Exception(
              'This phone number is already associated with another account.',
            );
          } else {
            rethrow;
          }
        }
      } else {
        UserCredential tempUserCredential = await firebaseAuth
            .signInWithCredential(credential);

        logger.i(
          "OTP Verified Successfully! Temp User UID: ${tempUserCredential.user?.uid}",
        );

        // Delete the temp user and sign out
        await tempUserCredential.user?.delete();
        logger.i(
          "AuthRemoteDataSource: Deleted temporary phone user after verification.",
        );

        await firebaseAuth.signOut();
        logger.i(
          "AuthRemoteDataSource: Signed out after phone verification (email/password flow).",
        );
      }
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

      // Check if phone is already linked to this user
      final user = firebaseAuth.currentUser!;
      final isPhoneAlreadyLinked = user.providerData.any(
        (info) => info.providerId == 'phone',
      );

      if (isPhoneAlreadyLinked) {
        logger.i(
          "Phone credential already linked to user: ${user.uid}. Skipping link operation.",
        );
        return; // Phone already linked, no need to link again
      }

      await user.linkWithCredential(credential);
      logger.i("Phone credential linked successfully to user: ${user.uid}");
    } on FirebaseAuthException catch (error) {
      // Handle specific Firebase errors
      if (error.code == 'provider-already-linked') {
        logger.i("Phone credential already linked. Continuing...");
        return; // Not an error, phone is already linked
      } else if (error.code == 'credential-already-in-use') {
        logger.e(
          "Phone number is already used by another account: ${error.message}",
        );
        throw Exception(
          'This phone number is already associated with another account.',
        );
      }

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

      // Try to sign in to Firebase with the Google credential
      try {
        final userCredential = await firebaseAuth.signInWithCredential(
          credential,
        );

        logger.i(
          'Google Sign-In successful for user: ${userCredential.user?.email}',
        );

        return userCredential;
      } on FirebaseAuthException catch (credentialError) {
        // Handle account-exists-with-different-credential error
        if (credentialError.code ==
            'account-exists-with-different-credential') {
          logger.w(
            'Account exists with different credential. Attempting to link accounts.',
          );

          // Get the current user (if signed in)
          final currentUser = firebaseAuth.currentUser;

          if (currentUser == null) {
            // User is not signed in, they need to sign in with their password first
            throw Exception(
              'An account already exists with this email. Please sign in with your password first, then you can link your Google account.',
            );
          }

          try {
            // Link the Google credential to the existing account
            final linkedCredential = await currentUser.linkWithCredential(
              credential,
            );

            logger.i('Successfully linked Google account to existing account');

            return linkedCredential;
          } catch (linkError) {
            logger.e('Error linking accounts: $linkError');
            if (linkError is FirebaseAuthException) {
              if (linkError.code == 'provider-already-linked') {
                throw Exception(
                  'This Google account is already linked to your account.',
                );
              } else if (linkError.code == 'credential-already-in-use') {
                throw Exception(
                  'This Google account is already used by another user.',
                );
              }
            }
            throw Exception(
              'Unable to link accounts. Please sign in with your password first.',
            );
          }
        }

        // Re-throw other Firebase auth errors
        logger.e(
          'Firebase Auth error during Google Sign-In: ${credentialError.message}',
        );
        throw Exception(
          'Failed to sign in with Google: ${credentialError.message ?? credentialError.code}',
        );
      }
    } catch (error) {
      logger.e('Error during Google Sign-In: $error');
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Error signing in with Google: $error');
    }
  }
}
