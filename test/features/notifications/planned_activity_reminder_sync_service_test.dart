import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/notification_settings.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/repositories/planned_activity_repository.dart';
import 'package:forge/domain/repositories/settings_repository.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/domain/use_cases/planned_activity_session_lookup.dart';
import 'package:forge/features/notifications/application/notification_constants.dart';
import 'package:forge/features/notifications/application/notification_ids.dart';
import 'package:forge/features/notifications/application/notification_operation.dart';
import 'package:forge/features/notifications/application/planned_activity_reminder_sync_service.dart';
import 'package:forge/features/notifications/domain/local_notification_gateway.dart';
import 'package:forge/features/notifications/domain/notification_permission_gateway.dart';
import 'package:forge/features/notifications/domain/notification_permission_status.dart';
import 'package:forge/features/notifications/domain/notification_tap_event.dart';
import 'package:forge/features/notifications/domain/notification_payload.dart';
import 'package:forge/features/notifications/domain/pending_local_notification.dart';
import 'package:forge/features/notifications/domain/pending_local_notification_reader.dart';
import 'package:forge/features/notifications/domain/scheduled_local_notification.dart';

class _FakeClock implements Clock {
  _FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

class _FakePermissionGateway implements NotificationPermissionGateway {
  NotificationPermissionStatus status;

  _FakePermissionGateway(this.status);

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async => status;

  @override
  Future<NotificationPermissionStatus> requestPermission() async => status;
}

class _FakeSettingsRepository implements SettingsRepository {
  NotificationSettings settings;

  _FakeSettingsRepository(this.settings);

  @override
  Future<NotificationSettings> getNotificationSettings() async => settings;

  @override
  Future<bool> getNotificationsEnabled() async => settings.notificationsEnabled;

  @override
  Future<bool> getPlannedActivityRemindersEnabled() async =>
      settings.plannedActivityRemindersEnabled;

  @override
  Future<int?> getPlannedActivityReminderTimeMinutes() async =>
      settings.plannedActivityReminderTimeMinutes;

  @override
  Future<String> getThemeMode() async => 'dark';

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<void> setNotificationsEnabled(bool value) async {}

  @override
  Future<void> setOnboardingCompleted(bool value) async {}

  @override
  Future<void> setPlannedActivityRemindersEnabled(bool value) async {}

  @override
  Future<void> setPlannedActivityReminderTimeMinutes(int? value) async {}

  @override
  Future<void> setThemeMode(String mode) async {}

  @override
  Stream<bool> watchOnboardingCompleted() => Stream.value(true);
}

class _FakePlannedActivityRepository implements PlannedActivityRepository {
  final activities = <int, PlannedActivity>{};

  @override
  Future<int> addPlannedActivity(PlannedActivity activity) async {
    final id =
        activity.id ?? (activities.keys.fold(0, (a, b) => a > b ? a : b) + 1);
    activities[id] = activity.copyWith(id: id);
    return id;
  }

  @override
  Future<void> deletePlannedActivity(int id) async => activities.remove(id);

  @override
  Future<List<PlannedActivity>> getAllForProfile({
    required int profileId,
  }) async => activities.values
      .where((activity) => activity.profileId == profileId)
      .toList();

  @override
  Future<PlannedActivity?> getById(int id) async => activities[id];

  @override
  Future<List<PlannedActivity>> getForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async => getAllForProfile(profileId: profileId);

  @override
  Future<void> linkWalkingSession({
    required int activityId,
    required int walkingSessionId,
  }) async {}

  @override
  Future<void> linkWorkoutSession({
    required int activityId,
    required int workoutSessionId,
  }) async {}

  @override
  Future<void> updatePlannedActivity(PlannedActivity activity) async {
    activities[activity.id!] = activity;
  }

  @override
  Stream<List<PlannedActivity>> watchForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) => Stream.value(const []);
}

class _FakeSessionStateResolver implements PlannedActivitySessionStateResolver {
  final states = <int, LinkedSessionState>{};

  @override
  Future<LinkedSessionState> resolve(PlannedActivity activity) async =>
      states[activity.id] ?? LinkedSessionState.none;
}

class _FakeGateway
    implements LocalNotificationGateway, PendingLocalNotificationReader {
  final pendingRequests = <int, PendingLocalNotification>{};
  final scheduled = <ScheduledLocalNotification>[];
  final cancelled = <int>[];

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pendingRequests.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    pendingRequests.clear();
  }

  @override
  Future<void> initialize({
    required Future<void> Function(NotificationTapEvent event)
    onNotificationTap,
  }) async {}

  @override
  Future<List<PendingLocalNotification>> pending() async =>
      pendingRequests.values.toList();

  @override
  Future<void> schedule(ScheduledLocalNotification notification) async {
    scheduled.add(notification);
    pendingRequests[notification.id] = PendingLocalNotification(
      id: notification.id,
      payload: notification.payload,
    );
  }
}

void main() {
  final now = DateTime(2026, 9, 1, 12);

  PlannedActivity activity({
    int id = 1,
    int profileId = 1,
    PlannedActivityType type = PlannedActivityType.workout,
    DateTime? date,
    PlannedActivityStatus status = PlannedActivityStatus.planned,
    int? workoutSessionId,
    int? walkingSessionId,
  }) => PlannedActivity(
    id: id,
    profileId: profileId,
    scheduledDate: date ?? DateTime(2026, 9, 2),
    type: type,
    workoutId: type == PlannedActivityType.workout ? 10 : null,
    status: status,
    origin: PlannedActivityOrigin.user,
    workoutSessionId: workoutSessionId,
    walkingSessionId: walkingSessionId,
  );

  PlannedActivityReminderSyncService createService({
    required _FakePlannedActivityRepository repository,
    required _FakeSettingsRepository settings,
    required _FakePermissionGateway permission,
    required _FakeGateway gateway,
    required _FakeSessionStateResolver sessionStates,
    _FakeClock? clock,
  }) => PlannedActivityReminderSyncService(
    plannedActivityRepository: repository,
    settingsRepository: settings,
    permissionGateway: permission,
    notificationGateway: gateway,
    sessionStateResolver: sessionStates,
    clock: clock ?? _FakeClock(now),
  );

  _FakeSettingsRepository enabledSettings([int? minutes = 510]) =>
      _FakeSettingsRepository(
        NotificationSettings(
          notificationsEnabled: true,
          plannedActivityRemindersEnabled: true,
          plannedActivityReminderTimeMinutes: minutes,
        ),
      );

  test(
    'WORKOUT eligible schedula con orario locale, copy e payload v1',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity();
      final gateway = _FakeGateway();
      final result = await createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: _FakeSessionStateResolver(),
      ).syncActivity(1);

      expect(result.outcome, PlannedActivityReminderSyncOutcome.scheduled);
      expect(gateway.scheduled, hasLength(1));
      final notification = gateway.scheduled.single;
      expect(notification.scheduledAt, DateTime(2026, 9, 2, 8, 30));
      expect(notification.title, 'Allenamento previsto oggi');
      expect(notification.body, 'Quando vuoi, il tuo allenamento è pronto.');
      final payload = NotificationPayloadCodec.tryDecode(notification.payload);
      expect(payload?.type, NotificationPayloadTypes.plannedActivity);
      expect(payload?.entityId, 1);
      expect(
        notification.id,
        NotificationIdGenerator.forEntity(
          namespace: PlannedActivityReminderSyncService.namespace,
          entityId: 1,
        ),
      );
    },
  );

  test('WALK eligible usa copy neutra dedicata', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity(type: PlannedActivityType.walk);
    final gateway = _FakeGateway();
    await createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    ).syncActivity(1);

    expect(gateway.scheduled.single.title, 'Camminata prevista oggi');
    expect(
      gateway.scheduled.single.body,
      'Quando vuoi, la tua camminata è pronta.',
    );
  });

  test('RECOVERY non schedula e cancella l id deterministico', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity(type: PlannedActivityType.recovery);
    final gateway = _FakeGateway();
    final result = await createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    ).syncActivity(1);

    expect(result.outcome, PlannedActivityReminderSyncOutcome.cancelled);
    expect(gateway.scheduled, isEmpty);
    expect(gateway.cancelled, hasLength(1));
  });

  test('stato skipped, completato o attivo cancella il reminder', () async {
    for (final scenario in [
      (PlannedActivityStatus.skipped, LinkedSessionState.none),
      (PlannedActivityStatus.planned, LinkedSessionState.completed),
      (PlannedActivityStatus.planned, LinkedSessionState.active),
    ]) {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity(status: scenario.$1);
      final gateway = _FakeGateway();
      final states = _FakeSessionStateResolver()..states[1] = scenario.$2;
      final result = await createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: states,
      ).syncActivity(1);
      expect(result.outcome, PlannedActivityReminderSyncOutcome.cancelled);
      expect(gateway.scheduled, isEmpty);
    }
  });

  test(
    'permission/settings/time non effective cancellano senza schedule',
    () async {
      for (final settings in [
        _FakeSettingsRepository(
          const NotificationSettings(
            notificationsEnabled: false,
            plannedActivityRemindersEnabled: true,
            plannedActivityReminderTimeMinutes: 510,
          ),
        ),
        _FakeSettingsRepository(
          const NotificationSettings(
            notificationsEnabled: true,
            plannedActivityRemindersEnabled: false,
            plannedActivityReminderTimeMinutes: 510,
          ),
        ),
        _FakeSettingsRepository(
          const NotificationSettings(
            notificationsEnabled: true,
            plannedActivityRemindersEnabled: true,
            plannedActivityReminderTimeMinutes: null,
          ),
        ),
      ]) {
        final repository = _FakePlannedActivityRepository()
          ..activities[1] = activity();
        final gateway = _FakeGateway();
        final result = await createService(
          repository: repository,
          settings: settings,
          permission: _FakePermissionGateway(
            NotificationPermissionStatus.denied,
          ),
          gateway: gateway,
          sessionStates: _FakeSessionStateResolver(),
        ).syncActivity(1);
        expect(result.outcome, PlannedActivityReminderSyncOutcome.cancelled);
        expect(gateway.scheduled, isEmpty);
      }
    },
  );

  test('permission denied non schedula; grant seguito da bulk crea', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity();
    final gateway = _FakeGateway();
    final permission = _FakePermissionGateway(
      NotificationPermissionStatus.denied,
    );
    final service = createService(
      repository: repository,
      settings: enabledSettings(),
      permission: permission,
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    );

    await service.syncActivity(1);
    expect(gateway.pendingRequests, isEmpty);
    permission.status = NotificationPermissionStatus.granted;
    await service.syncAllPlannedActivityReminders(profileId: 1);
    expect(gateway.pendingRequests, hasLength(1));
  });

  test(
    'past e oggi dopo l orario producono skippedPast, mai schedule immediato',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity(date: DateTime(2026, 8, 31));
      final gateway = _FakeGateway();
      final service = createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: _FakeSessionStateResolver(),
      );

      expect(
        (await service.syncActivity(1)).outcome,
        PlannedActivityReminderSyncOutcome.skippedPast,
      );
      repository.activities[1] = activity(date: DateTime(2026, 9, 1));
      expect(
        (await service.syncActivity(1)).outcome,
        PlannedActivityReminderSyncOutcome.skippedPast,
      );
      expect(gateway.scheduled, isEmpty);
    },
  );

  test('sync ripetuto è idempotente e mantiene una sola pending', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity();
    final gateway = _FakeGateway();
    final service = createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    );

    await service.syncActivity(1);
    await service.syncActivity(1);
    expect(gateway.pendingRequests, hasLength(1));
    expect(gateway.pendingRequests.keys.single, gateway.scheduled.first.id);
  });

  test('date change sostituisce A con B senza residui', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity(date: DateTime(2026, 9, 2));
    final gateway = _FakeGateway();
    final service = createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    );

    await service.syncActivity(1);
    repository.activities[1] = activity(date: DateTime(2026, 9, 3));
    await service.syncActivity(1);
    expect(gateway.pendingRequests, hasLength(1));
    expect(gateway.scheduled.last.scheduledAt, DateTime(2026, 9, 3, 8, 30));
  });

  test(
    'bulk time change aggiorna tutte le attività future del profilo',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity()
        ..activities[2] = activity(id: 2, type: PlannedActivityType.walk);
      final settings = enabledSettings();
      final gateway = _FakeGateway();
      final service = createService(
        repository: repository,
        settings: settings,
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: _FakeSessionStateResolver(),
      );

      await service.syncAllPlannedActivityReminders(profileId: 1);
      settings.settings = const NotificationSettings(
        notificationsEnabled: true,
        plannedActivityRemindersEnabled: true,
        plannedActivityReminderTimeMinutes: 1110,
      );
      await service.syncAllPlannedActivityReminders(profileId: 1);
      expect(gateway.pendingRequests, hasLength(2));
      expect(gateway.scheduled.last.scheduledAt.hour, 18);
      expect(gateway.scheduled.last.scheduledAt.minute, 30);
    },
  );

  test(
    'skip/delete/completion cancellano e l attività eliminata è notFound',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity();
      final gateway = _FakeGateway();
      final states = _FakeSessionStateResolver();
      final service = createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: states,
      );

      await service.syncActivity(1);
      repository.activities[1] = activity(
        status: PlannedActivityStatus.skipped,
      );
      await service.syncActivity(1);
      expect(gateway.pendingRequests, isEmpty);
      repository.activities[1] = activity();
      await service.syncActivity(1);
      states.states[1] = LinkedSessionState.completed;
      await service.syncActivity(1);
      expect(gateway.pendingRequests, isEmpty);
      repository.activities.remove(1);
      expect(
        (await service.syncActivity(1)).outcome,
        PlannedActivityReminderSyncOutcome.notFound,
      );
      expect(gateway.pendingRequests, isEmpty);
    },
  );

  test(
    'bulk cleanup rimuove solo planned_activity e preserva altre categorie',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity();
      final gateway = _FakeGateway();
      gateway.pendingRequests[99] = PendingLocalNotification(
        id: 99,
        payload: NotificationPayloadCodec.encode(
          const NotificationPayload(type: 'weight', entityId: 5),
        ),
      );
      gateway.pendingRequests[100] = PendingLocalNotification(
        id: 100,
        payload: NotificationPayloadCodec.encode(
          const NotificationPayload(
            type: NotificationPayloadTypes.plannedActivity,
            entityId: 404,
          ),
        ),
      );
      final service = createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: _FakeSessionStateResolver(),
      );

      await service.syncAllPlannedActivityReminders(profileId: 1);
      expect(gateway.pendingRequests.containsKey(99), isTrue);
      expect(gateway.pendingRequests.containsKey(100), isFalse);
      expect(gateway.pendingRequests, hasLength(2));
    },
  );

  test('bulk usa solo il profilo richiesto', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity(profileId: 1)
      ..activities[2] = activity(id: 2, profileId: 2);
    final gateway = _FakeGateway();
    final service = createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    );

    await service.syncAllPlannedActivityReminders(profileId: 1);
    expect(gateway.pendingRequests, hasLength(1));
    expect(
      gateway.pendingRequests.keys.single,
      isNot(
        NotificationIdGenerator.forEntity(
          namespace: PlannedActivityReminderSyncService.namespace,
          entityId: 2,
        ),
      ),
    );
  });

  test(
    'sessione abortita non rende completata l attività e il reminder resta eleggibile',
    () async {
      final repository = _FakePlannedActivityRepository()
        ..activities[1] = activity(workoutSessionId: 20);
      final gateway = _FakeGateway();
      final states = _FakeSessionStateResolver()
        ..states[1] = LinkedSessionState.none;
      final result = await createService(
        repository: repository,
        settings: enabledSettings(),
        permission: _FakePermissionGateway(
          NotificationPermissionStatus.granted,
        ),
        gateway: gateway,
        sessionStates: states,
      ).syncActivity(1);

      expect(result.outcome, PlannedActivityReminderSyncOutcome.scheduled);
    },
  );

  test('clock e data DST mantengono la wall clock locale', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity(date: DateTime(2026, 3, 29));
    final gateway = _FakeGateway();
    await createService(
      repository: repository,
      settings: enabledSettings(90),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
      clock: _FakeClock(DateTime(2026, 3, 28, 12)),
    ).syncActivity(1);

    expect(gateway.scheduled.single.scheduledAt, DateTime(2026, 3, 29, 1, 30));
  });

  test('fallimento gateway è risultato controllato e non eccezione', () async {
    final repository = _FakePlannedActivityRepository()
      ..activities[1] = activity();
    final gateway = _ThrowingGateway();
    final result = await createService(
      repository: repository,
      settings: enabledSettings(),
      permission: _FakePermissionGateway(NotificationPermissionStatus.granted),
      gateway: gateway,
      sessionStates: _FakeSessionStateResolver(),
    ).syncActivity(1);

    expect(result.outcome, PlannedActivityReminderSyncOutcome.failed);
    expect(result.failure, NotificationOperationFailure.pluginFailure);
  });
}

class _ThrowingGateway extends _FakeGateway {
  @override
  Future<void> cancel(int id) async {
    throw const NotificationGatewayException(
      NotificationOperationFailure.pluginFailure,
    );
  }
}
