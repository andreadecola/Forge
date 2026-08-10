import 'package:drift/drift.dart';

import '../../domain/entities/persisted_session_exercise.dart';
import '../../domain/entities/persisted_session_timer.dart';
import '../../domain/entities/persisted_session_timer_kind.dart';
import '../../domain/entities/persisted_workout_session.dart';
import '../../domain/entities/workout_session_exercise_history_item.dart';
import '../../domain/entities/workout_session_history_item.dart';
import '../../domain/entities/workout_session_persistence_status.dart';
import '../database/app_database.dart';

/// Conversioni tra righe Drift e entità di dominio della sessione
/// persistita (Milestone 4.4.3), stesso ruolo di `WorkoutMappers` per la
/// definizione della scheda.
abstract final class WorkoutSessionMappers {
  static PersistedWorkoutSession session(SessioniAllenamentoTableData row) {
    return PersistedWorkoutSession(
      id: row.id,
      workoutId: row.idAllenamento,
      profileId: row.idProfilo,
      workoutNameSnapshot: row.nomeAllenamentoSnapshot,
      status: WorkoutSessionPersistenceStatus.fromCode(row.stato),
      currentExerciseIndex: row.indiceEsercizioCorrente,
      startedAt: row.dataInizio,
      endedAt: row.dataFine,
      isPaused: row.inPausa,
      isCompleted: row.completata,
      timer: row.timerTipo == null
          ? null
          : PersistedSessionTimer(
              kind: PersistedSessionTimerKind.fromCode(row.timerTipo!),
              startedAt: row.timerStartedAt!,
              targetSeconds: row.timerTargetSeconds!,
              remainingPaused: row.timerRemainingPaused,
            ),
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  static PersistedSessionExercise sessionExercise(
    SessioniEserciziTableData row,
  ) {
    return PersistedSessionExercise(
      id: row.id,
      sessionId: row.idSessione,
      workoutExerciseId: row.idAllenamentoEsercizio,
      exerciseId: row.idEsercizio,
      order: row.ordine,
      totalSets: row.serieTotali,
      completedSets: row.serieCompletate,
      repetitions: row.ripetizioni,
      durationSeconds: row.durataSecondi,
      restSeconds: row.recuperoSecondi,
      isSkipped: row.saltato,
      isCompleted: row.completato,
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  /// Companion di inserimento per una nuova sessione (sempre con tutti i
  /// campi: non serve la scrittura parziale che serve invece agli
  /// aggiornamenti, vedi [stateChanges]).
  static SessioniAllenamentoTableCompanion sessionToInsertCompanion({
    required int? workoutId,
    required int profileId,
    required String workoutNameSnapshot,
    required DateTime startedAt,
  }) {
    return SessioniAllenamentoTableCompanion.insert(
      idAllenamento: Value(workoutId),
      idProfilo: profileId,
      nomeAllenamentoSnapshot: workoutNameSnapshot,
      stato: WorkoutSessionPersistenceStatus.inProgress.code,
      dataInizio: startedAt,
      dataCreazione: startedAt,
      dataModifica: startedAt,
    );
  }

  /// Companion di inserimento per una riga snapshot di una sessione.
  static SessioniEserciziTableCompanion sessionExerciseToInsertCompanion({
    required int sessionId,
    required int workoutExerciseId,
    required int exerciseId,
    required int order,
    required int totalSets,
    required int? repetitions,
    required int? durationSeconds,
    required int? restSeconds,
    required DateTime now,
  }) {
    return SessioniEserciziTableCompanion.insert(
      idSessione: sessionId,
      idAllenamentoEsercizio: Value(workoutExerciseId),
      idEsercizio: exerciseId,
      ordine: order,
      serieTotali: totalSets,
      ripetizioni: Value(repetitions),
      durataSecondi: Value(durationSeconds),
      recuperoSecondi: Value(restSeconds),
      dataCreazione: now,
      dataModifica: now,
    );
  }

  /// Companion di sola scrittura parziale (campi non passati restano
  /// `Value.absent()`, cioè invariati): usato con
  /// `SessioniAllenamentoDao.updateState`.
  static SessioniAllenamentoTableCompanion stateChanges({
    int? currentExerciseIndex,
    WorkoutSessionPersistenceStatus? status,
    bool? isPaused,
    bool? isCompleted,
    DateTime? endedAt,
    bool clearTimer = false,
    PersistedSessionTimer? timer,
    required DateTime updatedAt,
  }) {
    return SessioniAllenamentoTableCompanion(
      indiceEsercizioCorrente: currentExerciseIndex == null
          ? const Value.absent()
          : Value(currentExerciseIndex),
      stato: status == null ? const Value.absent() : Value(status.code),
      inPausa: isPaused == null ? const Value.absent() : Value(isPaused),
      completata: isCompleted == null
          ? const Value.absent()
          : Value(isCompleted),
      dataFine: endedAt == null ? const Value.absent() : Value(endedAt),
      timerTipo: !clearTimer ? const Value.absent() : Value(timer?.kind.code),
      timerStartedAt: !clearTimer
          ? const Value.absent()
          : Value(timer?.startedAt),
      timerTargetSeconds: !clearTimer
          ? const Value.absent()
          : Value(timer?.targetSeconds),
      timerRemainingPaused: !clearTimer
          ? const Value.absent()
          : Value(timer?.remainingPaused),
      dataModifica: Value(updatedAt),
    );
  }

  /// Companion di sola scrittura parziale del progresso di una riga
  /// snapshot: usato con `SessioniEserciziDao.updateProgress`.
  static SessioniEserciziTableCompanion progressChanges({
    required int completedSets,
    required bool isSkipped,
    required bool isCompleted,
    required DateTime updatedAt,
  }) {
    return SessioniEserciziTableCompanion(
      serieCompletate: Value(completedSets),
      saltato: Value(isSkipped),
      completato: Value(isCompleted),
      dataModifica: Value(updatedAt),
    );
  }

  /// Riga di storico (Milestone 4.5.1): [exerciseRows] sono le righe
  /// snapshot della sessione, usate solo per aggregare i conteggi (nessun
  /// dettaglio esercizio qui — quello vive in [exerciseHistoryItem]).
  static WorkoutSessionHistoryItem historyItem(
    SessioniAllenamentoTableData row,
    List<SessioniEserciziTableData> exerciseRows,
  ) {
    return WorkoutSessionHistoryItem(
      sessionId: row.id,
      workoutId: row.idAllenamento,
      profileId: row.idProfilo,
      workoutName: row.nomeAllenamentoSnapshot,
      status: WorkoutSessionPersistenceStatus.fromCode(row.stato),
      startedAt: row.dataInizio,
      finishedAt: row.dataFine,
      totalExercises: exerciseRows.length,
      completedExercises: exerciseRows.where((e) => e.completato).length,
      skippedExercises: exerciseRows.where((e) => e.saltato).length,
      totalSetsCompleted: exerciseRows.fold(
        0,
        (sum, e) => sum + e.serieCompletate,
      ),
      totalPlannedSets: exerciseRows.fold(0, (sum, e) => sum + e.serieTotali),
    );
  }

  /// Riga esercizio di storico (Milestone 4.5.1): [exercise] risolve solo
  /// il nome dal catalogo, tutti gli altri valori restano lo snapshot
  /// della sessione (mai la scheda live, sezione 22).
  static WorkoutSessionExerciseHistoryItem exerciseHistoryItem(
    SessioniEserciziTableData row,
    EserciziTableData exercise,
  ) {
    return WorkoutSessionExerciseHistoryItem(
      sessionExerciseId: row.id,
      workoutExerciseId: row.idAllenamentoEsercizio,
      exerciseId: row.idEsercizio,
      order: row.ordine,
      exerciseName: exercise.nome,
      totalSets: row.serieTotali,
      completedSets: row.serieCompletate,
      repetitions: row.ripetizioni,
      durationSeconds: row.durataSecondi,
      restSeconds: row.recuperoSecondi,
      isCompleted: row.completato,
      isSkipped: row.saltato,
    );
  }
}
