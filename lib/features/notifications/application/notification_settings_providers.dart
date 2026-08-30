import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/notification_settings.dart';
import '../domain/notification_permission_status.dart';
import 'notification_providers.dart';
import 'notification_settings_controller.dart';

final notificationSettingsProvider = FutureProvider<NotificationSettings>((
  ref,
) {
  return ref.watch(settingsRepositoryProvider).getNotificationSettings();
});

final notificationPermissionStatusProvider =
    FutureProvider<NotificationPermissionStatus>((ref) {
      return ref
          .watch(notificationPermissionGatewayProvider)
          .getPermissionStatus();
    });

final notificationSettingsControllerProvider =
    Provider<NotificationSettingsController>(
      (ref) => NotificationSettingsController(ref),
    );
