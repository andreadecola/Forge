import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart';
import '../domain/local_notification_gateway.dart';
import '../domain/notification_permission_gateway.dart';
import '../domain/notification_tap_event.dart';
import '../infrastructure/device_timezone_resolver.dart';
import '../infrastructure/flutter_local_notification_gateway.dart';
import '../infrastructure/flutter_notification_permission_gateway.dart';
import '../infrastructure/notification_timezone_service.dart';
import 'notification_bootstrap_service.dart';
import 'notification_scheduler.dart';
import 'notification_tap_event_bus.dart';

final notificationTimezoneServiceProvider =
    Provider<NotificationTimezoneService>((ref) {
      return NotificationTimezoneService(
        resolver: const FlutterDeviceTimezoneResolver(),
      );
    });

final localNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
      (ref) => FlutterLocalNotificationsPlugin(),
    );

final notificationGatewayProvider = Provider<LocalNotificationGateway>((ref) {
  final timezoneService = ref.watch(notificationTimezoneServiceProvider);
  return FlutterLocalNotificationGateway(
    plugin: ref.watch(localNotificationsPluginProvider),
    timezoneInitializer: timezoneService,
    toLocalWallClock: timezoneService.toLocalWallClock,
  );
});

final notificationPermissionGatewayProvider =
    Provider<NotificationPermissionGateway>((ref) {
      return FlutterNotificationPermissionGateway(
        plugin: ref.watch(localNotificationsPluginProvider),
      );
    });

final notificationTapEventBusProvider = Provider<NotificationTapEventBus>((
  ref,
) {
  final bus = NotificationTapEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final notificationTapEventsProvider = StreamProvider<NotificationTapEvent>(
  (ref) => ref.watch(notificationTapEventBusProvider).stream,
);

final notificationBootstrapServiceProvider =
    Provider<NotificationBootstrapService>((ref) {
      return NotificationBootstrapService(
        gateway: ref.watch(notificationGatewayProvider),
        eventBus: ref.watch(notificationTapEventBusProvider),
      );
    });

final notificationBootstrapProvider =
    FutureProvider<NotificationBootstrapResult>((ref) {
      return ref.watch(notificationBootstrapServiceProvider).initialize();
    });

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    gateway: ref.watch(notificationGatewayProvider),
    clock: ref.watch(clockProvider),
  );
});
