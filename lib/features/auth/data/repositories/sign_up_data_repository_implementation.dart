import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';

const String SIGN_UP_DATA_KEY = 'pendingSignUpData';

class SignUpDataRepositoryImplementation implements SignUpDataRepository {
  final FlutterSecureStorage flutterSecureStorage;
  SignUpData _cachedData = SignUpData.empty;

  SignUpDataRepositoryImplementation({required this.flutterSecureStorage}) {
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    try {
      final jsonString = await flutterSecureStorage.read(key: SIGN_UP_DATA_KEY);

      if (jsonString != null) {
        _cachedData = SignUpData.fromJson(jsonDecode(jsonString));
        logger.i(
          "SignUpDataRepository: Loaded data from secure prefs: $_cachedData",
        );
      } else {
        _cachedData = SignUpData.empty;
        logger.i("SignUpDataRepository: No data found in secure prefs.");
      }
    } catch (e) {
      logger.e(
        "SignUpDataRepository: Error decoding data from secure prefs: $e",
      );
      _cachedData = SignUpData.empty;
    }
  }

  Future<void> _saveDataToPrefs() async {
    try {
      final jsonString = jsonEncode(_cachedData.toJson());
      await flutterSecureStorage.write(
        key: SIGN_UP_DATA_KEY,
        value: jsonString,
      );
      logger.i("SignUpDataRepository: Saved data to secure prefs.");
    } catch (e) {
      logger.e("SignUpDataRepository: Error encoding data to secure prefs: $e");
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
    flutterSecureStorage.delete(key: SIGN_UP_DATA_KEY);
    logger.i("SignUpDataRepository: Data cleared from secure storage.");
  }
}
