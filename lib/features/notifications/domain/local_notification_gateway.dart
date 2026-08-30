import 'notification_tap_event.dart';
import 'scheduled_local_notification.dart';

abstract interface class LocalNotificationGateway {
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent event)
    onNotificationTap,
  });

  Future<void> schedule(ScheduledLocalNotification notification);

  Future<void> cancel(int id);

  Future<void> cancelAll();
}
