import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';

abstract class SignUpDataRepository {
  void updateData(SignUpData newData);

  SignUpData getData();

  void clearData();
}
