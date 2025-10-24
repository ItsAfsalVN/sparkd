abstract class AuthRepository {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();
  Future<void> requestOtp();
}