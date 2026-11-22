import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/workout_session_history_item.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/services/activity_dashboard_service.dart';

void main() {
  final monday = DateTime(2026, 11, 23);
  WorkoutSessionHistoryItem workout(
    int id,
    DateTime date, {
    bool completed = true,
  }) => WorkoutSessionHistoryItem(
    sessionId: id,
    workoutId: 1,
    profileId: 1,
    workoutName: 'Test',
    status: completed
        ? WorkoutSessionPersistenceStatus.completed
        : WorkoutSessionPersistenceStatus.aborted,
    startedAt: date,
    finishedAt: date.add(const Duration(minutes: 20)),
    totalExercises: 1,
    completedExercises: 1,
    skippedExercises: 0,
    totalSetsCompleted: 3,
    totalPlannedSets: 3,
  );
  test(
    'settimana: totali corretti, pause camminate escluse, link espliciti e confronto',
    () {
      final result = ActivityDashboardService.compute(
        now: monday,
        period: ActivityDashboardPeriod.week,
        workouts: [
          workout(1, monday),
          workout(2, monday, completed: false),
          workout(3, monday.subtract(const Duration(days: 1))),
        ],
        walks: [
          WalkingSession(
            id: 1,
            profileId: 1,
            startedAt: monday,
            endedAt: monday.add(const Duration(minutes: 30)),
            accumulatedPauseSeconds: 300,
            status: WalkingSessionStatus.completed,
            steps: 1500,
            distanceMeters: 900,
          ),
          WalkingSession(
            id: 2,
            profileId: 1,
            startedAt: monday,
            endedAt: monday.add(const Duration(minutes: 10)),
            status: WalkingSessionStatus.completed,
          ),
          WalkingSession(
            id: 3,
            profileId: 1,
            startedAt: monday,
            endedAt: monday.add(const Duration(minutes: 10)),
            status: WalkingSessionStatus.aborted,
            steps: 99999,
          ),
        ],
        planned: [
          PlannedActivity(
            profileId: 1,
            scheduledDate: monday,
            type: PlannedActivityType.workout,
            workoutId: 1,
            workoutSessionId: 1,
            origin: PlannedActivityOrigin.user,
          ),
          PlannedActivity(
            profileId: 1,
            scheduledDate: monday,
            type: PlannedActivityType.workout,
            workoutId: 1,
            origin: PlannedActivityOrigin.user,
          ),
          PlannedActivity(
            profileId: 1,
            scheduledDate: monday,
            type: PlannedActivityType.workout,
            workoutId: 1,
            origin: PlannedActivityOrigin.user,
            status: PlannedActivityStatus.skipped,
          ),
          PlannedActivity(
            profileId: 1,
            scheduledDate: monday,
            type: PlannedActivityType.walk,
            walkingSessionId: 1,
            origin: PlannedActivityOrigin.forgeEngine,
          ),
        ],
        weights: [
          BodyMeasurement(
            id: 1,
            profileId: 1,
            measuredAt: monday,
            weightKg: 100,
          ),
          BodyMeasurement(
            id: 2,
            profileId: 1,
            measuredAt: monday.add(const Duration(days: 1)),
            weightKg: 99.5,
          ),
          BodyMeasurement(
            profileId: 1,
            measuredAt: monday.add(const Duration(days: 2)),
            waistCm: 90,
          ),
        ],
      );
      expect(result.current.workouts, 1);
      expect(result.previous.workouts, 1);
      expect(result.current.workoutSeconds, 1200);
      expect(result.current.walkSeconds, 2100);
      expect(result.current.walks, 2);
      expect(result.current.steps, 1500);
      expect(result.current.meters, 900);
      expect(result.current.plannedWorkouts, 2);
      expect(result.current.completedPlannedWorkouts, 1);
      expect(result.current.completedPlannedWalks, 1);
      expect(result.current.weightChange, -.5);
    },
  );
  test(
    'mese: confini calendario e assenza dati non diventano misurazioni zero',
    () {
      final result = ActivityDashboardService.compute(
        now: DateTime(2026, 1, 10),
        period: ActivityDashboardPeriod.month,
        workouts: [
          workout(1, DateTime(2025, 12, 31)),
          workout(2, DateTime(2026, 1, 31)),
          workout(3, DateTime(2026, 2, 1)),
        ],
        walks: [],
        planned: [],
        weights: [
          BodyMeasurement(
            profileId: 1,
            measuredAt: DateTime(2026, 1, 2),
            weightKg: 100,
          ),
        ],
      );
      expect(result.start, DateTime(2026, 1));
      expect(result.end, DateTime(2026, 2));
      expect(result.previousStart, DateTime(2025, 12));
      expect(result.current.workouts, 1);
      expect(result.previous.workouts, 1);
      expect(result.current.steps, isNull);
      expect(result.current.meters, isNull);
      expect(result.current.weightChange, isNull);
    },
  );
  test('zero passi registrati resta zero, diverso da dato mancante', () {
    final result = ActivityDashboardService.compute(
      now: monday,
      period: ActivityDashboardPeriod.week,
      workouts: [],
      planned: [],
      weights: [],
      walks: [
        WalkingSession(
          profileId: 1,
          startedAt: monday,
          endedAt: monday,
          status: WalkingSessionStatus.completed,
          steps: 0,
          distanceMeters: 0,
        ),
      ],
    );
    expect(result.current.steps, 0);
    expect(result.current.meters, 0);
  });
  test(
    'camminata interna: una sola scheda e conteggi collegati alla camminata reale',
    () {
      final result = ActivityDashboardService.compute(
        now: monday,
        period: ActivityDashboardPeriod.week,
        workouts: [],
        weights: [],
        planned: [
          PlannedActivity(
            id: 10,
            profileId: 1,
            scheduledDate: monday,
            type: PlannedActivityType.workout,
            workoutId: 1,
            origin: PlannedActivityOrigin.user,
          ),
        ],
        walks: [
          WalkingSession(
            id: 42,
            profileId: 1,
            startedAt: monday,
            endedAt: monday.add(const Duration(minutes: 15)),
            status: WalkingSessionStatus.completed,
            steps: 1000,
          ),
        ],
        includedWalks: {10: (planned: true, walkingSessionId: 42)},
      );
      expect(result.current.plannedWorkouts, 1);
      expect(result.current.completedPlannedWorkouts, 0);
      expect(result.current.plannedWalks, 1);
      expect(result.current.completedPlannedWalks, 1);
      expect(result.current.walks, 1);
      expect(result.current.steps, 1000);
    },
  );
}
