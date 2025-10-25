import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<UserCredential> call({
    required String verificationId,
    required String smsCode,
  }) async {
    return await repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
