import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';
import 'package:forge/features/notifications/application/notification_settings_providers.dart';
import 'package:forge/features/notifications/domain/notification_permission_gateway.dart';
import 'package:forge/features/notifications/domain/notification_permission_status.dart';
import 'package:forge/features/notifications/application/notification_providers.dart';
import 'package:forge/data/repositories/repository_providers.dart';

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

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    settingsRepository = SettingsRepositoryImpl(database.appSettingsDao);
  });

  tearDown(() => database.close());

  test('permission request è invocabile solo dal flusso esplicito', () async {
    final gateway = _FakePermissionGateway(
      NotificationPermissionStatus.granted,
    );
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        notificationPermissionGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(notificationSettingsControllerProvider);

    await controller.setMasterEnabled(true);
    await controller.setReminderTimeMinutes(510);
    await controller.setPlannedActivityRemindersEnabled(true);
    expect(gateway.requestCount, 0);

    expect(
      await controller.requestPermission(),
      NotificationPermissionStatus.granted,
    );
    expect(gateway.requestCount, 1);
  });
}
