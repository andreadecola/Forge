import '../entities/forge_adaptation_context.dart';
import '../entities/forge_adaptation_decision.dart';
import '../entities/forge_adaptation_reason.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_exercise_history.dart';
import '../entities/persisted_session_exercise.dart';
import '../entities/workout_session_history_item.dart';
import '../entities/workout_session_persistence_status.dart';

/// Costruisce un [ForgeAdaptationContext] dallo storico reale delle
/// sessioni (Milestone 5.4). Puro: nessun database, nessun `DateTime.now()`
/// — riceve liste già caricate dal chiamante (l'use case applicativo,
/// sezione 43), stesso schema di `ForgeEngine`/`ForgeWorkoutComposer`.
///
/// Principio fondamentale (sezione 3): non deduce mai "l'utente è
/// diventato più forte" dal solo passare del tempo — ogni decisione
/// dipende esclusivamente da conteggi derivabili da
/// `sessioni_allenamento`/`sessioni_esercizi`. Nessun dato che non
/// possediamo (peso, RPE, frequenza cardiaca, dolore, fatica percepita,
/// sezione 6/STOP 1) entra in nessun calcolo qui.
abstract final class ForgeProgressionAnalyzer {
  static ForgeAdaptationContext analyze({
    required List<WorkoutSessionHistoryItem> sessions,
    required List<PersistedSessionExercise> sessionExercises,
    required ForgeEngineConfig config,
  }) {
    // Ordinamento esplicito per data decrescente (mai l'ordine di arrivo
    // della lista, sezione 62): la finestra "sessioni più recenti" deve
    // dipendere solo da `startedAt`, non da come il chiamante ha
    // assemblato l'elenco.
    final sorted = List<WorkoutSessionHistoryItem>.of(sessions)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recent = sorted.take(config.adaptationHistorySessions).toList();
    final recentSessionIds = recent.map((s) => s.sessionId).toSet();

    final relevantRows = sessionExercises
        .where((e) => recentSessionIds.contains(e.sessionId))
        .toList();

    final completed = recent
        .where((s) => s.status == WorkoutSessionPersistenceStatus.completed)
        .length;
    final aborted = recent
        .where((s) => s.status == WorkoutSessionPersistenceStatus.aborted)
        .length;
    final recentSessionCount = recent.length;
    final recentCompletionRate = recentSessionCount == 0
        ? 0.0
        : completed / recentSessionCount;

    final totalPlannedSets = relevantRows.fold<int>(
      0,
      (sum, e) => sum + e.totalSets,
    );
    final totalCompletedSets = relevantRows.fold<int>(
      0,
      (sum, e) => sum + e.completedSets,
    );
    final recentSetCompletionRate = totalPlannedSets == 0
        ? null
        : totalCompletedSets / totalPlannedSets;

    final decided = _decide(
      recentSessionCount: recentSessionCount,
      recentCompletionRate: recentCompletionRate,
      recentSetCompletionRate: recentSetCompletionRate,
      config: config,
    );

    return ForgeAdaptationContext(
      completedSessions: completed,
      abortedSessions: aborted,
      recentSessionCount: recentSessionCount,
      recentCompletionRate: recentCompletionRate,
      recentSetCompletionRate: recentSetCompletionRate,
      exerciseHistory: _buildExerciseHistory(recent, relevantRows),
      decision: decided.decision,
      reasons: decided.reasons,
    );
  }

  /// Regole globali (sezione 11), tutte le soglie da [config] — nessun
  /// magic number sparso. STOP 4: qualunque zona non chiaramente positiva
  /// o negativa resta `maintain`.
  static ({
    ForgeAdaptationDecision decision,
    List<ForgeAdaptationReason> reasons,
  })
  _decide({
    required int recentSessionCount,
    required double recentCompletionRate,
    required double? recentSetCompletionRate,
    required ForgeEngineConfig config,
  }) {
    if (recentSessionCount < config.minimumSessionsForAdaptation) {
      return (
        decision: ForgeAdaptationDecision.maintain,
        reasons: const [ForgeAdaptationReason.insufficientHistory],
      );
    }

    final setRate = recentSetCompletionRate;
    if (recentCompletionRate >= config.progressCompletionRateThreshold &&
        setRate != null &&
        setRate >= config.progressSetCompletionRateThreshold) {
      return (
        decision: ForgeAdaptationDecision.progress,
        reasons: const [ForgeAdaptationReason.highRecentCompletion],
      );
    }

    if (setRate != null &&
        setRate < config.simplifySetCompletionRateThreshold) {
      return (
        decision: ForgeAdaptationDecision.simplify,
        reasons: const [ForgeAdaptationReason.lowSetCompletion],
      );
    }

    return (
      decision: ForgeAdaptationDecision.maintain,
      reasons: const [ForgeAdaptationReason.stablePerformance],
    );
  }

  static Map<int, ForgeExerciseHistory> _buildExerciseHistory(
    List<WorkoutSessionHistoryItem> recent,
    List<PersistedSessionExercise> rows,
  ) {
    final sessionStartById = {for (final s in recent) s.sessionId: s.startedAt};
    final byExercise = <int, List<PersistedSessionExercise>>{};
    for (final row in rows) {
      byExercise.putIfAbsent(row.exerciseId, () => []).add(row);
    }
    return {
      for (final entry in byExercise.entries)
        entry.key: _aggregate(entry.key, entry.value, sessionStartById),
    };
  }

  static ForgeExerciseHistory _aggregate(
    int exerciseId,
    List<PersistedSessionExercise> rows,
    Map<int, DateTime> sessionStartById,
  ) {
    var timesCompleted = 0;
    var timesSkipped = 0;
    var completedSets = 0;
    var plannedSets = 0;
    DateTime? lastPerformedAt;

    for (final row in rows) {
      if (row.isCompleted) {
        timesCompleted++;
        final start = sessionStartById[row.sessionId];
        if (start != null &&
            (lastPerformedAt == null || start.isAfter(lastPerformedAt))) {
          lastPerformedAt = start;
        }
      }
      if (row.isSkipped) timesSkipped++;
      completedSets += row.completedSets;
      plannedSets += row.totalSets;
    }

    return ForgeExerciseHistory(
      exerciseId: exerciseId,
      timesPlanned: rows.length,
      timesCompleted: timesCompleted,
      timesSkipped: timesSkipped,
      completedSets: completedSets,
      plannedSets: plannedSets,
      lastPerformedAt: lastPerformedAt,
    );
  }
}
