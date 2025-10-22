import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';

class SignUpDataRepositoryImplementation implements SignUpDataRepository {
  SignUpData _signUpData = SignUpData.empty;

  @override
  void clearData() {
    _signUpData = SignUpData.empty;
  }

  @override
  SignUpData getData() {
    return _signUpData;
  }

  @override
  void updateData(SignUpData newData) {
    _signUpData = newData;
  }
}
