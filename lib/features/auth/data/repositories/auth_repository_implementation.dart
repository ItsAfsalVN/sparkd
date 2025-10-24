import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  AuthRepositoryImplementation({required this.localDataSource});

  @override
  Future<bool> getIsFirstRun() async {
    return await localDataSource.getIsFirstRun();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    return await localDataSource.setOnboardingCompleted();
  }
  
  @override
  Future<void> requestOtp() {
  }

}
