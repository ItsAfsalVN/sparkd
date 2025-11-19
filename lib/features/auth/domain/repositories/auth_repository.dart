import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();
  Future<String> requestOtp(String phoneNumber);
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<String?> getCurrentSignUpStep();
  Future<void> setCurrentSignUpStep(String step);
  Future<void> clearSignUpStep();
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> linkPhoneCredential({
    required String verificationID,
    required String smsCode,
    required String phoneNumber,
  });

  Future<void> saveUserProfile({required UserProfile profile});
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});
}
