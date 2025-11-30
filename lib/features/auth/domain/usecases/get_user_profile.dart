import 'package:sparkd/features/auth/domain/entities/user_profile.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository authRepository;

  GetUserProfileUseCase({required this.authRepository});

  Future<UserProfile?> call(String uid) async {
    return await authRepository.getUserProfile(uid: uid);
  }
}
