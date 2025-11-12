import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sparkd/features/auth/domain/entities/user_profile.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImplementation({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<bool> getIsFirstRun() async {
    return await localDataSource.getIsFirstRun();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    return await localDataSource.setOnboardingCompleted();
  }

  @override
  Future<String> requestOtp(String phoneNumber) async {
    try {
      return await remoteDataSource.requestOtp(phoneNumber);
    } catch (error) {
      logger.e("AuthRepositoryImplementation Error requesting OTP: $error");
      throw Exception('Failed to request OTP: $error');
    }
  }

  @override
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    return await remoteDataSource.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  Future<String?> getCurrentSignUpStep() async {
    return await localDataSource.getCurrentSignUpStep();
  }

  @override
  Future<void> setCurrentSignUpStep(String step) async {
    await localDataSource.setCurrentSignUpStep(step);
  }

  @override
  Future<void> clearSignUpStep() async {
    await localDataSource.clearSignUpStep();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      logger.e("AuthRepositoryImplementation Error creating user: $error");
      rethrow;
    }
  }

  @override
  Future<void> linkPhoneCredential({
    required String verificationID,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.linkPhoneCredential(
        verificationID: verificationID,
        smsCode: smsCode,
        phoneNumber: phoneNumber,
      );
    } catch (error) {
      logger.e("AuthRepositoryImplementation Error linking phone: $error");
      rethrow;
    }
  }

  @override
  Future<void> saveUserProfile({required UserProfile profile}) async {
    try {
      await remoteDataSource.saveUserProfile(profile);
    } catch (error) {
      logger.e(
        "AuthRepositoryImplementation Error saving user profile : $error",
      );
      rethrow;
    }
  }
}
