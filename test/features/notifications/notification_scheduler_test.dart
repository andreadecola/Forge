import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/notifications/application/notification_operation.dart';
import 'package:forge/features/notifications/application/notification_scheduler.dart';
import 'package:forge/features/notifications/domain/local_notification_gateway.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';
import 'package:forge/features/notifications/domain/scheduled_local_notification.dart';

class _FakeClock implements Clock {
  _FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

class _FakeGateway implements LocalNotificationGateway {
  final scheduled = <ScheduledLocalNotification>[];
  final cancelled = <int>[];
  var cancelAllCalls = 0;

  @override
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent event)
    onNotificationTap,
  }) async {}

  @override
  Future<void> schedule(ScheduledLocalNotification notification) async {
    scheduled.add(notification);
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

void main() {
  final now = DateTime(2026, 8, 30, 10);

  test(
    'schedule future, cancel e cancelAll passano dal gateway fake',
    () async {
      final gateway = _FakeGateway();
      final scheduler = NotificationScheduler(
        gateway: gateway,
        clock: _FakeClock(now),
      );
      final notification = ScheduledLocalNotification(
        id: 1,
        scheduledAt: now.add(const Duration(hours: 1)),
        title: 'Forge',
        body: 'Promemoria',
      );

      expect((await scheduler.schedule(notification)).isSuccess, isTrue);
      expect((await scheduler.cancel(1)).isSuccess, isTrue);
      expect((await scheduler.cancelAll()).isSuccess, isTrue);
      expect(gateway.scheduled, hasLength(1));
      expect(gateway.cancelled, [1]);
      expect(gateway.cancelAllCalls, 1);
    },
  );

  test('schedule passato è rifiutato senza chiamare il gateway', () async {
    final gateway = _FakeGateway();
    final scheduler = NotificationScheduler(
      gateway: gateway,
      clock: _FakeClock(now),
    );

    final result = await scheduler.schedule(
      ScheduledLocalNotification(
        id: 1,
        scheduledAt: now,
        title: 'Forge',
        body: 'Promemoria',
      ),
    );

    expect(result.failure, NotificationOperationFailure.invalidSchedule);
    expect(gateway.scheduled, isEmpty);
  });
}
