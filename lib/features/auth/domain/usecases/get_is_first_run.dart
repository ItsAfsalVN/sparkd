import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class GetIsFirstRun {
  final AuthRepository authRepository;
  GetIsFirstRun(this.authRepository);

  Future<bool> call() async {
    return await authRepository.getIsFirstRun();
  }
}
