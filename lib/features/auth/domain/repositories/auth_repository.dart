abstract class AuthRepository {
  Future<bool> getIsFirstRun();
  Future<void> setOnboardingCompleted();
}