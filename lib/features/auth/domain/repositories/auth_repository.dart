import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();
  Future<String> requestOtp(String phoneNumber);
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
}