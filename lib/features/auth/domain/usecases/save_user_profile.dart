import 'package:sparkd/features/auth/domain/entities/user_profile.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';

class SaveUserProfileUseCase {
  final AuthRepository authRepository;

  SaveUserProfileUseCase({required this.authRepository});
  
  Future<void> call(UserProfile profile) async{
 return await authRepository.saveUserProfile(profile: profile);
  }
}