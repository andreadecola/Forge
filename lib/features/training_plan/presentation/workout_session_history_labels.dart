import '../../../domain/entities/workout_session_persistence_status.dart';

/// Traduzioni italiane per lo storico sessioni (Milestone 4.5.1). Stesso
/// principio di `WorkoutLabels`: nessun codice tecnico/enum inglese deve
/// raggiungere la UI senza passare da qui.
abstract final class WorkoutSessionHistoryLabels {
  static String status(WorkoutSessionPersistenceStatus status) {
    switch (status) {
      case WorkoutSessionPersistenceStatus.completed:
        return 'Completato';
      case WorkoutSessionPersistenceStatus.aborted:
        return 'Interrotto';
      case WorkoutSessionPersistenceStatus.inProgress:
      case WorkoutSessionPersistenceStatus.paused:
        // Non dovrebbero mai comparire nello storico (sezione 8: solo
        // COMPLETED/ABORTED vengono interrogate) — fallback innocuo, mai
        // mostrato in pratica.
        return 'In corso';
    }
  }

  /// Stato di un singolo esercizio nel dettaglio storico (sezione 20/21).
  /// Nessun termine negativo/punitivo (sezione 10): "Non completato", non
  /// "Fallito"/"Mancato".
  static String exerciseState({
    required bool isCompleted,
    required bool isSkipped,
    required int completedSets,
  }) {
    if (isCompleted) return 'Completato';
    if (isSkipped) return 'Saltato';
    if (completedSets > 0) return 'Parziale';
    return 'Non completato';
  }
}
