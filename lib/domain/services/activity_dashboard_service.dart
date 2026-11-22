import '../entities/body_measurement.dart';
import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../entities/walking_session.dart';
import '../entities/walking_session_status.dart';
import '../entities/workout_session_history_item.dart';
import '../entities/workout_session_persistence_status.dart';
import 'weekly_planning_date_service.dart';

enum ActivityDashboardPeriod { week, month }

class ActivityPeriodSummary {
  const ActivityPeriodSummary({
    required this.workouts,
    required this.workoutSeconds,
    required this.walks,
    required this.walkSeconds,
    required this.steps,
    required this.meters,
    required this.plannedWorkouts,
    required this.completedPlannedWorkouts,
    required this.plannedWalks,
    required this.completedPlannedWalks,
    required this.weightChange,
  });
  final int workouts,
      workoutSeconds,
      walks,
      walkSeconds,
      plannedWorkouts,
      completedPlannedWorkouts,
      plannedWalks,
      completedPlannedWalks;
  final int? steps, meters;
  final double? weightChange;
}

class ActivityDashboardSummary {
  const ActivityDashboardSummary({
    required this.start,
    required this.end,
    required this.previousStart,
    required this.current,
    required this.previous,
  });
  final DateTime start, end, previousStart;
  final ActivityPeriodSummary current, previous;
}

abstract final class ActivityDashboardService {
  static ActivityDashboardSummary compute({
    required DateTime now,
    required ActivityDashboardPeriod period,
    required List<WorkoutSessionHistoryItem> workouts,
    required List<WalkingSession> walks,
    required List<PlannedActivity> planned,
    required List<BodyMeasurement> weights,
    Map<int, ({bool planned, int? walkingSessionId})> includedWalks = const {},
  }) {
    final start = period == ActivityDashboardPeriod.week
        ? WeeklyPlanningDateService.weekStart(now)
        : DateTime(now.year, now.month);
    final end = period == ActivityDashboardPeriod.week
        ? DateTime(start.year, start.month, start.day + 7)
        : DateTime(now.year, now.month + 1);
    final previousStart = period == ActivityDashboardPeriod.week
        ? DateTime(start.year, start.month, start.day - 7)
        : DateTime(now.year, now.month - 1);
    ActivityPeriodSummary summarize(DateTime from, DateTime until) {
      bool inside(DateTime d) => !d.isBefore(from) && d.isBefore(until);
      final completed = workouts
          .where((s) => s.status == WorkoutSessionPersistenceStatus.completed)
          .toList();
      final finishedWalks = walks
          .where((s) => s.status == WalkingSessionStatus.completed)
          .toList();
      final selectedWorkouts = completed
          .where((s) => inside(s.startedAt))
          .toList();
      final selectedWalks = finishedWalks
          .where((s) => inside(s.startedAt))
          .toList();
      final plannedWorkouts = planned
          .where(
            (a) =>
                inside(a.scheduledDate) &&
                a.status == PlannedActivityStatus.planned &&
                a.type == PlannedActivityType.workout,
          )
          .toList();
      final plannedWalks = planned
          .where(
            (a) =>
                inside(a.scheduledDate) &&
                a.status == PlannedActivityStatus.planned &&
                a.type == PlannedActivityType.walk,
          )
          .toList();
      final combinedWalks = plannedWorkouts
          .where((a) => includedWalks[a.id]?.planned == true)
          .toList();
      final workoutIds = completed.map((s) => s.sessionId).toSet();
      final walkIds = finishedWalks.map((s) => s.id).toSet();
      int? totalKnown(Iterable<int?> values) {
        final known = values.whereType<int>().toList();
        return known.isEmpty ? null : known.fold<int>(0, (sum, n) => sum + n);
      }

      final selectedWeights =
          weights
              .where((w) => inside(w.measuredAt) && w.weightKg != null)
              .toList()
            ..sort((a, b) {
              final date = a.measuredAt.compareTo(b.measuredAt);
              return date != 0 ? date : (a.id ?? 0).compareTo(b.id ?? 0);
            });
      return ActivityPeriodSummary(
        workouts: selectedWorkouts.length,
        workoutSeconds: selectedWorkouts.fold(
          0,
          (sum, s) =>
              sum +
              (s.finishedAt == null
                  ? 0
                  : s.finishedAt!
                        .difference(s.startedAt)
                        .inSeconds
                        .clamp(0, 1 << 53)),
        ),
        walks: selectedWalks.length,
        walkSeconds: selectedWalks.fold(
          0,
          (sum, s) =>
              sum +
              (s.endedAt == null ? 0 : s.activeDuration(s.endedAt!).inSeconds),
        ),
        steps: totalKnown(selectedWalks.map((s) => s.steps)),
        meters: totalKnown(selectedWalks.map((s) => s.distanceMeters)),
        plannedWorkouts: plannedWorkouts.length,
        completedPlannedWorkouts: plannedWorkouts
            .where((a) => workoutIds.contains(a.workoutSessionId))
            .length,
        plannedWalks: plannedWalks.length + combinedWalks.length,
        completedPlannedWalks:
            combinedWalks
                .where(
                  (a) =>
                      walkIds.contains(includedWalks[a.id]?.walkingSessionId),
                )
                .length +
            plannedWalks
                .where((a) => walkIds.contains(a.walkingSessionId))
                .length,
        weightChange: selectedWeights.length < 2
            ? null
            : selectedWeights.last.weightKg! - selectedWeights.first.weightKg!,
      );
    }

    return ActivityDashboardSummary(
      start: start,
      end: end,
      previousStart: previousStart,
      current: summarize(start, end),
      previous: summarize(previousStart, start),
    );
  }
}
