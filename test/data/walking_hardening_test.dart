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
  final startedAt = DateTime(2026, 1, 1, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWalkingSessionRepository(database);
    profileId = await insertProfilo(database);
  });

  tearDown(() => database.close());

  WalkingSession session([DateTime? start]) => WalkingSession(
    profileId: profileId,
    startedAt: start ?? startedAt,
    status: WalkingSessionStatus.inProgress,
  );

  test('creazioni concorrenti lasciano una sola sessione attiva', () async {
    final results = await Future.wait<Object>(
      [
        repository.createWalkingSession(session()),
        repository.createWalkingSession(
          session(startedAt.add(const Duration(seconds: 1))),
        ),
      ].map((operation) async {
        try {
          return await operation;
        } catch (error) {
          return error;
        }
      }),
    );

    expect(results.whereType<int>(), hasLength(1));
    expect(
      results.whereType<ActiveWalkingSessionAlreadyExistsException>(),
      hasLength(1),
    );
    expect(
      await repository.getWalkingSessions(profileId: profileId),
      hasLength(1),
    );
    expect(
      await repository.getActiveWalkingSession(profileId: profileId),
      isNotNull,
    );
  });

  test('lo stream storico esclude l attiva e riflette la chiusura', () async {
    final stream = repository.watchWalkingHistory(profileId: profileId);
    final values = <List<WalkingSession>>[];
    final subscription = stream.listen(values.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);

    final id = await repository.createWalkingSession(session());
    await Future<void>.delayed(Duration.zero);
    expect(values.last, isEmpty);

    await repository.completeWalkingSession(
      sessionId: id,
      endedAt: startedAt.add(const Duration(minutes: 1)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(values.last.map((item) => item.id), [id]);
  });

  test('dieci cicli pausa ripresa non perdono tempo', () async {
    final id = await repository.createWalkingSession(session());
    for (var index = 0; index < 10; index++) {
      final pauseAt = startedAt.add(Duration(minutes: index * 2 + 1));
      await repository.pauseWalkingSession(sessionId: id, pausedAt: pauseAt);
      await repository.resumeWalkingSession(
        sessionId: id,
        resumedAt: pauseAt.add(const Duration(seconds: 30)),
      );
    }

    final endedAt = startedAt.add(const Duration(minutes: 25));
    await repository.completeWalkingSession(sessionId: id, endedAt: endedAt);
    final completed = (await repository.getWalkingSession(id))!;
    expect(completed.accumulatedPauseSeconds, 300);
    expect(
      completed.chronologicalDuration(endedAt),
      const Duration(minutes: 25),
    );
    expect(completed.pauseDuration(endedAt), const Duration(minutes: 5));
    expect(completed.activeDuration(endedAt), const Duration(minutes: 20));
    expect(completed.isPaused, isFalse);
    expect(completed.pauseStartedAt, isNull);
  });

  test('durate molto brevi e oltre 24 ore restano valide', () async {
    final shortId = await repository.createWalkingSession(session());
    final shortEnd = startedAt.add(const Duration(seconds: 2));
    await repository.completeWalkingSession(
      sessionId: shortId,
      endedAt: shortEnd,
    );

    final longStart = startedAt.add(const Duration(days: 2));
    final longId = await repository.createWalkingSession(session(longStart));
    final longEnd = longStart.add(const Duration(hours: 25, minutes: 3));
    await repository.completeWalkingSession(
      sessionId: longId,
      endedAt: longEnd,
    );

    expect((await repository.getWalkingSession(shortId))!.durationSeconds, 2);
    expect(
      (await repository.getWalkingSession(longId))!.durationSeconds,
      const Duration(hours: 25, minutes: 3).inSeconds,
    );
  });

  test('metriche grandi restano persistite senza soglie artificiali', () async {
    final id = await repository.createWalkingSession(session());
    await repository.updateWalkingMetrics(
      sessionId: id,
      distanceMeters: 100000,
      steps: 150000,
    );
    final updated = (await repository.getWalkingSession(id))!;
    expect(updated.distanceMeters, 100000);
    expect(updated.steps, 150000);
    expect(updated.status, WalkingSessionStatus.inProgress);
  });
}
