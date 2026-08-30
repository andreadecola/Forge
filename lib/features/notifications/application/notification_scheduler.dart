import '../../../domain/services/clock.dart';
import '../domain/local_notification_gateway.dart';
import '../domain/scheduled_local_notification.dart';
import 'notification_operation.dart';

class NotificationScheduler {
  const NotificationScheduler({required this.gateway, required this.clock});

  final LocalNotificationGateway gateway;
  final Clock clock;

  Future<NotificationOperationResult> schedule(
    ScheduledLocalNotification notification,
  ) async {
    if (!notification.scheduledAt.isAfter(clock.now())) {
      return const NotificationOperationResult.failure(
        NotificationOperationFailure.invalidSchedule,
      );
    }

    try {
      await gateway.schedule(notification);
      return const NotificationOperationResult.success();
    } on NotificationGatewayException catch (error) {
      return NotificationOperationResult.failure(error.failure);
    } on Object {
      return const NotificationOperationResult.failure(
        NotificationOperationFailure.pluginFailure,
      );
    }
  }

  Future<NotificationOperationResult> cancel(int id) async {
    try {
      await gateway.cancel(id);
      return const NotificationOperationResult.success();
    } on Object {
      return const NotificationOperationResult.failure(
        NotificationOperationFailure.pluginFailure,
      );
    }
  }

  Future<NotificationOperationResult> cancelAll() async {
    try {
      await gateway.cancelAll();
      return const NotificationOperationResult.success();
    } on Object {
      return const NotificationOperationResult.failure(
        NotificationOperationFailure.pluginFailure,
      );
    }
  }
}
