abstract class SettingsRepository {
  Future<bool> isOnboardingCompleted();

  Stream<bool> watchOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool value);

  Future<String> getThemeMode();

  Future<void> setThemeMode(String mode);

  Future<bool> getNotificationsEnabled();

  Future<void> setNotificationsEnabled(bool value);
}
