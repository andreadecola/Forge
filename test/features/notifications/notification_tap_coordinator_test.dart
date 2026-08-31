import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/application/notification_tap_coordinator.dart';
import 'package:forge/features/notifications/application/notification_tap_event_bus.dart';
import 'package:forge/features/notifications/domain/notification_payload.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';

NotificationTapEvent event({int id = 1, bool valid = true}) =>
    NotificationTapEvent(
      rawPayload: valid
          ? NotificationPayloadCodec.encode(
              NotificationPayload(type: 'planned_activity', entityId: id),
            )
          : '{bad',
      payload: valid
          ? NotificationPayload(type: 'planned_activity', entityId: id)
          : null,
    );

void main() {
  test('cold-start event resta in coda finché il router è pronto', () async {
    final bus = NotificationTapEventBus();
    final coordinator = NotificationTapCoordinator(eventBus: bus);
    coordinator.start();
    bus.emit(event());
    final received = <NotificationTapEvent>[];
    coordinator.setHandler((value) async => received.add(value));
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    await coordinator.dispose();
  });

  test(
    'tap singolo non naviga due volte e gli eventi invalidi non esplodono',
    () async {
      final bus = NotificationTapEventBus();
      final coordinator = NotificationTapCoordinator(eventBus: bus);
      coordinator.start();
      var calls = 0;
      final gate = Completer<void>();
      coordinator.setHandler((value) async {
        calls++;
        await gate.future;
      });
      bus.emit(event());
      bus.emit(event(valid: false));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      gate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(calls, 2);
      await coordinator.dispose();
    },
  );
}
