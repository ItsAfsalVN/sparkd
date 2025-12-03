import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  final SignUpDataRepository signUpDataRepository;

  LogoutUseCase({
    required this.authRepository,
    required this.signUpDataRepository,
  });

  Future<void> call() async {
    await authRepository.logout();
    signUpDataRepository.clearData();
  }
}
