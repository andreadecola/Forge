import '../entities/notification_settings.dart';

abstract class SettingsRepository {
  Future<bool> isOnboardingCompleted();

  Stream<bool> watchOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool value);

  Future<String> getThemeMode();

  Future<void> setThemeMode(String mode);

  Future<bool> getNotificationsEnabled();

  Future<void> setNotificationsEnabled(bool value);

  Future<bool> getPlannedActivityRemindersEnabled();

  Future<void> setPlannedActivityRemindersEnabled(bool value);

  Future<int?> getPlannedActivityReminderTimeMinutes();

  Future<void> setPlannedActivityReminderTimeMinutes(int? value);

  Future<NotificationSettings> getNotificationSettings();
}
