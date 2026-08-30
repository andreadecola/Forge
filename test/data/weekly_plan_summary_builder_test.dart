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
import 'package:forge/domain/use_cases/link_workout_session.dart';
import 'package:forge/domain/use_cases/restore_planned_activity.dart';
import 'package:forge/domain/use_cases/skip_planned_activity.dart';
import 'package:forge/domain/use_cases/update_planned_activity.dart';
import 'package:forge/features/weekly_plan/application/weekly_plan_summary_builder.dart';

import '../data/workout_test_helpers.dart';

/// Test di [WeeklyPlanSummaryBuilder] (Milestone 8.7) con repository e DB
/// reali: orchestrazione I/O (risoluzione stato sessione) + calcolo,
/// scenari che il servizio puro da solo non può coprire — sessioni
/// spontanee, isolamento profilo/settimana, completamento/abbandono reale,
/// impatto di sposta/salta/ripristina.
void main() {
  late AppDatabase db;
  late DriftPlannedActivityRepository plannedActivityRepository;
  late DriftWorkoutSessionRepository workoutSessionRepository;
  late DriftWalkingSessionRepository walkingSessionRepository;
  late WeeklyPlanSummaryBuilder builder;
  late int profileId;
  late int workoutId;
  final today = DateTime(2026, 9, 9); // mercoledì

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    plannedActivityRepository = DriftPlannedActivityRepository(
      db.attivitaPianificateDao,
    );
    workoutSessionRepository = DriftWorkoutSessionRepository(db);
    walkingSessionRepository = DriftWalkingSessionRepository(db);
    builder = WeeklyPlanSummaryBuilder.withRepositories(
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

  Future<int> plannedWorkout(DateTime scheduledDate) {
    return AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: scheduledDate,
        type: PlannedActivityType.workout,
        workoutId: workoutId,
        origin: PlannedActivityOrigin.user,
      ),
    );
  }

  test('nessuna attività -> summary vuoto', () async {
    final summary = await builder.build(activities: const [], today: today);
    expect(summary.total, 0);
  });

  test('sessione Workout completata reale -> completed incrementa', () async {
    final id = await plannedWorkout(DateTime(2026, 9, 7));
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
    activity = (await plannedActivityRepository.getById(id))!;

    final summary = await builder.build(activities: [activity], today: today);

    expect(summary.completed, 1);
    expect(summary.matureCompleted, 1);
  });

  test(
    'sessione Workout abbandonata reale -> non completata, resta da fare',
    () async {
      final id = await plannedWorkout(DateTime(2026, 9, 7));
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
      activity = (await plannedActivityRepository.getById(id))!;

      final summary = await builder.build(activities: [activity], today: today);

      expect(summary.completed, 0);
      expect(summary.plannedRemaining, 1);
    },
  );

  test(
    'sessione Walk spontanea (senza PlannedActivity) non entra nel summary',
    () async {
      // Nessuna PlannedActivity creata per questa sessione: il builder
      // riceve sempre e solo un elenco di PlannedActivity, mai una query
      // diretta sulle sessioni — la sessione spontanea non può comparire
      // per costruzione.
      await walkingSessionRepository.createWalkingSession(
        WalkingSession(
          profileId: profileId,
          startedAt: DateTime(2026, 9, 7, 8),
          status: WalkingSessionStatus.inProgress,
        ),
      );

      final summary = await builder.build(activities: const [], today: today);

      expect(summary.total, 0);
    },
  );

  test(
    'isolamento profilo: getForWeek di un profilo non include l\'altro',
    () async {
      final otherProfileId = await insertProfilo(db);
      await plannedWorkout(DateTime(2026, 9, 7));
      await AddPlannedActivity(plannedActivityRepository)(
        PlannedActivity(
          profileId: otherProfileId,
          scheduledDate: DateTime(2026, 9, 7),
          type: PlannedActivityType.recovery,
          origin: PlannedActivityOrigin.user,
        ),
      );

      final activitiesForProfile = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: DateTime(2026, 9, 7),
        weekEnd: DateTime(2026, 9, 13),
      );
      final summary = await builder.build(
        activities: activitiesForProfile,
        today: today,
      );

      expect(summary.total, 1);
      expect(summary.workoutCount, 1);
    },
  );

  test(
    'isolamento settimana: getForWeek di una settimana non include l\'altra',
    () async {
      await plannedWorkout(DateTime(2026, 9, 7));
      await plannedWorkout(DateTime(2026, 9, 14));

      final activitiesForWeek = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: DateTime(2026, 9, 7),
        weekEnd: DateTime(2026, 9, 13),
      );
      final summary = await builder.build(
        activities: activitiesForWeek,
        today: today,
      );

      expect(summary.total, 1);
    },
  );

  test('Salta poi Ripristina: il summary riflette lo stato corrente ad ogni '
      'passo', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );

    final beforeSkip = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 7),
      weekEnd: DateTime(2026, 9, 13),
    );
    final summaryBefore = await builder.build(
      activities: beforeSkip,
      today: today,
    );
    expect(summaryBefore.plannedRemaining, 1);
    expect(summaryBefore.skipped, 0);

    await SkipPlannedActivity(
      plannedActivityRepository,
      workoutSessionRepository,
      walkingSessionRepository,
    )(id);
    final afterSkip = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 7),
      weekEnd: DateTime(2026, 9, 13),
    );
    final summaryAfterSkip = await builder.build(
      activities: afterSkip,
      today: today,
    );
    expect(summaryAfterSkip.skipped, 1);
    expect(summaryAfterSkip.plannedRemaining, 0);

    await RestorePlannedActivity(plannedActivityRepository)(id);
    final afterRestore = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 7),
      weekEnd: DateTime(2026, 9, 13),
    );
    final summaryAfterRestore = await builder.build(
      activities: afterRestore,
      today: today,
    );
    expect(summaryAfterRestore.skipped, 0);
    expect(summaryAfterRestore.plannedRemaining, 1);
  });

  test('Sposta fuori settimana: scompare dalla settimana vecchia, compare '
      'nella nuova', () async {
    final id = await AddPlannedActivity(plannedActivityRepository)(
      PlannedActivity(
        profileId: profileId,
        scheduledDate: DateTime(2026, 9, 7),
        type: PlannedActivityType.recovery,
        origin: PlannedActivityOrigin.user,
      ),
    );
    final activity = (await plannedActivityRepository.getById(id))!;
    await UpdatePlannedActivity(plannedActivityRepository)(
      activity.copyWith(scheduledDate: DateTime(2026, 9, 14)),
    );

    final oldWeek = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 7),
      weekEnd: DateTime(2026, 9, 13),
    );
    final newWeek = await plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: DateTime(2026, 9, 14),
      weekEnd: DateTime(2026, 9, 20),
    );

    final summaryOldWeek = await builder.build(
      activities: oldWeek,
      today: today,
    );
    final summaryNewWeek = await builder.build(
      activities: newWeek,
      today: today,
    );

    expect(summaryOldWeek.total, 0);
    expect(summaryNewWeek.total, 1);
  });
}
