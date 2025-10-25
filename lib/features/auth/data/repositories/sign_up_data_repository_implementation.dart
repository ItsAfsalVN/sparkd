import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';

const String SIGN_UP_DATA_KEY = 'pendingSignUpData';

class SignUpDataRepositoryImplementation implements SignUpDataRepository {
  final SharedPreferences sharedPreferences;
  SignUpData _cachedData = SignUpData.empty;

  SignUpDataRepositoryImplementation({required this.sharedPreferences}) {
    _loadDataFromPrefs();
  }

  void _loadDataFromPrefs() {
    final jsonString = sharedPreferences.getString(SIGN_UP_DATA_KEY);
    if (jsonString != null) {
      try {
        _cachedData = SignUpData.fromJson(jsonDecode(jsonString));
        logger.i("SignUpDataRepository: Loaded data from prefs: $_cachedData");
      } catch (e) {
        logger.e("SignUpDataRepository: Error decoding data from prefs: $e");
        _cachedData = SignUpData.empty;
      }
    } else {
      _cachedData = SignUpData.empty;
      logger.e("SignUpDataRepository: No data found in prefs.");
    }
  }

  Future<void> _saveDataToPrefs() async {
    try {
      final jsonString = jsonEncode(_cachedData.toJson());
      await sharedPreferences.setString(SIGN_UP_DATA_KEY, jsonString);
      logger.i("SignUpDataRepository: Saved data to prefs.");
    } catch (e) {
      logger.e("SignUpDataRepository: Error encoding data to prefs: $e");
    }
  }

  @override
  SignUpData getData() {
    return _cachedData;
  }

  @override
  void updateData(SignUpData newData) {
    _cachedData = newData;
    _saveDataToPrefs();
    logger.i("SignUpDataRepository: Cache updated: $_cachedData");
  }

  @override
  void clearData() {
    _cachedData = SignUpData.empty;
    sharedPreferences.remove(SIGN_UP_DATA_KEY);
    logger.i("SignUpDataRepository: Data cleared.");
  }
}
