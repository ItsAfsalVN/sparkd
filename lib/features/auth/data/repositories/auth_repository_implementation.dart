import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/data/datasources/auth_remote_data_source.dart';
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
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      return await remoteDataSource.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
    } catch (e) {
      logger.e("AuthRepositoryImplementation Error verifying OTP: $e");
      throw Exception('Failed to verify OTP: $e');
    }
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
}
