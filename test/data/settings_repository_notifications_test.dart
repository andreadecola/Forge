import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase database;
  late SettingsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(database.appSettingsDao);
  });

  tearDown(() => database.close());

  test('nuove preferenze hanno default sicuri', () async {
    final settings = await repository.getNotificationSettings();

    expect(settings.notificationsEnabled, isFalse);
    expect(settings.plannedActivityRemindersEnabled, isFalse);
    expect(settings.plannedActivityReminderTimeMinutes, isNull);
  });

  test('master, categoria e orario vengono persistiti', () async {
    await repository.setNotificationsEnabled(true);
    await repository.setPlannedActivityReminderTimeMinutes(510);
    await repository.setPlannedActivityRemindersEnabled(true);

    final reloaded = SettingsRepositoryImpl(database.appSettingsDao);
    final settings = await reloaded.getNotificationSettings();

    expect(settings.notificationsEnabled, isTrue);
    expect(settings.plannedActivityRemindersEnabled, isTrue);
    expect(settings.plannedActivityReminderTimeMinutes, 510);
    expect(settings.hasDesiredPlannedActivityReminders, isTrue);
  });

  test('un orario nullo può essere salvato e rimuove il valore', () async {
    await repository.setPlannedActivityReminderTimeMinutes(1439);
    await repository.setPlannedActivityReminderTimeMinutes(null);

    expect(await repository.getPlannedActivityReminderTimeMinutes(), isNull);
  });

  test('orari fuori range vengono rifiutati', () async {
    await expectLater(
      repository.setPlannedActivityReminderTimeMinutes(-1),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      repository.setPlannedActivityReminderTimeMinutes(1440),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('categoria non attivabile senza un orario valido', () async {
    await expectLater(
      repository.setPlannedActivityRemindersEnabled(true),
      throwsA(isA<StateError>()),
    );
  });
}
