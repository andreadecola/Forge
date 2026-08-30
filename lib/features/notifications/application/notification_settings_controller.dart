import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/notification_settings.dart';
import '../domain/notification_permission_status.dart';
import 'notification_providers.dart';

class NotificationSettingsController {
  const NotificationSettingsController(this._ref);

  final Ref _ref;

  Future<NotificationSettings> load() {
    return _ref.read(settingsRepositoryProvider).getNotificationSettings();
  }

  Future<void> setMasterEnabled(bool value) {
    return _ref.read(settingsRepositoryProvider).setNotificationsEnabled(value);
  }

  Future<void> setPlannedActivityRemindersEnabled(bool value) {
    return _ref
        .read(settingsRepositoryProvider)
        .setPlannedActivityRemindersEnabled(value);
  }

  Future<void> setReminderTimeMinutes(int? value) {
    return _ref
        .read(settingsRepositoryProvider)
        .setPlannedActivityReminderTimeMinutes(value);
  }

  Future<NotificationPermissionStatus> permissionStatus() {
    return _ref
        .read(notificationPermissionGatewayProvider)
        .getPermissionStatus();
  }

  Future<NotificationPermissionStatus> requestPermission() {
    return _ref.read(notificationPermissionGatewayProvider).requestPermission();
  }
}
