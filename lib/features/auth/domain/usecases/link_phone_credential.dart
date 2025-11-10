
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class LinkPhoneCredentialUseCase {
  final AuthRepository authRepository;

  LinkPhoneCredentialUseCase({required this.authRepository});

  Future<void> call({
    required String verificationID,
    required String smsCode,
    required String phoneNumber,
  }) {
    return authRepository.linkPhoneCredential(
      verificationID: verificationID,
      smsCode: smsCode,
      phoneNumber: phoneNumber,
    );
  }
}
