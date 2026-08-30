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
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/link_walking_session.dart';
import 'package:forge/domain/use_cases/link_workout_session.dart';
import 'package:forge/domain/use_cases/planned_activity_session_lookup.dart';

import '../data/workout_test_helpers.dart';

/// Test end-to-end "riavvio dopo abbandono" (Milestone 8.8, sezione 13):
/// PlannedActivity -> avvia Sessione A -> abbandona -> avvia di nuovo
/// (Sessione B) -> completa B. Verifica in un colpo solo tutte le
/// invarianti che i singoli test di M8.5/M8.6 coprono separatamente ma mai
/// insieme in un unico scenario end-to-end reale.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late int profileId;
  late int workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
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

  test('Workout: sessione A abbandonata, sessione B avviata e completata — A '
      'resta nello storico, il link punta a B, B completata rende '
      'l\'attività completata', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
        origin: PlannedActivityOrigin.user,
      ),
    );
    var activity = (await plannedActivityRepository.getById(id))!;
    final details = await DriftWorkoutRepository(
      db,
    ).getWorkoutDetails(workoutId);

    // Sessione A: avviata, collegata, poi abbandonata.
    final sessionAId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: details!,
      startedAt: DateTime(2026, 9, 7, 8),
    );
    await LinkWorkoutSession(
      plannedActivityRepository,
      workoutSessionRepository,
    )(activity: activity, workoutSessionId: sessionAId);
    await workoutSessionRepository.abortSession(
      sessionId: sessionAId,
      endedAt: DateTime(2026, 9, 7, 8, 30),
    );

    activity = (await plannedActivityRepository.getById(id))!;
    expect(activity.workoutSessionId, sessionAId);
    expect(
      await resolveLinkedSessionState(
        activity,
        workoutSessionRepository,
        walkingSessionRepository,
      ),
      LinkedSessionState.none,
    );

    // Nuovo avvio: Sessione B, diversa da A, sovrascrive il link.
    final sessionBId = await workoutSessionRepository.createSession(
      profileId: profileId,
      details: details,
      startedAt: DateTime(2026, 9, 7, 9),
    );
    expect(sessionBId, isNot(sessionAId));
    await LinkWorkoutSession(
      plannedActivityRepository,
      workoutSessionRepository,
    )(activity: activity, workoutSessionId: sessionBId);
    activity = (await plannedActivityRepository.getById(id))!;
    expect(activity.workoutSessionId, sessionBId);

    // A resta recuperabile nello storico, invariata, mai toccata dal
    // nuovo avvio.
    final sessionA = await workoutSessionRepository.getSessionById(sessionAId);
    expect(sessionA, isNotNull);
    expect(sessionA!.status, WorkoutSessionPersistenceStatus.aborted);
    final history = await workoutSessionRepository.getSessionHistory(
      profileId: profileId,
    );
    expect(history.any((item) => item.sessionId == sessionAId), isTrue);

    // Completare B rende l'attività "completata" (derivato dal link
    // corrente, mai da A).
    await workoutSessionRepository.completeSession(
      sessionId: sessionBId,
      endedAt: DateTime(2026, 9, 7, 10),
    );
    activity = (await plannedActivityRepository.getById(id))!;
    expect(
      await resolveLinkedSessionState(
        activity,
        workoutSessionRepository,
        walkingSessionRepository,
      ),
      LinkedSessionState.completed,
    );
  });

  test('Walk: sessione A abbandonata, sessione B avviata e completata — '
      'stesso ciclo end-to-end', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.walk,
        origin: PlannedActivityOrigin.user,
      ),
    );
    var activity = (await plannedActivityRepository.getById(id))!;

    final sessionAId = await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime(2026, 9, 7, 8),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await LinkWalkingSession(
      plannedActivityRepository,
      walkingSessionRepository,
    )(activity: activity, walkingSessionId: sessionAId);
    await walkingSessionRepository.abortWalkingSession(
      sessionId: sessionAId,
      endedAt: DateTime(2026, 9, 7, 8, 30),
    );
    activity = (await plannedActivityRepository.getById(id))!;

    final sessionBId = await walkingSessionRepository.createWalkingSession(
      WalkingSession(
        profileId: profileId,
        startedAt: DateTime(2026, 9, 7, 9),
        status: WalkingSessionStatus.inProgress,
      ),
    );
    expect(sessionBId, isNot(sessionAId));
    await LinkWalkingSession(
      plannedActivityRepository,
      walkingSessionRepository,
    )(activity: activity, walkingSessionId: sessionBId);
    activity = (await plannedActivityRepository.getById(id))!;
    expect(activity.walkingSessionId, sessionBId);

    final sessionA = await walkingSessionRepository.getWalkingSession(
      sessionAId,
    );
    expect(sessionA!.status, WalkingSessionStatus.aborted);

    await walkingSessionRepository.completeWalkingSession(
      sessionId: sessionBId,
      endedAt: DateTime(2026, 9, 7, 10),
    );
    expect(
      await resolveLinkedSessionState(
        activity,
        workoutSessionRepository,
        walkingSessionRepository,
      ),
      LinkedSessionState.completed,
    );
  });
}
