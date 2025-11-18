import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class LoginUserUseCase{
  final AuthRepository _authRepository;

  LoginUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<UserCredential> call({required String email, required String password}) async {
    return await _authRepository.loginUser(email: email, password: password);
  }
}