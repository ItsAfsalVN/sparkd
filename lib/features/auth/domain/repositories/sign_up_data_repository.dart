import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';

abstract class SignUpDataRepository {

  // Update the central data for the user
  void updateData(SignUpData newData);

  // Get data from the central repository
  SignUpData getData();

  // Clear user data for after the submit
  void clearData();
}
