import 'notification_permission_status.dart';

abstract interface class NotificationPermissionGateway {
  Future<NotificationPermissionStatus> getPermissionStatus();

  Future<NotificationPermissionStatus> requestPermission();
}
