import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class RequestOtpUseCase {
  final AuthRepository authRepository;
  RequestOtpUseCase({required this.authRepository});

Future<String> call(String phoneNumber) async {
  return await authRepository.requestOtp(phoneNumber);
}
}