import 'walking_activity_point.dart';
import 'walking_statistics_period.dart';

/// Statistiche aggregate calcolate esclusivamente da camminate persistite.
class WalkingStatistics {
  const WalkingStatistics({
    required this.period,
    required this.totalSessions,
    required this.completedSessions,
    required this.abortedSessions,
    required this.totalActiveDuration,
    required this.totalChronologicalDuration,
    required this.totalPauseDuration,
    required this.totalDistanceMeters,
    required this.totalSteps,
    required this.sessionsWithDistance,
    required this.sessionsWithSteps,
    required this.averageActiveDuration,
    required this.averageDistanceMeters,
    required this.averageSteps,
    required this.activeDays,
    required this.averageSessionsPerWeek,
    required this.activity,
  });

  final WalkingStatisticsPeriod period;
  final int totalSessions;
  final int completedSessions;
  final int abortedSessions;
  final Duration totalActiveDuration;
  final Duration totalChronologicalDuration;
  final Duration totalPauseDuration;
  final int? totalDistanceMeters;
  final int? totalSteps;
  final int sessionsWithDistance;
  final int sessionsWithSteps;
  final Duration? averageActiveDuration;
  final int? averageDistanceMeters;
  final int? averageSteps;
  final int activeDays;
  final double averageSessionsPerWeek;
  final List<WalkingActivityPoint> activity;
}
