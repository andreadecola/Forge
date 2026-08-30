import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/repository_providers.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/features/notifications/application/notification_providers.dart';
import 'package:forge/features/notifications/domain/notification_permission_gateway.dart';
import 'package:forge/features/notifications/domain/notification_permission_status.dart';
import 'package:forge/features/notifications/presentation/widgets/notification_settings_section.dart';

class _FakePermissionGateway implements NotificationPermissionGateway {
  _FakePermissionGateway(this.status);

  NotificationPermissionStatus status;
  int requestCount = 0;

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async => status;

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    requestCount++;
    return status;
  }
}

void main() {
  late AppDatabase database;
  late SettingsRepositoryImpl settingsRepository;
  late _FakePermissionGateway permissionGateway;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    settingsRepository = SettingsRepositoryImpl(database.appSettingsDao);
    await settingsRepository.setPlannedActivityReminderTimeMinutes(510);
    await settingsRepository.setPlannedActivityRemindersEnabled(true);
    permissionGateway = _FakePermissionGateway(
      NotificationPermissionStatus.granted,
    );
  });

  tearDown(() => database.close());

  testWidgets('attivazione master richiede il permesso solo dopo il tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          notificationPermissionGatewayProvider.overrideWithValue(
            permissionGateway,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NotificationSettingsSection(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(permissionGateway.requestCount, 0);
    await tester.tap(find.byKey(const ValueKey('notifications-master-switch')));
    await tester.pumpAndSettle();

    expect(permissionGateway.requestCount, 1);
    expect(await settingsRepository.getNotificationsEnabled(), isTrue);
    expect(find.text('Promemoria attività attivi.'), findsOneWidget);
  });

  testWidgets('permesso negato non blocca Forge e mostra stato controllato', (
    tester,
  ) async {
    permissionGateway.status = NotificationPermissionStatus.denied;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          notificationPermissionGatewayProvider.overrideWithValue(
            permissionGateway,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: NotificationSettingsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notifications-master-switch')));
    await tester.pumpAndSettle();

    expect(permissionGateway.requestCount, 1);
    expect(await settingsRepository.getNotificationsEnabled(), isTrue);
    expect(
      find.byKey(const ValueKey('notifications-permission-denied')),
      findsOneWidget,
    );
  });
}
