import '../domain/local_notification_gateway.dart';
import 'notification_tap_event_bus.dart';

class NotificationBootstrapService {
  const NotificationBootstrapService({
    required this.gateway,
    required this.eventBus,
  });

  final LocalNotificationGateway gateway;
  final NotificationTapEventBus eventBus;

  Future<NotificationBootstrapResult> initialize() async {
    try {
      await gateway.initialize(
        onNotificationTap: (event) async => eventBus.emit(event),
      );
      return const NotificationBootstrapResult.ready();
    } on Object {
      return const NotificationBootstrapResult.unavailable();
    }
  }
}

class NotificationBootstrapResult {
  const NotificationBootstrapResult.ready() : isReady = true;

  const NotificationBootstrapResult.unavailable() : isReady = false;

  final bool isReady;
}
