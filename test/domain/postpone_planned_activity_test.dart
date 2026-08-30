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
import 'package:forge/domain/use_cases/postpone_planned_activity.dart';

import '../data/workout_test_helpers.dart';

/// Test di [PostponePlannedActivity] (Milestone 8.6, sezione 7/13/14/15/30):
/// stesse guardie di [SkipPlannedActivity] — la `scheduledDate` originale
/// resta invariata (il rinvio non assegna subito una nuova data, sezione
/// 7/106); "Sposta" (M8.6) è ciò che assegna una nuova data e riporta lo
/// stato a `PLANNED` (vedi `update_planned_activity_move_test.dart`).
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late PostponePlannedActivity postponeUseCase;
  late int profileId;
  late int workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    postponeUseCase = PostponePlannedActivity(
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

  test(
    'RECOVERY senza sessione -> rinviata, scheduledDate invariata',
    () async {
      final id = await addActivity();
      await postponeUseCase(id);
      final saved = await plannedActivityRepository.getById(id);
      expect(saved!.status, PlannedActivityStatus.postponed);
      expect(saved.scheduledDate, DateTime(2026, 9, 7));
    },
  );

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

    expect(() => postponeUseCase(id), throwsArgumentError);
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

    expect(() => postponeUseCase(id), throwsArgumentError);
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

    expect(() => postponeUseCase(id), throwsArgumentError);
  });

  test('già rinviata -> idempotente, nessun effetto duplicato', () async {
    final id = await addActivity();
    await postponeUseCase(id);
    await postponeUseCase(id);
    final saved = await plannedActivityRepository.getById(id);
    expect(saved!.status, PlannedActivityStatus.postponed);
  });

  test('id inesistente -> nessuna eccezione, nessun effetto', () async {
    await postponeUseCase(999999);
  });
}
