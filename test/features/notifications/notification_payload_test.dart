import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/domain/notification_payload.dart';

void main() {
  test('payload encode/decode mantiene solo i dati minimi', () {
    const payload = NotificationPayload(type: 'planned_activity', entityId: 42);

    final decoded = NotificationPayloadCodec.tryDecode(
      NotificationPayloadCodec.encode(payload),
    );

    expect(decoded?.version, 1);
    expect(decoded?.type, 'planned_activity');
    expect(decoded?.entityId, 42);
  });

  test(
    'payload invalido, versione o tipo sconosciuto non fanno crashare il tap',
    () {
      expect(NotificationPayloadCodec.tryDecode(null), isNull);
      expect(NotificationPayloadCodec.tryDecode('{bad json'), isNull);
      expect(
        NotificationPayloadCodec.tryDecode('{"v":2,"type":"x","entityId":1}'),
        isNull,
      );
      expect(
        NotificationPayloadCodec.tryDecode(
          '{"v":1,"type":"future","entityId":1}',
        ),
        isNotNull,
      );
      expect(
        NotificationPayloadCodec.tryDecode('{"v":1,"type":"","entityId":1}'),
        isNull,
      );
    },
  );

  test('payload non accetta identificatori non validi', () {
    expect(
      () => NotificationPayloadCodec.encode(
        const NotificationPayload(type: 'x', entityId: 0),
      ),
      throwsArgumentError,
    );
  });
}
