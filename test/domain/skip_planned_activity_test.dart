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
import 'package:forge/domain/use_cases/link_walking_session.dart';
import 'package:forge/domain/use_cases/link_workout_session.dart';
import 'package:forge/domain/use_cases/skip_planned_activity.dart';

import '../data/workout_test_helpers.dart';

/// Test di [SkipPlannedActivity] (Milestone 8.6, sezione 9/13/14/15/28/43):
/// sempre una decisione esplicita, mai dedotta da `scheduledDate < oggi` —
/// nessun test qui verifica un simile comportamento perché non esiste (vedi
/// invece `planned_activity_no_auto_skip_test.dart` per la controprova
/// esplicita).
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late SkipPlannedActivity skipUseCase;
  late int profileId;
  late int workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    skipUseCase = SkipPlannedActivity(
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

  Future<int> addActivity({
    PlannedActivityType type = PlannedActivityType.recovery,
    int? forWorkoutId,
  }) {
    return AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: type,
        workoutId: forWorkoutId,
        origin: PlannedActivityOrigin.user,
      ),
    );
  }

  test('RECOVERY senza sessione -> saltata', () async {
    final id = await addActivity();
    await skipUseCase(id);
    final saved = await plannedActivityRepository.getById(id);
    expect(saved!.status, PlannedActivityStatus.skipped);
  });

  test('sessione Workout IN_PROGRESS collegata -> rifiutata', () async {
    final id = await addActivity(
      type: PlannedActivityType.workout,
      forWorkoutId: workoutId,
    );
    var activity = (await plannedActivityRepository.getById(id))!;
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

    expect(() => skipUseCase(id), throwsArgumentError);

    activity = (await plannedActivityRepository.getById(id))!;
    expect(activity.status, PlannedActivityStatus.planned);
  });

  test('sessione Workout COMPLETED collegata -> rifiutata', () async {
    final id = await addActivity(
      type: PlannedActivityType.workout,
      forWorkoutId: workoutId,
    );
    var activity = (await plannedActivityRepository.getById(id))!;
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
    await workoutSessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 9, 7, 9),
    );

    expect(() => skipUseCase(id), throwsArgumentError);
  });

  test('sessione Workout ABORTED collegata -> consentita', () async {
    final id = await addActivity(
      type: PlannedActivityType.workout,
      forWorkoutId: workoutId,
    );
    var activity = (await plannedActivityRepository.getById(id))!;
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
    await workoutSessionRepository.abortSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 9, 7, 9),
    );

    await skipUseCase(id);
    activity = (await plannedActivityRepository.getById(id))!;
    expect(activity.status, PlannedActivityStatus.skipped);
  });

  test('sessione Walk IN_PROGRESS collegata -> rifiutata', () async {
    final id = await addActivity(type: PlannedActivityType.walk);
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

    expect(() => skipUseCase(id), throwsArgumentError);
  });

  test('già saltata -> idempotente, nessun effetto duplicato', () async {
    final id = await addActivity();
    await skipUseCase(id);
    await skipUseCase(id);
    final saved = await plannedActivityRepository.getById(id);
    expect(saved!.status, PlannedActivityStatus.skipped);
  });

  test('id inesistente -> nessuna eccezione, nessun effetto', () async {
    await skipUseCase(999999);
  });
}
