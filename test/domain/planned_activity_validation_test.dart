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
import 'package:forge/domain/use_cases/add_planned_activity.dart';
import 'package:forge/domain/use_cases/update_planned_activity.dart';

import '../data/workout_test_helpers.dart' show insertProfilo;

/// Fondamenta del Piano Settimanale (Milestone 8.1, sezione 31): nessuna
/// classificazione temporale testata qui — solo la coerenza tipo/scheda.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository repository;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftPlannedActivityRepository(db.attivitaPianificateDao);
    profileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  PlannedActivity activity({
    int? profileIdOverride,
    DateTime? scheduledDate,
    PlannedActivityType type = PlannedActivityType.recovery,
    int? workoutId,
  }) {
    return PlannedActivity(
      profileId: profileIdOverride ?? profileId,
      scheduledDate: scheduledDate ?? DateTime(2026, 9, 1),
      type: type,
      workoutId: workoutId,
      origin: PlannedActivityOrigin.user,
    );
  }

  group('AddPlannedActivity', () {
    test('RECOVERY senza scheda -> creata', () async {
      final id = await AddPlannedActivity(repository)(activity());
      final saved = await repository.getById(id);
      expect(saved, isNotNull);
      expect(saved!.type, PlannedActivityType.recovery);
      expect(saved.workoutId, isNull);
    });

    test('WORKOUT senza workoutId -> invalida', () async {
      expect(
        () => AddPlannedActivity(repository)(
          activity(type: PlannedActivityType.workout),
        ),
        throwsArgumentError,
      );
    });

    test('WORKOUT con workoutId -> creata', () async {
      final workoutId = await DriftWorkoutRepository(db).createWorkout(
        Workout(
          profileId: profileId,
          name: 'Scheda gambe',
          type: WorkoutType.lowerBody,
          level: 1,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
        ),
      );
      final id = await AddPlannedActivity(repository)(
        activity(type: PlannedActivityType.workout, workoutId: workoutId),
      );
      final saved = await repository.getById(id);
      expect(saved!.workoutId, workoutId);
    });

    test('WALK con workoutId -> invalida (solo WORKOUT può referenziare una '
        'scheda)', () async {
      expect(
        () => AddPlannedActivity(repository)(
          activity(type: PlannedActivityType.walk, workoutId: 1),
        ),
        throwsArgumentError,
      );
    });

    test('RECOVERY con workoutId -> invalida', () async {
      expect(
        () => AddPlannedActivity(repository)(
          activity(type: PlannedActivityType.recovery, workoutId: 1),
        ),
        throwsArgumentError,
      );
    });

    test('profilo non valido -> invalida', () async {
      expect(
        () => AddPlannedActivity(repository)(activity(profileIdOverride: 0)),
        throwsArgumentError,
      );
    });

    test('WALK senza workoutId -> creata', () async {
      final id = await AddPlannedActivity(repository)(
        activity(type: PlannedActivityType.walk),
      );
      final saved = await repository.getById(id);
      expect(saved!.type, PlannedActivityType.walk);
      expect(saved.workoutId, isNull);
    });
  });

  group('UpdatePlannedActivity', () {
    test('stessa validazione di add', () async {
      final id = await AddPlannedActivity(repository)(activity());
      final saved = (await repository.getById(id))!;

      expect(
        () => UpdatePlannedActivity(repository)(
          saved.copyWith(type: PlannedActivityType.workout),
        ),
        throwsArgumentError,
      );
    });
  });

  group('type safety collegamento sessione (Milestone 8.5, sezione 41)', () {
    test('workoutSessionId su un\'attività non WORKOUT è invalido', () {
      expect(
        () => AddPlannedActivity(repository)(
          activity(
            type: PlannedActivityType.walk,
          ).copyWith(workoutSessionId: () => 1),
        ),
        throwsArgumentError,
      );
    });

    test('walkingSessionId su un\'attività non WALK è invalido', () {
      expect(
        () => AddPlannedActivity(repository)(
          activity().copyWith(walkingSessionId: () => 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('vincoli di modifica con sessione già collegata (Milestone 8.5, '
      'sezione 30-32)', () {
    Future<int> createRealWorkoutSession(int workoutId) async {
      final details = await DriftWorkoutRepository(
        db,
      ).getWorkoutDetails(workoutId);
      return DriftWorkoutSessionRepository(db).createSession(
        profileId: profileId,
        details: details!,
        startedAt: DateTime(2026, 9, 7, 8),
      );
    }

    test('non si può cambiare il tipo di un\'attività già collegata a '
        'una sessione', () async {
      final workoutId = await DriftWorkoutRepository(db).createWorkout(
        Workout(
          profileId: profileId,
          name: 'Scheda gambe',
          type: WorkoutType.lowerBody,
          level: 1,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
        ),
      );
      final id = await AddPlannedActivity(repository)(
        activity(type: PlannedActivityType.workout, workoutId: workoutId),
      );
      final sessionId = await createRealWorkoutSession(workoutId);
      await repository.linkWorkoutSession(
        activityId: id,
        workoutSessionId: sessionId,
      );
      final linked = (await repository.getById(id))!;

      expect(
        () => UpdatePlannedActivity(repository)(
          linked.copyWith(
            type: PlannedActivityType.recovery,
            workoutId: () => null,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('non si può cambiare la scheda di un\'attività già collegata a '
        'una sessione', () async {
      final workoutRepo = DriftWorkoutRepository(db);
      final workoutIdA = await workoutRepo.createWorkout(
        Workout(
          profileId: profileId,
          name: 'Scheda A',
          type: WorkoutType.lowerBody,
          level: 1,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
        ),
      );
      final workoutIdB = await workoutRepo.createWorkout(
        Workout(
          profileId: profileId,
          name: 'Scheda B',
          type: WorkoutType.lowerBody,
          level: 1,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
        ),
      );
      final id = await AddPlannedActivity(repository)(
        activity(type: PlannedActivityType.workout, workoutId: workoutIdA),
      );
      final sessionId = await createRealWorkoutSession(workoutIdA);
      await repository.linkWorkoutSession(
        activityId: id,
        workoutSessionId: sessionId,
      );
      final linked = (await repository.getById(id))!;

      expect(
        () => UpdatePlannedActivity(repository)(
          linked.copyWith(workoutId: () => workoutIdB),
        ),
        throwsArgumentError,
      );
    });

    test('scheduledDate resta modificabile anche con una sessione '
        'collegata', () async {
      final workoutId = await DriftWorkoutRepository(db).createWorkout(
        Workout(
          profileId: profileId,
          name: 'Scheda gambe',
          type: WorkoutType.lowerBody,
          level: 1,
          status: WorkoutDefinitionStatus.ready,
          origin: WorkoutOrigin.user,
        ),
      );
      final id = await AddPlannedActivity(repository)(
        activity(type: PlannedActivityType.workout, workoutId: workoutId),
      );
      final sessionId = await createRealWorkoutSession(workoutId);
      await repository.linkWorkoutSession(
        activityId: id,
        workoutSessionId: sessionId,
      );
      final linked = (await repository.getById(id))!;

      await UpdatePlannedActivity(repository)(
        linked.copyWith(scheduledDate: DateTime(2026, 9, 8)),
      );
      final updated = (await repository.getById(id))!;
      expect(updated.scheduledDate, DateTime(2026, 9, 8));
    });
  });
}
