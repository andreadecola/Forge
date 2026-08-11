import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_adaptation_reason.dart';
import 'package:forge/domain/entities/forge_engine_config.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout_session_history_item.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/services/forge_progression_analyzer.dart';

WorkoutSessionHistoryItem _session({
  required int id,
  required DateTime startedAt,
  WorkoutSessionPersistenceStatus status =
      WorkoutSessionPersistenceStatus.completed,
}) {
  return WorkoutSessionHistoryItem(
    sessionId: id,
    workoutId: 1,
    profileId: 1,
    workoutName: 'Scheda',
    status: status,
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(minutes: 30)),
    totalExercises: 1,
    completedExercises: 1,
    skippedExercises: 0,
    totalSetsCompleted: 3,
    totalPlannedSets: 3,
  );
}

PersistedSessionExercise _exerciseRow({
  required int sessionId,
  required int exerciseId,
  int totalSets = 3,
  int completedSets = 3,
  bool isCompleted = true,
  bool isSkipped = false,
}) {
  return PersistedSessionExercise(
    sessionId: sessionId,
    exerciseId: exerciseId,
    order: 1,
    totalSets: totalSets,
    completedSets: completedSets,
    isCompleted: isCompleted,
    isSkipped: isSkipped,
  );
}

void main() {
  const config = ForgeEngineConfig();

  test('nessuno storico -> maintain, insufficientHistory (sezione 46)', () {
    final context = ForgeProgressionAnalyzer.analyze(
      sessions: const [],
      sessionExercises: const [],
      config: config,
    );

    expect(context.decision, ForgeAdaptationDecision.maintain);
    expect(
      context.reasons,
      contains(ForgeAdaptationReason.insufficientHistory),
    );
    expect(context.recentSessionCount, 0);
  });

  test('storico sotto la soglia minima -> maintain anche con evidenza '
      'positiva (sezione 47)', () {
    final sessions = [_session(id: 1, startedAt: DateTime(2026, 1, 1))];
    final rows = [_exerciseRow(sessionId: 1, exerciseId: 10)];

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config, // minimumSessionsForAdaptation default 3
    );

    expect(context.decision, ForgeAdaptationDecision.maintain);
    expect(
      context.reasons,
      contains(ForgeAdaptationReason.insufficientHistory),
    );
  });

  test('sessioni recenti completate con alta completion -> progress '
      '(sezione 48)', () {
    final sessions = [
      for (var i = 0; i < 4; i++)
        _session(id: i, startedAt: DateTime(2026, 1, 1 + i)),
    ];
    final rows = [
      for (var i = 0; i < 4; i++)
        _exerciseRow(
          sessionId: i,
          exerciseId: 10,
          totalSets: 3,
          completedSets: 3,
        ),
    ];

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );

    expect(context.decision, ForgeAdaptationDecision.progress);
    expect(
      context.reasons,
      contains(ForgeAdaptationReason.highRecentCompletion),
    );
    expect(context.exerciseHistory[10]!.timesCompleted, 4);
    expect(context.exerciseHistory[10]!.completionRate, 1.0);
  });

  test('una singola sessione interrotta (sopra soglia minima, il resto '
      'nella norma) -> non regressione automatica (sezione 51)', () {
    final sessions = [
      _session(id: 1, startedAt: DateTime(2026, 1, 1)),
      _session(id: 2, startedAt: DateTime(2026, 1, 2)),
      _session(
        id: 3,
        startedAt: DateTime(2026, 1, 3),
        status: WorkoutSessionPersistenceStatus.aborted,
      ),
    ];
    final rows = [
      _exerciseRow(
        sessionId: 1,
        exerciseId: 10,
        totalSets: 3,
        completedSets: 3,
      ),
      _exerciseRow(
        sessionId: 2,
        exerciseId: 10,
        totalSets: 3,
        completedSets: 3,
      ),
      _exerciseRow(
        sessionId: 3,
        exerciseId: 10,
        totalSets: 3,
        completedSets: 2,
      ),
    ];

    final context = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );

    // Un solo abort non basta a spingere in simplify: completion rate
    // sessioni 2/3 e serie 8/9 restano nella "zona intermedia".
    expect(context.decision, ForgeAdaptationDecision.maintain);
  });

  test('determinismo: stesso storico analizzato più volte -> stesso '
      'contesto (sezione 61)', () {
    final sessions = [
      for (var i = 0; i < 5; i++)
        _session(id: i, startedAt: DateTime(2026, 1, 1 + i)),
    ];
    final rows = [
      for (var i = 0; i < 5; i++) _exerciseRow(sessionId: i, exerciseId: 10),
    ];

    final first = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    for (var i = 0; i < 100; i++) {
      final result = ForgeProgressionAnalyzer.analyze(
        sessions: sessions,
        sessionExercises: rows,
        config: config,
      );
      expect(result.decision, first.decision);
      expect(result.recentCompletionRate, first.recentCompletionRate);
    }
  });

  test('storico fornito in ordine diverso -> stesso contesto (sezione 62)', () {
    final sessions = [
      for (var i = 0; i < 5; i++)
        _session(id: i, startedAt: DateTime(2026, 1, 1 + i)),
    ];
    final rows = [
      for (var i = 0; i < 5; i++) _exerciseRow(sessionId: i, exerciseId: 10),
    ];
    final shuffledSessions = [
      sessions[3],
      sessions[0],
      sessions[4],
      sessions[1],
      sessions[2],
    ];
    final shuffledRows = [rows[2], rows[4], rows[0], rows[3], rows[1]];

    final original = ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: rows,
      config: config,
    );
    final shuffled = ForgeProgressionAnalyzer.analyze(
      sessions: shuffledSessions,
      sessionExercises: shuffledRows,
      config: config,
    );

    expect(shuffled.decision, original.decision);
    expect(shuffled.recentCompletionRate, original.recentCompletionRate);
    expect(shuffled.recentSetCompletionRate, original.recentSetCompletionRate);
  });

  test(
    'solo la finestra di sessioni recenti configurata entra nel calcolo',
    () {
      // 10 sessioni completate con serie basse, poi 8 recentissime con
      // serie perfette: con adaptationHistorySessions=8 solo le recenti
      // contano.
      final old = [
        for (var i = 0; i < 10; i++)
          _session(id: i, startedAt: DateTime(2025, 1, 1 + i)),
      ];
      final oldRows = [
        for (var i = 0; i < 10; i++)
          _exerciseRow(
            sessionId: i,
            exerciseId: 10,
            totalSets: 3,
            completedSets: 1,
          ),
      ];
      final recent = [
        for (var i = 100; i < 108; i++)
          _session(id: i, startedAt: DateTime(2026, 2, 1 + (i - 100))),
      ];
      final recentRows = [
        for (var i = 100; i < 108; i++)
          _exerciseRow(
            sessionId: i,
            exerciseId: 10,
            totalSets: 3,
            completedSets: 3,
          ),
      ];

      final context = ForgeProgressionAnalyzer.analyze(
        sessions: [...old, ...recent],
        sessionExercises: [...oldRows, ...recentRows],
        config: config,
      );

      expect(context.recentSessionCount, 8);
      expect(context.decision, ForgeAdaptationDecision.progress);
    },
  );
}
