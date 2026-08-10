import 'workout_session_persistence_status.dart';

/// Riga di storico (Milestone 4.5.1): riepilogo di una sessione conclusa
/// (COMPLETED o ABORTED — le sessioni IN_PROGRESS/PAUSED non compaiono
/// qui, sono già gestite come sessione attiva). [totalExercises]/
/// [completedExercises]/[skippedExercises] sono aggregati lato repository
/// da `sessioni_esercizi`, non ricalcolati nella UI.
class WorkoutSessionHistoryItem {
  const WorkoutSessionHistoryItem({
    required this.sessionId,
    required this.workoutId,
    required this.profileId,
    required this.workoutName,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    required this.totalExercises,
    required this.completedExercises,
    required this.skippedExercises,
    required this.totalSetsCompleted,
    required this.totalPlannedSets,
  });

  final int sessionId;

  /// Nullable: la scheda originale potrebbe essere stata eliminata
  /// (`ON DELETE SET NULL`, Milestone 4.4.3) — [workoutName] resta
  /// comunque leggibile in quel caso.
  final int? workoutId;

  final int profileId;
  final String workoutName;
  final WorkoutSessionPersistenceStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int totalExercises;
  final int completedExercises;
  final int skippedExercises;

  /// Somma di `sessioni_esercizi.serieCompletate`/`serieTotali` per la
  /// sessione (Milestone 4.5.2): aggregati qui, non nel dettaglio
  /// per-esercizio, perché [WorkoutStatisticsService] ha bisogno solo del
  /// totale per sessione, mai delle singole righe.
  final int totalSetsCompleted;
  final int totalPlannedSets;
}
