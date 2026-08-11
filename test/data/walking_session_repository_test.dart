import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/repositories/walking_session_repository.dart';

import 'workout_test_helpers.dart';

void main() {
  late AppDatabase database;
  late DriftWalkingSessionRepository repository;
  late int profileId;
  late DateTime startedAt;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWalkingSessionRepository(database);
    profileId = await insertProfilo(database);
    startedAt = DateTime(2026, 1, 1, 10);
  });

  tearDown(() => database.close());

  WalkingSession session([DateTime? start]) => WalkingSession(
    profileId: profileId,
    startedAt: start ?? startedAt,
    status: WalkingSessionStatus.inProgress,
  );

  test('create, getById, getByProfile e mapping enum/nullable', () async {
    final id = await repository.createWalkingSession(
      session().copyWith(steps: () => null, distanceMeters: () => null),
    );
    final byId = await repository.getWalkingSession(id);
    expect(byId, isNotNull);
    expect(byId!.id, id);
    expect(byId.status, WalkingSessionStatus.inProgress);
    expect(byId.steps, isNull);
    expect(byId.distanceMeters, isNull);
    expect(
      await repository.getWalkingSessions(profileId: profileId),
      hasLength(1),
    );
  });

  test('watchByProfile osserva inserimento e storico', () async {
    final stream = repository.watchWalkingSessions(profileId: profileId);
    expect(await stream.first, isEmpty);
    await repository.createWalkingSession(session());
    expect(await stream.first, hasLength(1));
  });

  test(
    'walking history esclude IN_PROGRESS e mantiene ordine deterministico',
    () async {
      final completedId = await repository.createWalkingSession(session());
      await repository.completeWalkingSession(
        sessionId: completedId,
        endedAt: startedAt.add(const Duration(minutes: 10)),
      );
      final abortedId = await repository.createWalkingSession(
        session(startedAt.add(const Duration(hours: 1))),
      );
      await repository.abortWalkingSession(
        sessionId: abortedId,
        endedAt: startedAt.add(const Duration(hours: 1, minutes: 5)),
      );
      final activeId = await repository.createWalkingSession(
        session(startedAt.add(const Duration(hours: 2))),
      );

      final history = await repository.getWalkingHistory(profileId: profileId);
      expect(history, hasLength(2));
      expect(history.map((item) => item.id), [abortedId, completedId]);
      expect(history.map((item) => item.status), [
        WalkingSessionStatus.aborted,
        WalkingSessionStatus.completed,
      ]);
      expect(history.any((item) => item.id == activeId), isFalse);

      final stream = repository.watchWalkingHistory(profileId: profileId);
      expect((await stream.first).map((item) => item.id), [
        abortedId,
        completedId,
      ]);
    },
  );

  test('active session e seconda IN_PROGRESS controllata', () async {
    final id = await repository.createWalkingSession(session());
    expect(
      (await repository.getActiveWalkingSession(profileId: profileId))!.id,
      id,
    );
    expect(
      () => repository.createWalkingSession(
        session(startedAt.add(const Duration(minutes: 1))),
      ),
      throwsA(isA<ActiveWalkingSessionAlreadyExistsException>()),
    );
  });

  test('update, complete, abort e storico conservato', () async {
    final completedId = await repository.createWalkingSession(session());
    await repository.updateWalkingSession(
      (await repository.getWalkingSession(completedId))!.copyWith(
        steps: () => 0,
        distanceMeters: () => 0,
        notes: () => 'breve',
      ),
    );
    final endedAt = startedAt.add(const Duration(minutes: 20));
    await repository.completeWalkingSession(
      sessionId: completedId,
      endedAt: endedAt,
    );

    final abortedId = await repository.createWalkingSession(
      session(startedAt.add(const Duration(hours: 1))),
    );
    await repository.abortWalkingSession(
      sessionId: abortedId,
      endedAt: startedAt.add(const Duration(hours: 1, minutes: 5)),
      steps: 12,
    );

    final rows = await repository.getWalkingSessions(profileId: profileId);
    expect(rows, hasLength(2));
    expect(
      rows.map((row) => row.status),
      containsAll([
        WalkingSessionStatus.completed,
        WalkingSessionStatus.aborted,
      ]),
    );
    expect(
      (await repository.getWalkingSession(completedId))!.durationSeconds,
      1200,
    );
    expect(
      await repository.getActiveWalkingSession(profileId: profileId),
      isNull,
    );
  });

  test(
    'pause, resume e multiple pause persistono i timestamp corretti',
    () async {
      final id = await repository.createWalkingSession(
        session().copyWith(distanceMeters: () => 2400, steps: () => 3200),
      );
      final pauseAt = startedAt.add(const Duration(minutes: 10));
      final resumedAt = startedAt.add(const Duration(minutes: 15));
      final paused = await repository.pauseWalkingSession(
        sessionId: id,
        pausedAt: pauseAt,
      );
      expect(paused!.isPaused, isTrue);
      expect(paused.pauseStartedAt, pauseAt);
      expect(paused.accumulatedPauseSeconds, 0);
      expect(
        await repository.pauseWalkingSession(
          sessionId: id,
          pausedAt: resumedAt,
        ),
        isNull,
      );

      final resumed = await repository.resumeWalkingSession(
        sessionId: id,
        resumedAt: resumedAt,
      );
      expect(resumed!.isPaused, isFalse);
      expect(resumed.pauseStartedAt, isNull);
      expect(resumed.accumulatedPauseSeconds, 300);
      expect(
        await repository.resumeWalkingSession(
          sessionId: id,
          resumedAt: resumedAt,
        ),
        isNull,
      );

      final secondPauseAt = startedAt.add(const Duration(minutes: 20));
      await repository.pauseWalkingSession(
        sessionId: id,
        pausedAt: secondPauseAt,
      );
      await repository.resumeWalkingSession(
        sessionId: id,
        resumedAt: startedAt.add(const Duration(minutes: 25)),
      );
      final updated = await repository.getWalkingSession(id);
      expect(updated!.accumulatedPauseSeconds, 600);
      expect(updated.distanceMeters, 2400);
      expect(updated.steps, 3200);
    },
  );

  test(
    'complete e abort mentre in pausa contabilizzano la pausa corrente',
    () async {
      final completedId = await repository.createWalkingSession(session());
      await repository.pauseWalkingSession(
        sessionId: completedId,
        pausedAt: startedAt.add(const Duration(minutes: 20)),
      );
      await repository.completeWalkingSession(
        sessionId: completedId,
        endedAt: startedAt.add(const Duration(minutes: 30)),
      );
      var completed = await repository.getWalkingSession(completedId);
      expect(completed!.status, WalkingSessionStatus.completed);
      expect(completed.isPaused, isFalse);
      expect(completed.pauseStartedAt, isNull);
      expect(completed.accumulatedPauseSeconds, 600);

      final abortedId = await repository.createWalkingSession(
        session(startedAt.add(const Duration(hours: 1))),
      );
      await repository.pauseWalkingSession(
        sessionId: abortedId,
        pausedAt: startedAt.add(const Duration(hours: 1, minutes: 20)),
      );
      await repository.abortWalkingSession(
        sessionId: abortedId,
        endedAt: startedAt.add(const Duration(hours: 1, minutes: 25)),
      );
      completed = await repository.getWalkingSession(abortedId);
      expect(completed!.status, WalkingSessionStatus.aborted);
      expect(completed.isPaused, isFalse);
      expect(completed.pauseStartedAt, isNull);
      expect(completed.accumulatedPauseSeconds, 300);
    },
  );

  test('updateWalkingMetrics aggiorna, svuota e conserva lo stato', () async {
    final id = await repository.createWalkingSession(session());

    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: 2400,
      steps: null,
    );
    var updated = await repository.getWalkingSession(id);
    expect(updated!.distanceMeters, 2400);
    expect(updated.steps, isNull);
    expect(updated.status, WalkingSessionStatus.inProgress);

    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: null,
      steps: 3200,
    );
    updated = await repository.getWalkingSession(id);
    expect(updated!.distanceMeters, isNull);
    expect(updated.steps, 3200);

    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: 2600,
      steps: 3400,
    );
    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: null,
      steps: null,
    );
    updated = await repository.getWalkingSession(id);
    expect(updated!.distanceMeters, isNull);
    expect(updated.steps, isNull);

    await repository.completeWalkingSession(
      sessionId: id,
      endedAt: startedAt.add(const Duration(minutes: 10)),
    );
    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: 2500,
      steps: 3000,
    );
    updated = await repository.getWalkingSession(id);
    expect(updated!.status, WalkingSessionStatus.completed);
    expect(updated.distanceMeters, 2500);
    expect(updated.steps, 3000);

    final abortedId = await repository.createWalkingSession(
      session(startedAt.add(const Duration(hours: 1))),
    );
    await repository.abortWalkingSession(
      sessionId: abortedId,
      endedAt: startedAt.add(const Duration(hours: 1, minutes: 5)),
    );
    await repository.updateWalkingMetrics(
      sessionId: abortedId,
      distanceMeters: 800,
      steps: 1000,
    );
    updated = await repository.getWalkingSession(abortedId);
    expect(updated!.status, WalkingSessionStatus.aborted);
    expect(updated.distanceMeters, 800);
    expect(updated.steps, 1000);
  });

  test('updateWalkingMetrics valida atomicamente valori negativi', () async {
    final id = await repository.createWalkingSession(
      session().copyWith(distanceMeters: () => 1000, steps: () => 1200),
    );

    expect(
      () => repository.updateWalkingMetrics(
        sessionId: id,
        distanceMeters: -1,
        steps: 1200,
      ),
      throwsA(isA<InvalidWalkingSessionException>()),
    );
    final unchanged = await repository.getWalkingSession(id);
    expect(unchanged!.distanceMeters, 1000);
    expect(unchanged.steps, 1200);
  });

  test('transizioni terminali ripetute sono no-op idempotenti', () async {
    final id = await repository.createWalkingSession(session());
    final endedAt = startedAt.add(const Duration(minutes: 3));
    await repository.completeWalkingSession(sessionId: id, endedAt: endedAt);
    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: 2500,
      steps: 3000,
    );

    await repository.completeWalkingSession(
      sessionId: id,
      endedAt: endedAt.add(const Duration(minutes: 1)),
    );
    await repository.abortWalkingSession(
      sessionId: id,
      endedAt: endedAt.add(const Duration(minutes: 2)),
    );

    final unchanged = await repository.getWalkingSession(id);
    expect(unchanged!.status, WalkingSessionStatus.completed);
    expect(unchanged.endedAt, endedAt);
    expect(unchanged.distanceMeters, 2500);
    expect(unchanged.steps, 3000);
  });
}
