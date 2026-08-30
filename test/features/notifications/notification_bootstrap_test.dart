import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/application/notification_bootstrap_service.dart';
import 'package:forge/features/notifications/domain/local_notification_gateway.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';
import 'package:forge/features/notifications/domain/scheduled_local_notification.dart';
import 'package:forge/features/notifications/application/notification_tap_event_bus.dart';

class _FakeGateway implements LocalNotificationGateway {
  _FakeGateway({this.shouldFail = false});

  final bool shouldFail;
  var initializeCalls = 0;

  @override
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent event)
    onNotificationTap,
  }) async {
    initializeCalls++;
    if (shouldFail) {
      throw StateError('plugin unavailable');
    }
  }

  @override
  Future<void> schedule(ScheduledLocalNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  test('bootstrap inizializza una volta e non richiede permission', () async {
    final gateway = _FakeGateway();
    final service = NotificationBootstrapService(
      gateway: gateway,
      eventBus: NotificationTapEventBus(),
    );

    final result = await service.initialize();

    expect(result.isReady, isTrue);
    expect(gateway.initializeCalls, 1);
  });

  test('fallimento bootstrap è non bloccante', () async {
    final service = NotificationBootstrapService(
      gateway: _FakeGateway(shouldFail: true),
      eventBus: NotificationTapEventBus(),
    );

    final result = await service.initialize();

    expect(result.isReady, isFalse);
  });
}
