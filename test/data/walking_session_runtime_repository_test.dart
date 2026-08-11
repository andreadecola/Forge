import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';

import 'workout_test_helpers.dart';

void main() {
  late AppDatabase database;
  late DriftWalkingSessionRepository repository;
  late int profileId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWalkingSessionRepository(database);
    profileId = await insertProfilo(database);
  });

  tearDown(() => database.close());

  test('runtime start/complete/abort aggiorna DB e conserva storico', () async {
    final start = DateTime(2026, 1, 1, 10);
    final completeId = await repository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: start,
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await repository.completeWalkingSession(
      sessionId: completeId,
      endedAt: start.add(const Duration(minutes: 5)),
    );

    final abortId = await repository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: start.add(const Duration(hours: 1)),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await repository.abortWalkingSession(
      sessionId: abortId,
      endedAt: start.add(const Duration(hours: 1, minutes: 1)),
    );

    final history = await repository.getWalkingSessions(profileId: profileId);
    expect(history, hasLength(2));
    expect(
      history.map((session) => session.status),
      containsAll([
        WalkingSessionStatus.completed,
        WalkingSessionStatus.aborted,
      ]),
    );
    expect(history.every((session) => session.endedAt != null), isTrue);
  });
}
