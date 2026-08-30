import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/link_workout_session.dart';

import '../data/workout_test_helpers.dart';

/// Test di [LinkWorkoutSession] (Milestone 8.5): collegamento esplicito,
/// mai un matching implicito — type safety (sezione 41) e isolamento
/// profilo (sezione 40/73) validati qui.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late int profileId;
  late int otherProfileId;
  late int workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    profileId = await insertProfilo(db);
    otherProfileId = await insertProfilo(db);

    final categoryId = await insertCategoria(db);
    final exerciseId = await insertEsercizio(
      db,
      codice: 'A-001',
      idCategoria: categoryId,
      defaultReps: 10,
    );
    final workoutRepo = DriftWorkoutRepository(db);
    workoutId = await workoutRepo.createWorkoutWithExercises(
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

  Future<PlannedActivity> plannedWorkoutActivity({int? forProfileId}) async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: forProfileId ?? profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
        origin: PlannedActivityOrigin.user,
      ),
    );
    return (await plannedActivityRepository.getById(id))!;
  }

  test('collega una WorkoutSession reale allo stesso profilo -> link '
      'persistito', () async {
    final activity = await plannedWorkoutActivity();
    final sessionId = await _createRealSession(
      workoutSessionRepository,
      db,
      profileId,
      workoutId,
    );

    await LinkWorkoutSession(
      plannedActivityRepository,
      workoutSessionRepository,
    )(activity: activity, workoutSessionId: sessionId);

    final saved = await plannedActivityRepository.getById(activity.id!);
    expect(saved!.workoutSessionId, sessionId);
  });

  test('attività di tipo WALK/RECOVERY non può collegare una '
      'WorkoutSession', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.walk,
        origin: PlannedActivityOrigin.user,
      ),
    );
    final walkActivity = (await plannedActivityRepository.getById(id))!;
    final sessionId = await _createRealSession(
      workoutSessionRepository,
      db,
      profileId,
      workoutId,
    );

    expect(
      () => LinkWorkoutSession(
        plannedActivityRepository,
        workoutSessionRepository,
      )(activity: walkActivity, workoutSessionId: sessionId),
      throwsArgumentError,
    );
  });

  test(
    'sessione di un altro profilo -> rifiutata (isolamento profilo)',
    () async {
      final activity = await plannedWorkoutActivity();
      final sessionId = await _createRealSession(
        workoutSessionRepository,
        db,
        otherProfileId,
        workoutId,
      );

      expect(
        () => LinkWorkoutSession(
          plannedActivityRepository,
          workoutSessionRepository,
        )(activity: activity, workoutSessionId: sessionId),
        throwsArgumentError,
      );
    },
  );

  test('sessione inesistente -> rifiutata', () async {
    final activity = await plannedWorkoutActivity();
    expect(
      () => LinkWorkoutSession(
        plannedActivityRepository,
        workoutSessionRepository,
      )(activity: activity, workoutSessionId: 999999),
      throwsArgumentError,
    );
  });
}

Future<int> _createRealSession(
  DriftWorkoutSessionRepository repository,
  AppDatabase db,
  int profileId,
  int workoutId,
) async {
  final details = await DriftWorkoutRepository(db).getWorkoutDetails(workoutId);
  return repository.createSession(
    profileId: profileId,
    details: details!,
    startedAt: DateTime(2026, 9, 7, 8),
  );
}
