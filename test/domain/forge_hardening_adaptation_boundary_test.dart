import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_adaptation_reason.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout_session_history_item.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/services/forge_progression_analyzer.dart';

/// Hardening (Milestone 5.6, sezione 33): valori esattamente sulle soglie
/// di `ForgeEngineConfig` (default: minimumSessionsForAdaptation=3,
/// progressCompletionRateThreshold=0.8, progressSetCompletionRateThreshold
/// =0.85, simplifySetCompletionRateThreshold=0.5). Non aggiunge alcuna
/// regola: verifica solo che il comportamento inclusivo/esclusivo già
/// implementato in `ForgeProgressionAnalyzer._decide` (letto nel codice: `>=`
/// per le soglie di progress, `<` — strettamente — per quella di simplify)
/// resti quello osservato.
void main() {
  const config = ForgeEngineConfig();

  WorkoutSessionHistoryItem session({
    required int id,
    required WorkoutSessionPersistenceStatus status,
  }) {
    return WorkoutSessionHistoryItem(
      sessionId: id,
      workoutId: 1,
      profileId: 1,
      workoutName: 'Scheda',
      status: status,
      startedAt: DateTime(2026, 1, id),
      finishedAt: DateTime(2026, 1, id).add(const Duration(minutes: 30)),
      totalExercises: 1,
      completedExercises: 1,
      skippedExercises: 0,
      totalSetsCompleted: 0,
      totalPlannedSets: 0,
    );
  }

  PersistedSessionExercise row({
    required int sessionId,
    required int totalSets,
    required int completedSets,
  }) {
    return PersistedSessionExercise(
      sessionId: sessionId,
      exerciseId: 1,
      order: 1,
      totalSets: totalSets,
      completedSets: completedSets,
      isCompleted: completedSets >= totalSets,
      isSkipped: false,
    );
  }

  test('recentSessionCount esattamente alla soglia minima (3): non e\' '
      'insufficientHistory (il confronto e\' "<", 3 non e\' < 3)', () {
    final sessions = [
      for (var i = 1; i <= 3; i++)
        session(id: i, status: WorkoutSessionPersistenceStatus.completed),
    ];
    final rows = [
      for (var i = 1; i <= 3; i++)
        row(sessionId: i, totalSets: 10, completedSets: 10),
    ];
    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.decision, ForgeAdaptationDecision.progress);
    expect(
      context.reasons,
      isNot(contains(ForgeAdaptationReason.insufficientHistory)),
    );
  });

  test('recentSessionCount appena sotto la soglia minima (2): '
      'insufficientHistory -> maintain, indipendentemente da quanto buone '
      'siano le altre metriche', () {
    final sessions = [
      for (var i = 1; i <= 2; i++)
        session(id: i, status: WorkoutSessionPersistenceStatus.completed),
    ];
    final rows = [
      for (var i = 1; i <= 2; i++)
        row(sessionId: i, totalSets: 10, completedSets: 10),
    ];
    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.decision, ForgeAdaptationDecision.maintain);
    expect(
      context.reasons,
      contains(ForgeAdaptationReason.insufficientHistory),
    );
  });

  test('recentCompletionRate == 0.8 esatto e recentSetCompletionRate == 0.85 '
      'esatto (entrambe le soglie di progress incluse, ">=") -> progress', () {
    final sessions = [
      session(id: 1, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 2, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 3, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 4, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 5, status: WorkoutSessionPersistenceStatus.aborted),
    ];
    final rows = [
      row(sessionId: 1, totalSets: 4, completedSets: 4),
      row(sessionId: 2, totalSets: 4, completedSets: 4),
      row(sessionId: 3, totalSets: 4, completedSets: 4),
      row(sessionId: 4, totalSets: 4, completedSets: 4),
      row(sessionId: 5, totalSets: 4, completedSets: 1),
    ];
    expect((4 / 5), 0.8);
    expect((17 / 20), 0.85);

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.recentCompletionRate, 0.8);
    expect(context.recentSetCompletionRate, 0.85);
    expect(context.decision, ForgeAdaptationDecision.progress);
    expect(
      context.reasons,
      contains(ForgeAdaptationReason.highRecentCompletion),
    );
  });

  test('recentCompletionRate == 0.8 ma recentSetCompletionRate appena sotto '
      '0.85 (0.845): la condizione AND fallisce -> non progress, zona '
      'intermedia -> maintain', () {
    final sessions = [
      session(id: 1, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 2, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 3, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 4, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 5, status: WorkoutSessionPersistenceStatus.aborted),
    ];
    final rows = [
      row(sessionId: 1, totalSets: 40, completedSets: 40),
      row(sessionId: 2, totalSets: 40, completedSets: 40),
      row(sessionId: 3, totalSets: 40, completedSets: 40),
      row(sessionId: 4, totalSets: 40, completedSets: 40),
      row(sessionId: 5, totalSets: 40, completedSets: 9),
    ];
    expect((169 / 200), 0.845);

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.recentCompletionRate, 0.8);
    expect(context.recentSetCompletionRate, 0.845);
    expect(context.decision, ForgeAdaptationDecision.maintain);
    expect(context.reasons, contains(ForgeAdaptationReason.stablePerformance));
  });

  test('recentSetCompletionRate == 0.5 esatto: NON e\' simplify (il confronto '
      'e\' "<" stretto, 0.5 non e\' < 0.5) -> zona intermedia -> maintain', () {
    final sessions = [
      session(id: 1, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 2, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 3, status: WorkoutSessionPersistenceStatus.aborted),
      session(id: 4, status: WorkoutSessionPersistenceStatus.aborted),
      session(id: 5, status: WorkoutSessionPersistenceStatus.completed),
    ];
    final rows = [
      row(sessionId: 1, totalSets: 20, completedSets: 10),
      row(sessionId: 2, totalSets: 20, completedSets: 10),
      row(sessionId: 3, totalSets: 20, completedSets: 10),
      row(sessionId: 4, totalSets: 20, completedSets: 10),
      row(sessionId: 5, totalSets: 20, completedSets: 10),
    ];
    expect((3 / 5), 0.6);
    expect((50 / 100), 0.5);

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.recentSetCompletionRate, 0.5);
    expect(context.decision, ForgeAdaptationDecision.maintain);
    expect(context.reasons, contains(ForgeAdaptationReason.stablePerformance));
  });

  test('recentSetCompletionRate appena sotto 0.5 (0.49) -> simplify, '
      'lowSetCompletion', () {
    final sessions = [
      session(id: 1, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 2, status: WorkoutSessionPersistenceStatus.aborted),
      session(id: 3, status: WorkoutSessionPersistenceStatus.aborted),
      session(id: 4, status: WorkoutSessionPersistenceStatus.completed),
      session(id: 5, status: WorkoutSessionPersistenceStatus.completed),
    ];
    final rows = [
      row(sessionId: 1, totalSets: 20, completedSets: 10),
      row(sessionId: 2, totalSets: 20, completedSets: 10),
      row(sessionId: 3, totalSets: 20, completedSets: 10),
      row(sessionId: 4, totalSets: 20, completedSets: 10),
      row(sessionId: 5, totalSets: 20, completedSets: 9),
    ];
    expect((49 / 100), 0.49);

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    expect(context.recentSetCompletionRate, 0.49);
    expect(context.decision, ForgeAdaptationDecision.simplify);
    expect(context.reasons, contains(ForgeAdaptationReason.lowSetCompletion));
  });
}
