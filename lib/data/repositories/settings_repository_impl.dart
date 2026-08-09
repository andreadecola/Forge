import '../../domain/repositories/settings_repository.dart';
import '../database/daos/app_settings_dao.dart';

abstract final class SettingsKeys {
  static const onboardingCompleted = 'onboardingCompleted';
  static const themeMode = 'themeMode';
  static const notificationsEnabled = 'notificationsEnabled';
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
}
