import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/link_walking_session.dart';

import '../data/workout_test_helpers.dart';

/// Test di [LinkWalkingSession] (Milestone 8.5): stesso principio di
/// `link_workout_session_test.dart`, per `camminate`.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late int profileId;
  late int otherProfileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    profileId = await insertProfilo(db);
    otherProfileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  Future<PlannedActivity> plannedWalkActivity({int? forProfileId}) async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: forProfileId ?? profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.walk,
        origin: PlannedActivityOrigin.user,
      ),
    );
    return (await plannedActivityRepository.getById(id))!;
  }

  Future<int> createRealSession(int forProfileId) {
    return walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: forProfileId,
        startedAt: DateTime(2026, 9, 7, 8),
        status: WalkingSessionStatus.inProgress,
      ),
    );
  }

  test('collega una WalkingSession reale allo stesso profilo -> link '
      'persistito', () async {
    final activity = await plannedWalkActivity();
    final sessionId = await createRealSession(profileId);

    await LinkWalkingSession(
      plannedActivityRepository,
      walkingSessionRepository,
    )(activity: activity, walkingSessionId: sessionId);

    final saved = await plannedActivityRepository.getById(activity.id!);
    expect(saved!.walkingSessionId, sessionId);
  });

  test('attività di tipo WORKOUT/RECOVERY non può collegare una '
      'WalkingSession', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );
    final recoveryActivity = (await plannedActivityRepository.getById(id))!;
    final sessionId = await createRealSession(profileId);

    expect(
      () => LinkWalkingSession(
        plannedActivityRepository,
        walkingSessionRepository,
      )(activity: recoveryActivity, walkingSessionId: sessionId),
      throwsArgumentError,
    );
  });

  test(
    'sessione di un altro profilo -> rifiutata (isolamento profilo)',
    () async {
      final activity = await plannedWalkActivity();
      final sessionId = await createRealSession(otherProfileId);

      expect(
        () => LinkWalkingSession(
          plannedActivityRepository,
          walkingSessionRepository,
        )(activity: activity, walkingSessionId: sessionId),
        throwsArgumentError,
      );
    },
  );

  test('sessione inesistente -> rifiutata', () async {
    final activity = await plannedWalkActivity();
    expect(
      () => LinkWalkingSession(
        plannedActivityRepository,
        walkingSessionRepository,
      )(activity: activity, walkingSessionId: 999999),
      throwsArgumentError,
    );
  });
}
