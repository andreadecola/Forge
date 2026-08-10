/// Riga esercizio di storico (Milestone 4.5.1): dati dello snapshot
/// (`sessioni_esercizi`) più [exerciseName], risolto dal catalogo tramite
/// [exerciseId] — mai dalla scheda live (i parametri restano quelli con
/// cui la sessione è iniziata, anche se la scheda è stata modificata
/// dopo, sezione 22/23).
class WorkoutSessionExerciseHistoryItem {
  const WorkoutSessionExerciseHistoryItem({
    required this.sessionExerciseId,
    required this.workoutExerciseId,
    required this.exerciseId,
    required this.order,
    required this.exerciseName,
    required this.totalSets,
    required this.completedSets,
    this.repetitions,
    this.durationSeconds,
    this.restSeconds,
    required this.isCompleted,
    required this.isSkipped,
  });

  final int sessionExerciseId;

  /// Nullable: `ON DELETE SET NULL` se la riga scheda originale non
  /// esiste più (Milestone 4.4.3) — nessun dato mostrabile dipende da
  /// questo campo, è solo un riferimento storico.
  final int? workoutExerciseId;

  final int exerciseId;
  final int order;
  final String exerciseName;
  final int totalSets;
  final int completedSets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final bool isCompleted;
  final bool isSkipped;
}
