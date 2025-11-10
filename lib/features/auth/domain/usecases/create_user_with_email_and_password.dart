import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class CreateUserWithEmailUseCase {
  final AuthRepository authRepository;

  CreateUserWithEmailUseCase({required this.authRepository});

  Future<UserCredential> call({
    required String email,
    required String password,
  }) async {
    return authRepository.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
