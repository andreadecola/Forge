import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_walking_session_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/delete_planned_activity.dart';
import 'package:forge/domain/use_cases/link_walking_session.dart';
import 'package:forge/domain/use_cases/link_workout_session.dart';

import '../data/workout_test_helpers.dart';

/// Test di [DeletePlannedActivity] (Milestone 8.5, sezione 27/28/29):
/// blocca l'eliminazione solo se la sessione collegata è ancora ATTIVA —
/// mai per una sessione COMPLETED/ABORTED, e la sessione reale non viene
/// mai toccata dall'eliminazione del piano.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late DeletePlannedActivity deleteUseCase;
  late int profileId;
  late int workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    deleteUseCase = DeletePlannedActivity(
      plannedActivityRepository,
      workoutSessionRepository,
      walkingSessionRepository,
    );
    profileId = await insertProfilo(db);

    final categoryId = await insertCategoria(db);
    final exerciseId = await insertEsercizio(
      db,
      codice: 'A-001',
      idCategoria: categoryId,
      defaultReps: 10,
    );
    workoutId = await DriftWorkoutRepository(db).createWorkoutWithExercises(
      workout: Workout(
        profileId: profileId,
        name: 'Scheda gambe',
        type: WorkoutType.lowerBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
      exercises: [
        WorkoutExercise(
          workoutId: 0,
          exerciseId: exerciseId,
          order: 1,
          sets: 1,
          repetitions: 10,
        ),
      ],
    );
  });

  tearDown(() => db.close());

  Future<PlannedActivity> plannedWorkoutActivity() async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
        origin: PlannedActivityOrigin.user,
      ),
    );
    return (await plannedActivityRepository.getById(id))!;
  }

  test('nessuna sessione collegata -> eliminazione normale', () async {
    final activity = await plannedWorkoutActivity();
    await deleteUseCase(activity.id!);
    expect(await plannedActivityRepository.getById(activity.id!), isNull);
  });

  test('sessione Workout IN_PROGRESS collegata -> eliminazione rifiutata, '
      'piano e sessione restano', () async {
    var activity = await plannedWorkoutActivity();
    final details = await DriftWorkoutRepository(
      db,
    ).getWorkoutDetails(workoutId);
    final sessionId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: details!,
      startedAt: DateTime(2026, 9, 7, 8),
    );
    await LinkWorkoutSession(
      plannedActivityRepository,
      workoutSessionRepository,
    )(activity: activity, workoutSessionId: sessionId);
    activity = (await plannedActivityRepository.getById(activity.id!))!;

    expect(() => deleteUseCase(activity.id!), throwsArgumentError);

    expect(await plannedActivityRepository.getById(activity.id!), isNotNull);
    expect(await workoutSessionRepository.getSessionById(sessionId), isNotNull);
  });

  test('sessione Workout COMPLETED collegata -> eliminazione consentita, '
      'la sessione resta nello storico', () async {
    var activity = await plannedWorkoutActivity();
    final details = await DriftWorkoutRepository(
      db,
    ).getWorkoutDetails(workoutId);
    final sessionId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: details!,
      startedAt: DateTime(2026, 9, 7, 8),
    );
    await LinkWorkoutSession(
      plannedActivityRepository,
      workoutSessionRepository,
    )(activity: activity, workoutSessionId: sessionId);
    activity = (await plannedActivityRepository.getById(activity.id!))!;
    await workoutSessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 9, 7, 9),
    );

    await deleteUseCase(activity.id!);

    expect(await plannedActivityRepository.getById(activity.id!), isNull);
    final session = await workoutSessionRepository.getSessionById(sessionId);
    expect(session, isNotNull);
    expect(session!.isCompleted, isTrue);
  });

  test(
    'sessione Walk IN_PROGRESS collegata -> eliminazione rifiutata',
    () async {
      final id = await AddPlannedActivity(plannedActivityRepository)(
        PlannedActivity(
          profileId: profileId,
          scheduledDate: DateTime(2026, 9, 7),
          type: PlannedActivityType.walk,
          origin: PlannedActivityOrigin.user,
        ),
      );
      var activity = (await plannedActivityRepository.getById(id))!;
      final sessionId = await walkingSessionRepository.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: DateTime(2026, 9, 7, 8),
          status: WalkingSessionStatus.inProgress,
        ),
      );
      await LinkWalkingSession(
        plannedActivityRepository,
        walkingSessionRepository,
      )(activity: activity, walkingSessionId: sessionId);
      activity = (await plannedActivityRepository.getById(activity.id!))!;

      expect(() => deleteUseCase(activity.id!), throwsArgumentError);
    },
  );

  test('sessione Walk ABORTED collegata -> eliminazione consentita', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.walk,
        origin: PlannedActivityOrigin.user,
      ),
    );
    var activity = (await plannedActivityRepository.getById(id))!;
    final sessionId = await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime(2026, 9, 7, 8),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await LinkWalkingSession(
      plannedActivityRepository,
      walkingSessionRepository,
    )(activity: activity, walkingSessionId: sessionId);
    activity = (await plannedActivityRepository.getById(activity.id!))!;
    await walkingSessionRepository.abortWalkingSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 9, 7, 9),
    );

    await deleteUseCase(activity.id!);
    expect(await plannedActivityRepository.getById(activity.id!), isNull);
    expect(
      await walkingSessionRepository.getWalkingSession(sessionId),
      isNotNull,
    );
  });

  test('id inesistente -> nessuna eccezione, nessun effetto', () async {
    await deleteUseCase(999999);
  });
}
