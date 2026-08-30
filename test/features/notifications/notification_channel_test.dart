import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/notifications/application/notification_constants.dart';
import 'package:forge/features/notifications/infrastructure/flutter_local_notification_gateway.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  test('channel unico con importanza moderata', () {
    expect(NotificationChannelConfig.id, 'forge_reminders');
    expect(NotificationChannelConfig.name, isNotEmpty);
    expect(
      NotificationChannelConfig.importance,
      NotificationChannelImportance.defaultImportance,
    );
  });

  test('lo scheduling Android è inexact e non richiede exact alarm', () {
    expect(
      FlutterLocalNotificationGateway.androidScheduleMode,
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
  });

  test('l adapter costruisce NotificationDetails sul channel Forge', () {
    final android =
        FlutterLocalNotificationGateway.notificationDetails.android!;

    expect(android.channelId, 'forge_reminders');
    expect(android.channelName, 'Promemoria Forge');
    expect(android.importance, Importance.defaultImportance);
    expect(android.priority, Priority.defaultPriority);
  });
}
