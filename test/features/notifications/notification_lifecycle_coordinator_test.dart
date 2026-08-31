import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/user_profile.dart';
import 'package:forge/domain/repositories/profile_repository.dart';
import 'package:forge/features/notifications/application/notification_bootstrap_service.dart';
import 'package:forge/features/notifications/application/notification_lifecycle_coordinator.dart';
import 'package:forge/features/notifications/application/planned_activity_reminder_sync_service.dart';
import 'package:forge/features/notifications/infrastructure/notification_timezone_service.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  UserProfile? profile;

  @override
  Future<UserProfile?> getCurrentProfile() async => profile;

  @override
  Stream<UserProfile?> watchCurrentProfile() => Stream.value(profile);

  @override
  Future<List<UserProfile>> getAllProfiles() async => [?profile];

  @override
  Future<int> saveProfile(UserProfile profile) async => profile.id ?? 1;
}

class _FakeTimezoneRefresher implements NotificationTimezoneRefresher {
  _FakeTimezoneRefresher(this.result);

  bool result;
  var calls = 0;

  @override
  Future<bool> refreshIfChanged() async {
    calls++;
    return result;
  }
}

class _FakeReconciler implements PlannedActivityReminderReconciler {
  var syncCalls = 0;
  var clearCalls = 0;
  var concurrentCalls = 0;
  var maxConcurrentCalls = 0;
  Completer<void>? gate;

  @override
  Future<void> clearAllPlannedActivityReminders() async => clearCalls++;

  @override
  Future<PlannedActivityReminderBulkSyncResult>
  syncAllPlannedActivityReminders({required int profileId}) async {
    syncCalls++;
    concurrentCalls++;
    maxConcurrentCalls = maxConcurrentCalls > concurrentCalls
        ? maxConcurrentCalls
        : concurrentCalls;
    try {
      await gate?.future;
    } finally {
      concurrentCalls--;
    }
    return const PlannedActivityReminderBulkSyncResult(
      activityResults: [],
      orphanCleanupResult: null,
    );
  }
}

class _ThrowingReconciler extends _FakeReconciler {
  @override
  Future<PlannedActivityReminderBulkSyncResult>
  syncAllPlannedActivityReminders({required int profileId}) async {
    throw StateError('reconciliation failed');
  }
}

UserProfile _profile() => UserProfile(
  id: 7,
  name: 'Test',
  birthDate: DateTime(1990),
  heightCm: 175,
  initialWeightKg: 70,
  preferredWalkMinutes: 30,
  equipmentBudgetLimit: 0,
  startDate: DateTime(2026),
);

void main() {
  NotificationLifecycleCoordinator createCoordinator({
    UserProfile? profile,
    bool timezoneReady = true,
    _FakeReconciler? reconciler,
  }) {
    return NotificationLifecycleCoordinator(
      notificationBootstrap: () async =>
          const NotificationBootstrapResult.ready(),
      catalogBootstrap: () async =>
          const CatalogSeedResult(alreadyImported: true),
      profileRepository: _FakeProfileRepository(profile),
      timezoneService: _FakeTimezoneRefresher(timezoneReady),
      reminderSyncService: reconciler ?? _FakeReconciler(),
    );
  }

  test('startup con profilo riconcilia senza richiedere permission', () async {
    final reconciler = _FakeReconciler();
    await createCoordinator(
      profile: _profile(),
      reconciler: reconciler,
    ).startup();

    expect(reconciler.syncCalls, 1);
    expect(reconciler.clearCalls, 0);
  });

  test('no profile o timezone non risolvibile fanno solo cleanup', () async {
    final noProfile = _FakeReconciler();
    await createCoordinator(reconciler: noProfile).startup();
    expect(noProfile.syncCalls, 0);
    expect(noProfile.clearCalls, 1);

    final badTimezone = _FakeReconciler();
    await createCoordinator(
      profile: _profile(),
      timezoneReady: false,
      reconciler: badTimezone,
    ).onResumed();
    expect(badTimezone.syncCalls, 0);
    expect(badTimezone.clearCalls, 1);
  });

  test('startup failure non blocca Forge', () async {
    final reconciler = _FakeReconciler();
    final coordinator = NotificationLifecycleCoordinator(
      notificationBootstrap: () async =>
          const NotificationBootstrapResult.unavailable(),
      catalogBootstrap: () async =>
          const CatalogSeedResult(alreadyImported: true),
      profileRepository: _FakeProfileRepository(_profile()),
      timezoneService: _FakeTimezoneRefresher(true),
      reminderSyncService: reconciler,
    );

    await coordinator.startup();
    expect(reconciler.syncCalls, 0);
    expect(reconciler.clearCalls, 1);
  });

  test(
    'resume ravvicinati sono serializzati e l ultima richiesta è vista',
    () async {
      final reconciler = _FakeReconciler()..gate = Completer<void>();
      final coordinator = createCoordinator(
        profile: _profile(),
        reconciler: reconciler,
      );
      final first = coordinator.onResumed();
      final second = coordinator.onResumed();
      await Future<void>.delayed(Duration.zero);
      expect(reconciler.maxConcurrentCalls, 1);
      reconciler.gate!.complete();
      await Future.wait([first, second]);
      expect(reconciler.syncCalls, 2);
      expect(reconciler.maxConcurrentCalls, 1);
    },
  );

  test(
    'failure reconciliation non lascia errori asincroni non gestiti',
    () async {
      final coordinator = createCoordinator(
        profile: _profile(),
        reconciler: _ThrowingReconciler(),
      );

      await expectLater(coordinator.onResumed(), completes);
      await expectLater(coordinator.onResumed(), completes);
    },
  );
}
