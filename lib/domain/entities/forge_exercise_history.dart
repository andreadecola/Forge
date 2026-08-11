/// Storico aggregato di un esercizio nella finestra recente analizzata da
/// `ForgeProgressionAnalyzer` (Milestone 5.4, sezione 5). Costruito solo
/// da dati realmente persistiti (`sessioni_esercizi`) — nessun dato
/// inventato (peso, RPE, frequenza cardiaca, dolore, fatica percepita:
/// non li abbiamo, quindi non compaiono qui, sezione 6).
class ForgeExerciseHistory {
  const ForgeExerciseHistory({
    required this.exerciseId,
    required this.timesPlanned,
    required this.timesCompleted,
    required this.timesSkipped,
    required this.completedSets,
    required this.plannedSets,
    this.lastPerformedAt,
  });

  final int exerciseId;

  /// Numero di occorrenze dell'esercizio in una sessione della finestra
  /// (completata, saltata, o né l'una né l'altra — riga presente).
  final int timesPlanned;

  /// Occorrenze con `completato == true`.
  final int timesCompleted;

  /// Occorrenze con `saltato == true`.
  final int timesSkipped;

  /// Somma di `serieCompletate` su tutte le occorrenze.
  final int completedSets;

  /// Somma di `serieTotali` su tutte le occorrenze.
  final int plannedSets;

  /// Inizio della sessione più recente in cui l'esercizio è stato
  /// **completato** (non solo pianificato/saltato) — `null` se non è mai
  /// stato completato nella finestra.
  final DateTime? lastPerformedAt;

  /// `null` se non pianificato nella finestra (evita una divisione per
  /// zero silenziosa altrove).
  double? get completionRate =>
      timesPlanned == 0 ? null : timesCompleted / timesPlanned;

  /// `null` se nessuna serie pianificata nella finestra.
  double? get setCompletionRate =>
      plannedSets == 0 ? null : completedSets / plannedSets;
}
