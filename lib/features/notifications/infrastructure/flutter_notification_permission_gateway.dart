import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/notification_permission_gateway.dart';
import '../domain/notification_permission_status.dart';

class FlutterNotificationPermissionGateway
    implements NotificationPermissionGateway {
  const FlutterNotificationPermissionGateway({required this.plugin});

  final FlutterLocalNotificationsPlugin plugin;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final android = _androidPlugin;
    if (android == null) {
      return NotificationPermissionStatus.unsupported;
    }
    final enabled = await android.areNotificationsEnabled();
    if (enabled == null) {
      return statusFromAndroid(enabled);
    }
    return statusFromAndroid(enabled);
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final android = _androidPlugin;
    if (android == null) {
      return NotificationPermissionStatus.unsupported;
    }
    final granted = await android.requestNotificationsPermission();
    if (granted == null) {
      return statusFromAndroid(granted);
    }
    return statusFromAndroid(granted);
  }

  static NotificationPermissionStatus statusFromAndroid(bool? enabled) {
    if (enabled == null) {
      return NotificationPermissionStatus.unsupported;
    }
    return enabled
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }
}
