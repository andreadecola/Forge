/// Riga persistita di `sessioni_esercizi` (Milestone 4.4.3): snapshot dei
/// parametri di una riga scheda al momento dell'avvio della sessione, più
/// il progresso serie raggiunto. Vedi `sessioni_esercizi_table.dart` per il
/// perché di [workoutExerciseId] nullable.
class PersistedSessionExercise {
  const PersistedSessionExercise({
    this.id,
    required this.sessionId,
    this.workoutExerciseId,
    required this.exerciseId,
    required this.order,
    required this.totalSets,
    this.completedSets = 0,
    this.repetitions,
    this.durationSeconds,
    this.restSeconds,
    this.isSkipped = false,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int sessionId;
  final int? workoutExerciseId;
  final int exerciseId;
  final int order;
  final int totalSets;
  final int completedSets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final bool isSkipped;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// Aggiornamento di progresso per una riga (Milestone 4.4.3): usato da
/// `WorkoutSessionRepository.updateProgress` per scrivere solo ciò che può
/// cambiare durante la sessione, senza riscrivere lo snapshot dei parametri
/// (che non cambia mai dopo la creazione).
class SessionExerciseProgressUpdate {
  const SessionExerciseProgressUpdate({
    required this.workoutExerciseId,
    required this.completedSets,
    required this.isSkipped,
    required this.isCompleted,
  });

  final int workoutExerciseId;
  final int completedSets;
  final bool isSkipped;
  final bool isCompleted;
}
