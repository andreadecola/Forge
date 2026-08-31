import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../application/notification_constants.dart';
import '../application/notification_operation.dart';
import '../domain/local_notification_gateway.dart';
import '../domain/notification_payload.dart';
import '../domain/notification_tap_event.dart';
import '../domain/pending_local_notification.dart';
import '../domain/pending_local_notification_reader.dart';
import '../domain/scheduled_local_notification.dart';
import 'notification_timezone_service.dart';

class FlutterLocalNotificationGateway
    implements LocalNotificationGateway, PendingLocalNotificationReader {
  static const androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

  static const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      NotificationChannelConfig.id,
      NotificationChannelConfig.name,
      channelDescription: NotificationChannelConfig.description,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );

  FlutterLocalNotificationGateway({
    required this.plugin,
    required this.timezoneInitializer,
    required this.toLocalWallClock,
  });

  final FlutterLocalNotificationsPlugin plugin;
  final NotificationTimezoneInitializer timezoneInitializer;
  final tz.TZDateTime Function(DateTime scheduledAt) toLocalWallClock;
  bool _initialized = false;

  @override
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent event)
    onNotificationTap,
  }) async {
    if (_initialized) {
      return;
    }

    final timezoneReady = await timezoneInitializer.initialize();
    if (!timezoneReady) {
      throw const NotificationGatewayException(
        NotificationOperationFailure.timezoneUnavailable,
      );
    }

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) async {
        await onNotificationTap(_eventFromRawPayload(response.payload));
      },
    );

    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannelConfig.id,
        NotificationChannelConfig.name,
        description: NotificationChannelConfig.description,
        importance: Importance.defaultImportance,
      ),
    );

    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      await onNotificationTap(_eventFromRawPayload(payload));
    }

    _initialized = true;
  }

  @override
  Future<void> schedule(ScheduledLocalNotification notification) async {
    if (!_initialized) {
      throw const NotificationGatewayException(
        NotificationOperationFailure.pluginFailure,
      );
    }

    final scheduledDate = toLocalWallClock(notification.scheduledAt);
    await plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: androidScheduleMode,
      payload: notification.payload,
    );
  }

  @override
  Future<void> cancel(int id) => plugin.cancel(id: id);

  @override
  Future<List<PendingLocalNotification>> pending() async {
    final requests = await plugin.pendingNotificationRequests();
    return requests
        .map(
          (request) => PendingLocalNotification(
            id: request.id,
            payload: request.payload,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> cancelAll() => plugin.cancelAll();

  NotificationTapEvent _eventFromRawPayload(String? rawPayload) {
    return NotificationTapEvent(
      rawPayload: rawPayload,
      payload: NotificationPayloadCodec.tryDecode(rawPayload),
    );
  }
}
