import 'workout_activity_point.dart';
import 'workout_statistics_period.dart';

/// Statistiche aggregate per un periodo (Milestone 4.5.2), calcolate
/// esclusivamente da dati realmente persistiti — nessuna metrica
/// inventata (sezione 2): niente calorie, carico, tonnellaggio, 1RM,
/// tempo attivo preciso.
class WorkoutStatistics {
  const WorkoutStatistics({
    required this.period,
    required this.totalSessions,
    required this.completedSessions,
    required this.abortedSessions,
    required this.completionRate,
    required this.totalExercisesCompleted,
    required this.totalExercisesSkipped,
    required this.totalSetsCompleted,
    required this.totalPlannedSets,
    this.setCompletionRate,
    required this.totalDuration,
    this.averageDuration,
    required this.activeDays,
    required this.averageSessionsPerWeek,
    required this.activity,
  });

  final WorkoutStatisticsPeriod period;

  /// COMPLETED + ABORTED nel periodo (sezione 9).
  final int totalSessions;
  final int completedSessions;
  final int abortedSessions;

  /// `completedSessions / totalSessions`, `0` se [totalSessions] è `0`
  /// (sezione 12: mai una divisione per zero).
  final double completionRate;

  final int totalExercisesCompleted;
  final int totalExercisesSkipped;

  final int totalSetsCompleted;
  final int totalPlannedSets;

  /// `totalSetsCompleted / totalPlannedSets`. `null` se [totalPlannedSets]
  /// è `0` (sezione 17: non mostrabile, non "0%" — sarebbe un dato
  /// inventato).
  final double? setCompletionRate;

  /// Somma delle durate (`data_fine - data_inizio`) delle sole sessioni
  /// che hanno una `data_fine` (sezione 19). Include eventuali pause,
  /// stesso principio già stabilito in 07_Training_Engine.md — "Durata
  /// totale", non "tempo attivo".
  final Duration totalDuration;

  /// Media delle sole sessioni con durata valida. `null` se nessuna
  /// sessione nel periodo ha una `data_fine` (sezione 20/50).
  final Duration? averageDuration;

  /// Giorni di calendario distinti nel periodo con almeno una sessione
  /// (sezione 21/37: più sessioni nello stesso giorno contano 1).
  final int activeDays;

  /// `totalSessions / giorni-nel-periodo * 7` (sezione 22). Per
  /// `allTime`, i "giorni nel periodo" vanno dalla prima sessione a
  /// [WorkoutStatisticsService]'s `now`, minimo 1 giorno.
  final double averageSessionsPerWeek;

  /// Aggregazione per il grafico attività (sezione 24/26): vuota se
  /// [totalSessions] è `0` (nessuna barra finta, sezione 27).
  final List<WorkoutActivityPoint> activity;
}
