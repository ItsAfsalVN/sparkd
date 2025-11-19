import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

 Future<void> call({required String email}) async {
  return await _authRepository.forgotPassword(email: email);
 }
}