/// Riepilogo derivato di una settimana del Piano Settimanale (Milestone
/// 8.7): risponde solo a "com'è andata questa settimana rispetto a quello
/// che era previsto?" — mai un giudizio, un adattamento o una modifica del
/// piano. Nessun campo qui è persistito: ricalcolato ogni volta da
/// [PlannedActivity] e dallo stato reale delle sessioni collegate
/// (`WeeklyPlanSummaryService`).
///
/// [matureTotal]/[matureCompleted] sono la base per un'eventuale
/// percentuale di completamento: contano solo le attività con
/// `scheduledDate <= oggi` (sezione 39-44) — un'attività futura non
/// abbassa mai un tasso di completamento, perché semplicemente non è
/// ancora "matura". Per una settimana futura [matureTotal] è sempre 0
/// (nessuna percentuale mostrabile, sezione 16/18/36); per una settimana
/// interamente passata [matureTotal] coincide con [total] (sezione 17).
class WeeklyPlanSummary {
  const WeeklyPlanSummary({
    required this.total,
    required this.completed,
    required this.active,
    required this.skipped,
    required this.postponed,
    required this.plannedRemaining,
    required this.workoutCount,
    required this.walkCount,
    required this.recoveryCount,
    required this.matureTotal,
    required this.matureCompleted,
  });

  /// Tutte le `PlannedActivity` della settimana, indipendentemente da
  /// stato o data.
  final int total;

  /// Sessione reale collegata con stato COMPLETED (sezione 7) — mai un
  /// secondo flag persistito, sempre derivato.
  final int completed;

  /// Sessione reale collegata ancora IN_PROGRESS/PAUSED (Workout) o
  /// IN_PROGRESS (Walk) — mai considerata completata (sezione 8).
  final int active;

  /// `status == SKIPPED` (sezione 10) — sempre una decisione esplicita
  /// dell'utente, mai dedotta dalla data.
  final int skipped;

  /// `status == POSTPONED` (sezione 11).
  final int postponed;

  /// `status == PLANNED` e nessuna sessione attiva/completata collegata
  /// (sezione 12): ancora da fare, futura o meno.
  final int plannedRemaining;

  final int workoutCount;
  final int walkCount;
  final int recoveryCount;

  /// Attività con `scheduledDate <= oggi` — la base del denominatore per
  /// un'eventuale percentuale (sezione 14/15/39).
  final int matureTotal;

  /// Tra le mature, quelle con sessione reale COMPLETED.
  final int matureCompleted;

  /// `null` se non c'è nulla di "maturo" da valutare (settimana futura o
  /// senza attività) — mai una percentuale fuorviante (sezione 18).
  double? get matureCompletionRate =>
      matureTotal == 0 ? null : matureCompleted / matureTotal;
}
