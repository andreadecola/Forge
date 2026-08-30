import '../../domain/repositories/settings_repository.dart';
import '../database/daos/app_settings_dao.dart';
import '../../domain/entities/notification_settings.dart';

abstract final class SettingsKeys {
  static const onboardingCompleted = 'onboardingCompleted';
  static const themeMode = 'themeMode';
  static const notificationsEnabled = 'notificationsEnabled';
  static const plannedActivityRemindersEnabled =
      'plannedActivityRemindersEnabled';
  static const plannedActivityReminderTimeMinutes =
      'plannedActivityReminderTimeMinutes';
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dao);

  final AppSettingsDao _dao;

  @override
  Future<bool> isOnboardingCompleted() async {
    final value = await _dao.getValue(SettingsKeys.onboardingCompleted);
    return value == '1';
  }

  @override
  Stream<bool> watchOnboardingCompleted() {
    return _dao
        .watchValue(SettingsKeys.onboardingCompleted)
        .map((value) => value == '1');
  }

  @override
  Future<void> setOnboardingCompleted(bool value) {
    return _dao.setValue(SettingsKeys.onboardingCompleted, value ? '1' : '0');
  }

  @override
  Future<String> getThemeMode() async {
    return await _dao.getValue(SettingsKeys.themeMode) ?? 'dark';
  }

  @override
  Future<void> setThemeMode(String mode) {
    return _dao.setValue(SettingsKeys.themeMode, mode);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    final value = await _dao.getValue(SettingsKeys.notificationsEnabled);
    return value == '1';
  }

  @override
  Future<void> setNotificationsEnabled(bool value) {
    return _dao.setValue(SettingsKeys.notificationsEnabled, value ? '1' : '0');
  }

  @override
  Future<bool> getPlannedActivityRemindersEnabled() async {
    final value = await _dao.getValue(
      SettingsKeys.plannedActivityRemindersEnabled,
    );
    return value == '1';
  }

  @override
  Future<void> setPlannedActivityRemindersEnabled(bool value) async {
    if (value) {
      final time = await getPlannedActivityReminderTimeMinutes();
      if (!NotificationSettings.isValidReminderTimeMinutes(time)) {
        throw StateError(
          'Imposta un orario valido prima di attivare i promemoria.',
        );
      }
    }
    await _dao.setValue(
      SettingsKeys.plannedActivityRemindersEnabled,
      value ? '1' : '0',
    );
  }

  @override
  Future<int?> getPlannedActivityReminderTimeMinutes() async {
    final value = await _dao.getValue(
      SettingsKeys.plannedActivityReminderTimeMinutes,
    );
    if (value == null || value.isEmpty) return null;
    final parsed = int.tryParse(value);
    return NotificationSettings.isValidReminderTimeMinutes(parsed)
        ? parsed
        : null;
  }

  @override
  Future<void> setPlannedActivityReminderTimeMinutes(int? value) async {
    NotificationSettings.validateReminderTimeMinutes(value);
    if (value == null) {
      await _dao.deleteValue(SettingsKeys.plannedActivityReminderTimeMinutes);
      return;
    }
    await _dao.setValue(
      SettingsKeys.plannedActivityReminderTimeMinutes,
      value.toString(),
    );
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return NotificationSettings(
      notificationsEnabled: await getNotificationsEnabled(),
      plannedActivityRemindersEnabled:
          await getPlannedActivityRemindersEnabled(),
      plannedActivityReminderTimeMinutes:
          await getPlannedActivityReminderTimeMinutes(),
    );
  }
}
