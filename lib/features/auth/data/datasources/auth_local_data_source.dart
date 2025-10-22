import 'package:shared_preferences/shared_preferences.dart';

const String IS_FIRST_RUN_KEY = 'isFirstRun';

abstract class AuthLocalDataSource {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();
}

class AuthLocalDataSourceImplementation implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImplementation({required this.sharedPreferences});

  @override
  Future<bool> getIsFirstRun() async {
    return sharedPreferences.getBool(IS_FIRST_RUN_KEY) ?? true;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await sharedPreferences.setBool(IS_FIRST_RUN_KEY, false);
  }
}
