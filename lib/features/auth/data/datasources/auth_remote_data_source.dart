import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/logger.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String phoneNumber);
  Future<UserCredential> verifyOtp({
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
}

class AuthRemoteDataSourceImplementation extends AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImplementation({required this.firebaseAuth});

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
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      logger.i(
        "OTP Verified Successfully! User UID: ${userCredential.user?.uid}",
      );
      return userCredential;
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
    } on FirebaseAuthException catch (error) {
      throw Exception(
        'Error linking phone credential: ${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception('Error linking phone credential with auth: $error');
    }
  }
}
