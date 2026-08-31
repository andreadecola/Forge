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

  Future<void> setMasterEnabled(bool value, {int? profileId}) async {
    await _ref.read(settingsRepositoryProvider).setNotificationsEnabled(value);
    if (profileId != null) await syncProfile(profileId);
  }

  Future<void> setPlannedActivityRemindersEnabled(
    bool value, {
    int? profileId,
  }) async {
    await _ref
        .read(settingsRepositoryProvider)
        .setPlannedActivityRemindersEnabled(value);
    if (profileId != null) await syncProfile(profileId);
  }

  Future<void> setReminderTimeMinutes(int? value, {int? profileId}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .setPlannedActivityReminderTimeMinutes(value);
    if (profileId != null) await syncProfile(profileId);
  }

  Future<NotificationPermissionStatus> permissionStatus() {
    return _ref
        .read(notificationPermissionGatewayProvider)
        .getPermissionStatus();
  }

  Future<NotificationPermissionStatus> requestPermission({
    int? profileId,
  }) async {
    final status = await _ref
        .read(notificationPermissionGatewayProvider)
        .requestPermission();
    if (profileId != null) await syncProfile(profileId);
    return status;
  }

  Future<void> syncProfile(int profileId) async {
    try {
      // Notification projection failures must not roll back or hide a
      // successfully persisted settings change.
      await _ref
          .read(plannedActivityReminderSyncServiceProvider)
          .syncAllPlannedActivityReminders(profileId: profileId);
    } on Object {
      // A later settings/permission change can retry reconciliation.
    }
  }
}
