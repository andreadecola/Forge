import '../../../domain/entities/workout_statistics_period.dart';

/// Traduzioni italiane per le statistiche allenamenti (Milestone 4.5.2).
abstract final class WorkoutStatisticsLabels {
  static String period(WorkoutStatisticsPeriod period) {
    switch (period) {
      case WorkoutStatisticsPeriod.last7Days:
        return '7 giorni';
      case WorkoutStatisticsPeriod.last30Days:
        return '30 giorni';
      case WorkoutStatisticsPeriod.last90Days:
        return '90 giorni';
      case WorkoutStatisticsPeriod.allTime:
        return 'Tutto';
    }
  }
}
