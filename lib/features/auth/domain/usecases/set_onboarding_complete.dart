import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class SetOnboardingComplete {
  final AuthRepository authRepository;
  SetOnboardingComplete(this.authRepository);

  Future<void> call() async {
    await authRepository.setOnboardingCompleted();
  }
}