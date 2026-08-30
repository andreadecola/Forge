import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/domain/notification_permission_status.dart';
import 'package:forge/features/notifications/infrastructure/flutter_notification_permission_gateway.dart';

void main() {
  test('mappa gli esiti Android senza confondere unsupported e denied', () {
    expect(
      FlutterNotificationPermissionGateway.statusFromAndroid(true),
      NotificationPermissionStatus.granted,
    );
    expect(
      FlutterNotificationPermissionGateway.statusFromAndroid(false),
      NotificationPermissionStatus.denied,
    );
    expect(
      FlutterNotificationPermissionGateway.statusFromAndroid(null),
      NotificationPermissionStatus.unsupported,
    );
  });

  test('il modello conserva anche stati utili a piattaforme future', () {
    expect(
      NotificationPermissionStatus.values,
      containsAll(<NotificationPermissionStatus>[
        NotificationPermissionStatus.notDetermined,
        NotificationPermissionStatus.granted,
        NotificationPermissionStatus.denied,
        NotificationPermissionStatus.unsupported,
      ]),
    );
  });
}
