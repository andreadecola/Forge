import 'forge_adaptation_decision.dart';
import 'forge_adaptation_reason.dart';
import 'forge_exercise_history.dart';

/// Risultato dell'analisi dello storico (Milestone 5.4, sezione 4):
/// rappresenta solo l'evidenza disponibile e la decisione che ne deriva,
/// nessuna logica UI, nessuna stringa pronta per l'utente.
///
/// Non duplica `WorkoutStatistics` (Milestone 4.5.2): quella riguarda
/// **periodi calendariali** per la UI statistiche (7/30/90/tutto),
/// questo riguarda una **finestra a numero fisso di sessioni recenti**
/// per l'adattamento del motore — stesso dato sorgente
/// (`WorkoutSessionHistoryItem`), interpretazione diversa, campi diversi
/// (nessuna sovrapposizione di significato da poter effettivamente
/// riusare).
class ForgeAdaptationContext {
  const ForgeAdaptationContext({
    required this.completedSessions,
    required this.abortedSessions,
    required this.recentSessionCount,
    required this.recentCompletionRate,
    required this.recentSetCompletionRate,
    required this.exerciseHistory,
    required this.decision,
    required this.reasons,
  });

  /// Sessioni COMPLETED nella finestra recente analizzata.
  final int completedSessions;

  /// Sessioni ABORTED nella finestra recente analizzata — segnale debole
  /// (sezione 13: un abort non implica automaticamente "troppo
  /// difficile", può essere un'interruzione esterna).
  final int abortedSessions;

  /// Sessioni totali nella finestra (== `completedSessions + abortedSessions`,
  /// dato che solo sessioni concluse entrano nello storico).
  final int recentSessionCount;

  /// `completedSessions / recentSessionCount`, `0.0` se nessuna sessione.
  final double recentCompletionRate;

  /// Rapporto serie completate/pianificate sulla finestra, `null` se
  /// nessuna serie pianificata.
  final double? recentSetCompletionRate;

  /// Per `Exercise.id`.
  final Map<int, ForgeExerciseHistory> exerciseHistory;

  /// Corrisponde al concetto di "progression readiness": la decisione
  /// globale già presa da `ForgeProgressionAnalyzer`, pronta per essere
  /// applicata da `ForgeWorkoutAdaptationService` senza ricalcolo.
  final ForgeAdaptationDecision decision;

  /// Perché [decision] è quella (es. storico insufficiente, completion
  /// rate alta) — mai vuoto: c'è sempre almeno un motivo per ogni
  /// decisione.
  final List<ForgeAdaptationReason> reasons;
}
