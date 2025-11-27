import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  Future<UserCredential> call() async {
    return await repository.signInWithGoogle();
  }
}
