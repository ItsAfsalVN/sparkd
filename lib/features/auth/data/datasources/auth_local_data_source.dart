import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';

const String IS_FIRST_RUN_KEY = 'isFirstRun';
const String SIGN_UP_STEP_KEY = 'signUpStep';
const String STEP_AWAITING_PHONE = 'awaiting_phone';
const String STEP_COMPLETE = 'complete';
const String STEP_AWAITING_SKILLS = 'awaiting_skills';
const String STEP_AWAITING_BUSINESS = 'awaiting_business';
const String CACHED_USER_TYPE_KEY = 'cachedUserType';

abstract class AuthLocalDataSource {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();

  Future<String?> getCurrentSignUpStep();
  Future<void> setCurrentSignUpStep(String step);
  Future<void> clearSignUpStep();

  Future<UserType?> getCachedUserType();
  Future<void> setCachedUserType(UserType userType);
  Future<void> clearCachedUserType();
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
    await clearSignUpStep();
  }

  @override
  Future<String?> getCurrentSignUpStep() async {
    return sharedPreferences.getString(SIGN_UP_STEP_KEY);
  }

  @override
  Future<void> setCurrentSignUpStep(String step) async {
    await sharedPreferences.setString(SIGN_UP_STEP_KEY, step);
  }

  @override
  Future<void> clearSignUpStep() async {
    await sharedPreferences.remove(SIGN_UP_STEP_KEY);
  }

  @override
  Future<UserType?> getCachedUserType() async {
    final typeString = sharedPreferences.getString(CACHED_USER_TYPE_KEY);
    if (typeString == null) return null;
    try {
      return UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.$typeString',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setCachedUserType(UserType userType) async {
    await sharedPreferences.setString(
      CACHED_USER_TYPE_KEY,
      userType.toString().split('.').last,
    );
  }

  @override
  Future<void> clearCachedUserType() async {
    await sharedPreferences.remove(CACHED_USER_TYPE_KEY);
  }
}
