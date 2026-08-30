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
import 'package:forge/domain/services/weekly_planning_date_service.dart';

import 'workout_test_helpers.dart';

/// Fondamenta del Piano Settimanale (Milestone 8.1, sezioni 70-74): CRUD,
/// isolamento profilo/settimana, riferimento a `Workout` senza duplicarlo,
/// WALK/RECOVERY senza creare alcuna sessione reale.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository repository;
  late int profileId;
  late int otherProfileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftPlannedActivityRepository(db.attivitaPianificateDao);
    profileId = await insertProfilo(db);
    otherProfileId = await insertProfilo(db);
  });

  tearDown(() => db.close());

  PlannedActivity activity({
    int? id,
    int? profileIdOverride,
    required DateTime scheduledDate,
    PlannedActivityType type = PlannedActivityType.recovery,
    int? workoutId,
    int? plannedDurationMinutes,
    String? notes,
  }) {
    return PlannedActivity(
      id: id,
      profileId: profileIdOverride ?? profileId,
      scheduledDate: scheduledDate,
      type: type,
      workoutId: workoutId,
      plannedDurationMinutes: plannedDurationMinutes,
      origin: PlannedActivityOrigin.user,
      notes: notes,
    );
  }

  test(
    'create -> getById restituisce la stessa attività (mapping fedele)',
    (() async {
      final id = await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.walk,
          plannedDurationMinutes: 30,
          notes: 'camminata leggera',
        ),
      );
      final saved = await repository.getById(id);

      expect(saved, isNotNull);
      expect(saved!.profileId, profileId);
      expect(saved.scheduledDate, DateTime(2026, 9, 1));
      expect(saved.type, PlannedActivityType.walk);
      expect(saved.plannedDurationMinutes, 30);
      expect(saved.notes, 'camminata leggera');
      expect(saved.origin, PlannedActivityOrigin.user);
    }),
  );

  test('getById su id inesistente -> null', () async {
    expect(await repository.getById(999999), isNull);
  });

  test('update mantiene lo stesso id, nessuna riga duplicata', () async {
    final id = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );
    final original = (await repository.getById(id))!;

    await repository.updatePlannedActivity(
      original.copyWith(
        scheduledDate: DateTime(2026, 9, 3),
        notes: () => 'aggiornata',
      ),
    );

    final updated = await repository.getById(id);
    expect(updated!.id, id);
    expect(updated.scheduledDate, DateTime(2026, 9, 3));
    expect(updated.notes, 'aggiornata');

    final all = await repository.getForWeek(
      profileId: profileId,
      weekStart: WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 1)),
      weekEnd: WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1)),
    );
    expect(all, hasLength(1));
  });

  test('delete rimuove la riga', () async {
    final id = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );
    await repository.deletePlannedActivity(id);
    expect(await repository.getById(id), isNull);
  });

  test('watchForWeek emette su create/update/delete', () async {
    final weekStart = WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 1));
    final weekEnd = WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1));
    final emissions = <int>[];
    final subscription = repository
        .watchForWeek(
          profileId: profileId,
          weekStart: weekStart,
          weekEnd: weekEnd,
        )
        .listen((rows) => emissions.add(rows.length));

    await Future<void>.delayed(Duration.zero);
    final id = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );
    await Future<void>.delayed(Duration.zero);
    await repository.updatePlannedActivity(
      (await repository.getById(id))!.copyWith(notes: () => 'nota'),
    );
    await Future<void>.delayed(Duration.zero);
    await repository.deletePlannedActivity(id);
    await Future<void>.delayed(Duration.zero);

    await subscription.cancel();
    expect(emissions, [0, 1, 1, 0]);
  });

  test('isolamento per profilo: le attività di un profilo non compaiono '
      'nell\'altro', () async {
    await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );
    await repository.addPlannedActivity(
      activity(
        profileIdOverride: otherProfileId,
        scheduledDate: DateTime(2026, 9, 1),
      ),
    );

    final weekStart = WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 1));
    final weekEnd = WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1));
    final mine = await repository.getForWeek(
      profileId: profileId,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );
    expect(mine, hasLength(1));
    expect(mine.single.profileId, profileId);
  });

  test(
    'isolamento per settimana: un\'attività fuori range non compare',
    () async {
      await repository.addPlannedActivity(
        activity(scheduledDate: DateTime(2026, 9, 1)), // dentro la settimana
      );
      await repository.addPlannedActivity(
        activity(scheduledDate: DateTime(2026, 9, 10)), // settimana successiva
      );

      final weekStart = WeeklyPlanningDateService.weekStart(
        DateTime(2026, 9, 1),
      );
      final weekEnd = WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1));
      final result = await repository.getForWeek(
        profileId: profileId,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );
      expect(result, hasLength(1));
      expect(result.single.scheduledDate, DateTime(2026, 9, 1));
    },
  );

  test(
    'più attività nello stesso giorno sono consentite (WORKOUT + WALK)',
    (() async {
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
      await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        ),
      );
      await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.walk,
        ),
      );

      final result = await repository.getForWeek(
        profileId: profileId,
        weekStart: WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 1)),
        weekEnd: WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1)),
      );
      expect(result, hasLength(2));
      expect(
        result.map((a) => a.type),
        containsAll([PlannedActivityType.workout, PlannedActivityType.walk]),
      );
    }),
  );

  test('ordinamento: scheduledDate ASC con tie-break su id ASC', () async {
    final second = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 2)),
    );
    final firstSameDay = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );
    final secondSameDay = await repository.addPlannedActivity(
      activity(scheduledDate: DateTime(2026, 9, 1)),
    );

    final result = await repository.getForWeek(
      profileId: profileId,
      weekStart: WeeklyPlanningDateService.weekStart(DateTime(2026, 9, 1)),
      weekEnd: WeeklyPlanningDateService.weekEnd(DateTime(2026, 9, 1)),
    );

    expect(result.map((a) => a.id), [firstSameDay, secondSameDay, second]);
  });

  test('WORKOUT referenzia la scheda senza duplicarla; delete non elimina '
      'il Workout', () async {
    final workoutRepository = DriftWorkoutRepository(db);
    final workoutId = await workoutRepository.createWorkout(
      Workout(
        profileId: profileId,
        name: 'Scheda gambe',
        type: WorkoutType.lowerBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    final activityId = await repository.addPlannedActivity(
      activity(
        scheduledDate: DateTime(2026, 9, 1),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      ),
    );

    await repository.deletePlannedActivity(activityId);

    final workout = await workoutRepository.getWorkoutById(workoutId);
    expect(
      workout,
      isNotNull,
      reason: 'il Workout referenziato deve sopravvivere',
    );
  });

  test('WORKOUT: eliminare la scheda referenziata non blocca né elimina '
      'l\'attività pianificata (ON DELETE SET NULL)', () async {
    final workoutRepository = DriftWorkoutRepository(db);
    final workoutId = await workoutRepository.createWorkout(
      Workout(
        profileId: profileId,
        name: 'Scheda gambe',
        type: WorkoutType.lowerBody,
        level: 1,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    final activityId = await repository.addPlannedActivity(
      activity(
        scheduledDate: DateTime(2026, 9, 1),
        type: PlannedActivityType.workout,
        workoutId: workoutId,
      ),
    );

    await workoutRepository.deleteWorkout(workoutId);

    final survived = await repository.getById(activityId);
    expect(survived, isNotNull);
    expect(survived!.workoutId, isNull);
  });

  test('WALK pianificata non crea alcuna WalkingSession', () async {
    await repository.addPlannedActivity(
      activity(
        scheduledDate: DateTime(2026, 9, 1),
        type: PlannedActivityType.walk,
        plannedDurationMinutes: 20,
      ),
    );

    final walkingSessions = await db.camminateDao.getByProfile(profileId);
    expect(walkingSessions, isEmpty);
  });

  test(
    'RECOVERY pianificata non crea alcun Workout né WalkingSession',
    (() async {
      await repository.addPlannedActivity(
        activity(scheduledDate: DateTime(2026, 9, 1)),
      );

      final workouts = await DriftWorkoutRepository(
        db,
      ).getWorkouts(profileId: profileId);
      final walkingSessions = await db.camminateDao.getByProfile(profileId);
      expect(workouts, isEmpty);
      expect(walkingSessions, isEmpty);
    }),
  );

  group('collegamento sessione (Milestone 8.5, sezione 49/50)', () {
    Future<int> createWorkoutWithSession() async {
      final categoryId = await insertCategoria(db);
      final exerciseId = await insertEsercizio(
        db,
        codice: 'A-001',
        idCategoria: categoryId,
        defaultReps: 10,
      );
      final workoutId = await DriftWorkoutRepository(db)
          .createWorkoutWithExercises(
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
      return workoutId;
    }

    test('linkWorkoutSession persiste il collegamento', () async {
      final workoutId = await createWorkoutWithSession();
      final activityId = await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        ),
      );
      final details = await DriftWorkoutRepository(
        db,
      ).getWorkoutDetails(workoutId);
      final sessionId = await DriftWorkoutSessionRepository(db).createSession(
        profileId: profileId,
        details: details!,
        startedAt: DateTime(2026, 9, 1, 8),
      );

      await repository.linkWorkoutSession(
        activityId: activityId,
        workoutSessionId: sessionId,
      );

      final saved = await repository.getById(activityId);
      expect(saved!.workoutSessionId, sessionId);
    });

    test('linkWorkoutSession sovrascrive un collegamento precedente '
        '(riavvio dopo abort)', () async {
      final workoutId = await createWorkoutWithSession();
      final activityId = await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.workout,
          workoutId: workoutId,
        ),
      );
      final workoutSessionRepository = DriftWorkoutSessionRepository(db);
      final details = await DriftWorkoutRepository(
        db,
      ).getWorkoutDetails(workoutId);
      final firstSessionId = await workoutSessionRepository.createSession(
        profileId: profileId,
        details: details!,
        startedAt: DateTime(2026, 9, 1, 8),
      );
      await repository.linkWorkoutSession(
        activityId: activityId,
        workoutSessionId: firstSessionId,
      );
      await workoutSessionRepository.abortSession(
        sessionId: firstSessionId,
        endedAt: DateTime(2026, 9, 1, 8, 30),
      );
      final secondSessionId = await workoutSessionRepository.createSession(
        profileId: profileId,
        details: details,
        startedAt: DateTime(2026, 9, 1, 9),
      );

      await repository.linkWorkoutSession(
        activityId: activityId,
        workoutSessionId: secondSessionId,
      );

      final saved = await repository.getById(activityId);
      expect(saved!.workoutSessionId, secondSessionId);
    });

    test('linkWalkingSession persiste il collegamento', () async {
      final activityId = await repository.addPlannedActivity(
        activity(
          scheduledDate: DateTime(2026, 9, 1),
          type: PlannedActivityType.walk,
        ),
      );
      final walkingSessionRepository = DriftWalkingSessionRepository(db);
      final sessionId = await walkingSessionRepository.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: DateTime(2026, 9, 1, 8),
          status: WalkingSessionStatus.inProgress,
        ),
      );

      await repository.linkWalkingSession(
        activityId: activityId,
        walkingSessionId: sessionId,
      );

      final saved = await repository.getById(activityId);
      expect(saved!.walkingSessionId, sessionId);
    });
  });
}
