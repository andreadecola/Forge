import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/persisted_session_exercise.dart';
import '../../../domain/entities/persisted_session_timer.dart';
import '../../../domain/entities/persisted_session_timer_kind.dart';
import '../../../domain/entities/workout_details.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import 'session_timer.dart';
import 'workout_session_clock.dart';
import 'workout_session_state.dart';

/// Sessione runtime di allenamento (Milestone 4.4.1, estesa con serie e
/// timer in Milestone 4.4.2, con persistenza in Milestone 4.4.3): provider
/// globale (non `.family`) perché Forge permette **una sola sessione
/// attiva alla volta**, indipendentemente da quale scheda. Tutta la
/// logica di avanzamento vive qui, non nei widget.
///
/// [state] resta la fonte di verità *runtime* (invariato dalla Milestone
/// 4.4.1): la persistenza (Milestone 4.4.3) è solo un meccanismo di
/// ripristino best-effort dopo la chiusura dell'app, scritto su eventi
/// significativi (mai a ogni tick, sezione 14) e sempre **dopo** aver già
/// aggiornato `state` — la UI non aspetta mai l'I/O del database per
/// reagire a un'azione. Le scritture sono quindi fire-and-forget
/// (`unawaited`, con solo un log in caso di errore): un singolo
/// aggiornamento perso non compromette la sessione runtime in corso, al
/// più rende il ripristino leggermente indietro rispetto all'ultimo
/// istante — vedi 07_Training_Engine.md per il compromesso.
///
/// Il countdown (serie a tempo o recupero) non è un contatore decrementato
/// a ogni tick: [SessionTimer] deriva sempre i secondi residui dal tempo
/// realmente trascorso. Il `Timer.periodic` qui dentro serve solo a
/// "risvegliare" la UI ogni secondo per farla ridisegnare (e per accorgersi
/// che un countdown è arrivato a zero) — non è la fonte di verità del
/// tempo residuo, che resta sempre ricalcolato da [SessionClock].
class WorkoutSessionController extends Notifier<WorkoutSessionState?> {
  Timer? _ticker;
  late final SessionClock _clock;
  late final WorkoutSessionRepository _repository;

  @override
  WorkoutSessionState? build() {
    _clock = ref.read(sessionClockProvider);
    _repository = ref.read(workoutSessionRepositoryProvider);
    ref.onDispose(_stopTicker);
    return null;
  }

  /// Avvia una nuova sessione per [details]: crea prima la riga
  /// persistita (sezione 15 — l'ordine non è arbitrario, serve l'id
  /// assegnato dal DB prima di poter inizializzare [state].sessionId) e
  /// solo poi inizializza lo stato runtime. Ritorna `false` — senza
  /// modificare lo stato corrente — se una sessione è già attiva (in
  /// memoria, o già persistita per questo profilo da un dispositivo/avvio
  /// precedente): Forge non sostituisce mai una sessione in corso
  /// silenziosamente.
  Future<bool> startSession(WorkoutDetails details) async {
    if (state != null) return false;
    _stopTicker();

    final startedAt = _clock.now();
    int sessionId;
    try {
      sessionId = await _repository.createSession(
        profileId: details.workout.profileId,
        details: details,
        startedAt: startedAt,
      );
    } on ActiveSessionAlreadyExistsException {
      return false;
    }

    state = WorkoutSessionState(
      sessionId: sessionId,
      workoutId: details.workout.id!,
      workoutName: details.workout.name,
      exercises: details.exercises,
      startedAt: startedAt,
    );
    return true;
  }

  /// Adotta una sessione già ricostruita da un
  /// `WorkoutSessionRestoreService` (Milestone 4.4.3): unico chiamante
  /// previsto è il flusso "Riprendi" del banner di ripristino, sempre con
  /// nessuna sessione runtime già attiva (il banner esiste solo quando
  /// [state] è ancora `null`, prima di qualunque `startSession` in questo
  /// avvio dell'app).
  void adoptRestoredSession(WorkoutSessionState restored) {
    if (state != null) return;
    _stopTicker();
    state = restored;
    if (!restored.isPaused &&
        (restored.exerciseTimer != null || restored.restTimer != null)) {
      _startTicker();
    }
  }

  /// "Completa serie" per un esercizio a ripetizioni. Se l'esercizio
  /// corrente è già risolto (visto tramite "Indietro"), si comporta come
  /// "vai al successivo" senza toccare di nuovo le serie.
  void completeCurrentSet() {
    final current = state;
    if (current == null || current.isPaused || current.isCompleted) return;
    if (current.exerciseTimer != null || current.restTimer != null) return;

    if (_isAlreadyResolved(current)) {
      _advanceToNextExercise(current);
      return;
    }

    _stopTicker();
    _finishSet(current);
  }

  /// "Avvia serie" per un esercizio a tempo: parte il countdown da
  /// `durationSeconds`. Nessun effetto per un esercizio a ripetizioni.
  void startTimedSet() {
    final current = state;
    if (current == null || current.isPaused || current.isCompleted) return;
    if (current.exerciseTimer != null || current.restTimer != null) return;

    final duration = current.currentExercise.workoutExercise.durationSeconds;
    if (duration == null) return;

    if (_isAlreadyResolved(current)) {
      _advanceToNextExercise(current);
      return;
    }

    final next = current.copyWith(
      exerciseTimer: () =>
          SessionTimer(targetSeconds: duration, startedAt: _clock.now()),
    );
    state = next;
    _persist(next);
    _startTicker();
  }

  /// "Salta recupero": ferma il countdown di recupero, la serie
  /// successiva è pronta immediatamente.
  void skipRest() {
    final current = state;
    if (current == null || current.isPaused || current.restTimer == null) {
      return;
    }
    _stopTicker();
    final next = current.copyWith(restTimer: () => null);
    state = next;
    _persist(next);
  }

  bool _isAlreadyResolved(WorkoutSessionState current) {
    final id = current.currentWorkoutExerciseId;
    return current.completedWorkoutExerciseIds.contains(id) ||
        current.skippedWorkoutExerciseIds.contains(id);
  }

  void _onTick() {
    final current = state;
    if (current == null || current.isPaused) return;

    final exerciseTimer = current.exerciseTimer;
    if (exerciseTimer != null) {
      if (exerciseTimer.isFinished(_clock)) {
        _stopTicker();
        // La serie a tempo si completa da sola al termine del countdown
        // (sezione 9): stessa logica "dopo la serie" di completeCurrentSet.
        _finishSet(current.copyWith(exerciseTimer: () => null));
      } else {
        // Nessun valore nuovo da calcolare: il residuo è già derivato dal
        // timestamp. Serve solo un nuovo stato (diverso per identità) per
        // far ridisegnare la UI con il countdown aggiornato — e nessuna
        // scrittura DB, perché non è cambiato nulla di significativo
        // (sezione 14).
        state = current.copyWith();
      }
      return;
    }

    final restTimer = current.restTimer;
    if (restTimer != null) {
      if (restTimer.isFinished(_clock)) {
        _stopTicker();
        final next = current.copyWith(restTimer: () => null);
        state = next;
        _persist(next);
      } else {
        state = current.copyWith();
      }
    }
  }

  /// Registra la serie corrente come completata e decide cosa succede
  /// dopo: recupero (se `restSeconds > 0`), serie successiva immediata, o
  /// fine esercizio (se era l'ultima).
  void _finishSet(WorkoutSessionState current) {
    final id = current.currentWorkoutExerciseId;
    final we = current.currentExercise.workoutExercise;
    final totalSets = totalSetsFor(we);
    final doneSets = current.currentCompletedSets + 1;
    final updatedSets = {
      ...current.completedSetsByWorkoutExerciseId,
      id: doneSets,
    };

    if (doneSets >= totalSets) {
      final completed = {...current.completedWorkoutExerciseIds, id};
      final skipped = {...current.skippedWorkoutExerciseIds}..remove(id);
      _advanceExercise(
        current.copyWith(completedSetsByWorkoutExerciseId: updatedSets),
        completedWorkoutExerciseIds: completed,
        skippedWorkoutExerciseIds: skipped,
      );
      return;
    }

    final rest = we.restSeconds;
    final WorkoutSessionState next;
    if (rest != null && rest > 0) {
      next = current.copyWith(
        completedSetsByWorkoutExerciseId: updatedSets,
        restTimer: () =>
            SessionTimer(targetSeconds: rest, startedAt: _clock.now()),
      );
      _startTicker();
    } else {
      next = current.copyWith(completedSetsByWorkoutExerciseId: updatedSets);
    }
    state = next;
    _persist(next);
  }

  void _advanceToNextExercise(WorkoutSessionState current) {
    _advanceExercise(
      current,
      completedWorkoutExerciseIds: current.completedWorkoutExerciseIds,
      skippedWorkoutExerciseIds: current.skippedWorkoutExerciseIds,
    );
  }

  void _advanceExercise(
    WorkoutSessionState current, {
    required Set<int> completedWorkoutExerciseIds,
    required Set<int> skippedWorkoutExerciseIds,
  }) {
    final cleared = current.copyWith(
      completedWorkoutExerciseIds: completedWorkoutExerciseIds,
      skippedWorkoutExerciseIds: skippedWorkoutExerciseIds,
      exerciseTimer: () => null,
      restTimer: () => null,
    );
    final next = cleared.isLastExercise
        ? cleared.copyWith(isCompleted: true)
        : cleared.copyWith(
            currentExerciseIndex: cleared.currentExerciseIndex + 1,
          );
    state = next;
    _persist(next);
  }

  /// Segna l'esercizio corrente come saltato (mai completato), azzera il
  /// suo progresso serie e avanza. Ferma sempre un eventuale timer o
  /// recupero in corso (sezione 16). Se l'esercizio è già risolto (visto
  /// tramite "Indietro"), si comporta come "vai al successivo".
  void skipCurrentExercise() {
    final current = state;
    if (current == null || current.isPaused || current.isCompleted) return;
    _stopTicker();

    if (_isAlreadyResolved(current)) {
      _advanceToNextExercise(current);
      return;
    }

    final id = current.currentWorkoutExerciseId;
    final skipped = {...current.skippedWorkoutExerciseIds, id};
    final completed = {...current.completedWorkoutExerciseIds}..remove(id);
    final resetSets = {...current.completedSetsByWorkoutExerciseId}..remove(id);

    _advanceExercise(
      current.copyWith(completedSetsByWorkoutExerciseId: resetSets),
      completedWorkoutExerciseIds: completed,
      skippedWorkoutExerciseIds: skipped,
    );
  }

  /// Torna all'esercizio precedente. Non riavvia mai automaticamente un
  /// timer (sezione 27): un eventuale countdown in corso sull'esercizio
  /// che si lascia viene fermato (andrà ripreso da capo con "Avvia serie"
  /// se e quando si torna avanti). Il progresso serie già completate
  /// resta invece intatto per tutti gli esercizi.
  void previousExercise() {
    final current = state;
    if (current == null ||
        current.isPaused ||
        current.currentExerciseIndex == 0) {
      return;
    }
    _stopTicker();
    final next = current.copyWith(
      currentExerciseIndex: current.currentExerciseIndex - 1,
      exerciseTimer: () => null,
      restTimer: () => null,
    );
    state = next;
    _persist(next);
  }

  /// In pausa si bloccano le normali azioni della sessione, e un
  /// eventuale timer/recupero in corso si congela (nessun secondo passa)
  /// senza perdere il residuo.
  void pause() {
    final current = state;
    if (current == null || current.isCompleted) return;
    _stopTicker();

    var next = current;
    final exerciseTimer = current.exerciseTimer;
    if (exerciseTimer != null) {
      next = next.copyWith(exerciseTimer: () => exerciseTimer.frozen(_clock));
    }
    final restTimer = current.restTimer;
    if (restTimer != null) {
      next = next.copyWith(restTimer: () => restTimer.frozen(_clock));
    }
    next = next.copyWith(isPaused: true);
    state = next;

    _guardedRepositoryCall(
      () => _repository.pauseSession(
        sessionId: next.sessionId,
        frozenTimer: _currentPersistedTimer(next),
        updatedAt: _clock.now(),
      ),
    );
  }

  /// Riprende dal residuo congelato (nessuna deriva): se un timer era in
  /// corso, ricomincia a scorrere da dove si era fermato.
  void resume() {
    final current = state;
    if (current == null) return;

    var next = current.copyWith(isPaused: false);
    final exerciseTimer = current.exerciseTimer;
    final restTimer = current.restTimer;
    if (exerciseTimer != null) {
      next = next.copyWith(exerciseTimer: () => exerciseTimer.resumed(_clock));
      _startTicker();
    } else if (restTimer != null) {
      next = next.copyWith(restTimer: () => restTimer.resumed(_clock));
      _startTicker();
    }
    state = next;

    _guardedRepositoryCall(
      () => _repository.resumeSession(
        sessionId: next.sessionId,
        resumedTimer: _currentPersistedTimer(next),
        updatedAt: _clock.now(),
      ),
    );
  }

  /// Chiusura normale (dal riepilogo finale, dopo "Fine"): pulisce la
  /// sessione, libera lo slot per una nuova. Nessuna scrittura DB qui: la
  /// riga è già stata segnata `COMPLETED` nell'istante in cui
  /// `state.isCompleted` è diventato vero (dentro [_persist], chiamato da
  /// [_advanceExercise]) — non quando l'utente preme "Fine" (sezione 39:
  /// il record non deve mai dipendere da quel tap, altrimenti un'app
  /// terminata tra il riepilogo e "Fine" lascerebbe la sessione
  /// erroneamente "in corso" per sempre).
  void finish() {
    _stopTicker();
    state = null;
  }

  /// Uscita anticipata (conferma del dialog "Vuoi uscire
  /// dall'allenamento?"): pulisce subito lo stato runtime (la UI non deve
  /// aspettare l'I/O per uscire) e segna `ABORTED` sul record in modo
  /// fire-and-forget, come tutte le altre scritture di questo controller.
  void abort() {
    final current = state;
    _stopTicker();
    state = null;
    if (current == null) return;
    _guardedRepositoryCall(
      () => _repository.abortSession(
        sessionId: current.sessionId,
        endedAt: _clock.now(),
      ),
    );
  }

  PersistedSessionTimer? _currentPersistedTimer(WorkoutSessionState state) {
    final exerciseTimer = state.exerciseTimer;
    if (exerciseTimer != null) {
      return PersistedSessionTimer(
        kind: PersistedSessionTimerKind.exercise,
        startedAt: exerciseTimer.startedAt,
        targetSeconds: exerciseTimer.targetSeconds,
        remainingPaused: exerciseTimer.pausedRemainingSeconds,
      );
    }
    final restTimer = state.restTimer;
    if (restTimer != null) {
      return PersistedSessionTimer(
        kind: PersistedSessionTimerKind.rest,
        startedAt: restTimer.startedAt,
        targetSeconds: restTimer.targetSeconds,
        remainingPaused: restTimer.pausedRemainingSeconds,
      );
    }
    return null;
  }

  /// Persiste indice esercizio, timer attivo e progresso serie di ogni
  /// riga in un'unica scrittura (sezione 14: sempre dopo un evento, mai a
  /// ogni tick). Se [state] è appena diventato completo, marca anche la
  /// sessione `COMPLETED` (sezione 38) — non aspetta che l'utente prema
  /// "Fine" (vedi [finish]).
  void _persist(WorkoutSessionState state) {
    final timer = _currentPersistedTimer(state);
    final exercises = state.exercises
        .map(
          (e) => SessionExerciseProgressUpdate(
            workoutExerciseId: e.workoutExercise.id!,
            completedSets:
                state.completedSetsByWorkoutExerciseId[e.workoutExercise.id] ??
                0,
            isSkipped: state.skippedWorkoutExerciseIds.contains(
              e.workoutExercise.id,
            ),
            isCompleted: state.completedWorkoutExerciseIds.contains(
              e.workoutExercise.id,
            ),
          ),
        )
        .toList();

    _guardedRepositoryCall(() async {
      await _repository.updateProgress(
        sessionId: state.sessionId,
        currentExerciseIndex: state.currentExerciseIndex,
        exercises: exercises,
        timer: () => timer,
        updatedAt: _clock.now(),
      );
      if (state.isCompleted) {
        await _repository.completeSession(
          sessionId: state.sessionId,
          endedAt: _clock.now(),
        );
      }
    });
  }

  /// Esegue [call] senza farla mai attendere dal chiamante (fire-and-forget,
  /// vedi commento di classe): un errore di persistenza viene solo
  /// loggato, non deve mai far crashare la sessione runtime in corso.
  void _guardedRepositoryCall(Future<void> Function() call) {
    unawaited(
      call().catchError((Object error, StackTrace stackTrace) {
        debugPrint('Errore nel persistere la sessione: $error');
      }),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final workoutSessionControllerProvider =
    NotifierProvider<WorkoutSessionController, WorkoutSessionState?>(
      WorkoutSessionController.new,
    );
