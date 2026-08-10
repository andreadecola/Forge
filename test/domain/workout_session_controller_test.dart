import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/repositories/workout_session_providers.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/persisted_session_timer.dart';
import 'package:forge/domain/entities/persisted_workout_session.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_details.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_exercise_details.dart';
import 'package:forge/domain/entities/workout_session_history_details.dart';
import 'package:forge/domain/entities/workout_session_history_item.dart';
import 'package:forge/domain/repositories/workout_session_repository.dart';
import 'package:forge/features/training_plan/application/workout_session_clock.dart';
import 'package:forge/features/training_plan/application/workout_session_controller.dart';
import 'package:forge/features/training_plan/application/workout_session_phase.dart';
import 'package:forge/features/training_plan/application/workout_session_state.dart';

/// Qualunque istanza si comporta uguale (delega a `DateTime.now()`, che
/// dentro `FakeAsync().run(...)` è già intercettato): serve solo per
/// leggere `remainingSeconds` nelle asserzioni.
const _clock = SystemSessionClock();

/// Repository fittizio in memoria (Milestone 4.4.3): qui interessa solo
/// che il controller *chiami* il repository nei punti giusti e propaghi
/// l'id di sessione — la correttezza delle scritture reali sul DB è
/// verificata separatamente da `workout_session_repository_test.dart`
/// (con `DriftWorkoutSessionRepository` vero) e da
/// `workout_session_controller_persistence_test.dart`. Nessuna dipendenza
/// da un database reale qui: mantiene questi test rapidi e concentrati
/// sul comportamento runtime (sezione 45 — niente attese reali, e niente
/// I/O reale necessario per verificarlo).
class _FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  int _nextId = 1;
  int? _activeSessionId;

  int createSessionCalls = 0;
  int updateProgressCalls = 0;
  int pauseSessionCalls = 0;
  int resumeSessionCalls = 0;
  int abortSessionCalls = 0;
  int completeSessionCalls = 0;
  List<SessionExerciseProgressUpdate>? lastExerciseUpdates;
  PersistedSessionTimer? lastTimer;

  @override
  Future<int> createSession({
    required int profileId,
    required WorkoutDetails details,
    required DateTime startedAt,
  }) async {
    createSessionCalls++;
    if (_activeSessionId != null) {
      throw ActiveSessionAlreadyExistsException(_activeSessionId!);
    }
    final id = _nextId++;
    _activeSessionId = id;
    return id;
  }

  @override
  Future<PersistedWorkoutSession?> getActiveSession({
    required int profileId,
  }) async => null;

  @override
  Future<PersistedWorkoutSession?> getSessionById(int sessionId) async => null;

  @override
  Future<List<PersistedSessionExercise>> getSessionExercises(
    int sessionId,
  ) async => const [];

  @override
  Future<void> updateProgress({
    required int sessionId,
    int? currentExerciseIndex,
    List<SessionExerciseProgressUpdate> exercises = const [],
    PersistedSessionTimer? Function()? timer,
    required DateTime updatedAt,
  }) async {
    updateProgressCalls++;
    lastExerciseUpdates = exercises;
    if (timer != null) lastTimer = timer();
  }

  @override
  Future<void> updateTimerState({
    required int sessionId,
    PersistedSessionTimer? timer,
    required DateTime updatedAt,
  }) async {}

  @override
  Future<void> pauseSession({
    required int sessionId,
    PersistedSessionTimer? frozenTimer,
    required DateTime updatedAt,
  }) async {
    pauseSessionCalls++;
  }

  @override
  Future<void> resumeSession({
    required int sessionId,
    PersistedSessionTimer? resumedTimer,
    required DateTime updatedAt,
  }) async {
    resumeSessionCalls++;
  }

  @override
  Future<void> completeSession({
    required int sessionId,
    required DateTime endedAt,
  }) async {
    completeSessionCalls++;
  }

  @override
  Future<void> abortSession({
    required int sessionId,
    required DateTime endedAt,
  }) async {
    abortSessionCalls++;
    _activeSessionId = null;
  }

  @override
  Future<List<WorkoutSessionHistoryItem>> getSessionHistory({
    required int profileId,
    DateTime? since,
  }) async => const [];

  @override
  Stream<List<WorkoutSessionHistoryItem>> watchSessionHistory({
    required int profileId,
    DateTime? since,
  }) => const Stream.empty();

  @override
  Future<WorkoutSessionHistoryDetails?> getSessionHistoryDetails(
    int sessionId,
  ) async => null;
}

Workout _workout({int workoutId = 1, String name = 'Scheda'}) {
  return Workout(
    id: workoutId,
    profileId: 1,
    name: name,
    type: WorkoutType.fullBody,
    status: WorkoutDefinitionStatus.ready,
    origin: WorkoutOrigin.user,
  );
}

Exercise _exercise({int id = 1, String name = 'Esercizio'}) {
  return Exercise(
    id: id,
    code: 'X-$id',
    name: name,
    description: 'desc',
    instructions: 'istr',
    categoryId: 1,
    minimumLevel: 1,
    impactLevel: ExerciseImpactLevel.low,
    balanceRequired: false,
    floorRequired: false,
    standingRequired: false,
    supportAllowed: false,
    isSystem: true,
    isActive: true,
    catalogVersion: 1,
  );
}

/// Riga scheda a ripetizioni.
WorkoutExerciseDetails _repsEntry({
  required int workoutExerciseId,
  required int exerciseId,
  int order = 1,
  int? sets = 3,
  int? repetitions = 10,
  int? restSeconds,
  String name = 'Esercizio',
}) {
  return WorkoutExerciseDetails(
    workoutExercise: WorkoutExercise(
      id: workoutExerciseId,
      workoutId: 1,
      exerciseId: exerciseId,
      order: order,
      sets: sets,
      repetitions: repetitions,
      restSeconds: restSeconds,
    ),
    exercise: _exercise(id: exerciseId, name: name),
  );
}

/// Riga scheda a tempo.
WorkoutExerciseDetails _timedEntry({
  required int workoutExerciseId,
  required int exerciseId,
  int order = 1,
  int sets = 2,
  int durationSeconds = 30,
  int? restSeconds,
  String name = 'Esercizio a tempo',
}) {
  return WorkoutExerciseDetails(
    workoutExercise: WorkoutExercise(
      id: workoutExerciseId,
      workoutId: 1,
      exerciseId: exerciseId,
      order: order,
      sets: sets,
      durationSeconds: durationSeconds,
      restSeconds: restSeconds,
    ),
    exercise: _exercise(id: exerciseId, name: name),
  );
}

WorkoutDetails _details({
  int workoutId = 1,
  String name = 'Scheda',
  required List<WorkoutExerciseDetails> exercises,
}) {
  return WorkoutDetails(
    workout: _workout(workoutId: workoutId, name: name),
    exercises: exercises,
  );
}

void main() {
  // Ogni test gira dentro FakeAsync: il `Timer.periodic` interno al
  // controller (Milestone 4.4.2) diventa un timer finto, avanzabile
  // istantaneamente con `async.elapse(...)` — nessun test aspetta secondi
  // reali (sezione 45/46). `SystemSessionClock` (il default di
  // produzione) funziona qui senza bisogno di override: `DateTime.now()`
  // dentro una zona FakeAsync è già intercettato e avanza insieme al
  // timer. Un `flushMicrotasks()` finale drena le scritture di
  // persistenza fire-and-forget (Milestone 4.4.3) prima che la zona finta
  // si chiuda, così nessun microtask resta agganciato a una zona già
  // terminata.
  void runTest(String description, void Function(FakeAsync async) body) {
    test(description, () {
      FakeAsync().run((async) {
        body(async);
        async.flushMicrotasks();
      });
    });
  }

  late ProviderContainer container;
  late _FakeWorkoutSessionRepository repository;
  WorkoutSessionController controller() =>
      container.read(workoutSessionControllerProvider.notifier);
  WorkoutSessionState? state() =>
      container.read(workoutSessionControllerProvider);

  void setUpContainer() {
    repository = _FakeWorkoutSessionRepository();
    container = ProviderContainer(
      overrides: [
        workoutSessionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  }

  /// `startSession` è `Future<bool>` da quando crea la riga persistita
  /// prima di inizializzare lo stato runtime (Milestone 4.4.3, sezione
  /// 15): qui non serve mai un vero `await` dentro `FakeAsync` (il
  /// callback di `run()` non è `async`) — basta far girare il microtask
  /// che la risolve.
  bool start(FakeAsync async, WorkoutDetails details) {
    var result = false;
    unawaited(controller().startSession(details).then((r) => result = r));
    async.flushMicrotasks();
    return result;
  }

  runTest('startSession crea la sessione al primo esercizio', (async) {
    setUpContainer();

    final entryA = _repsEntry(workoutExerciseId: 10, exerciseId: 1, order: 1);
    final entryB = _repsEntry(workoutExerciseId: 11, exerciseId: 2, order: 2);
    final started = start(async, _details(exercises: [entryA, entryB]));

    expect(started, isTrue);
    final s = state()!;
    expect(s.workoutId, 1);
    expect(s.sessionId, 1, reason: 'id assegnato dal repository fittizio');
    expect(s.currentExerciseIndex, 0);
    expect(s.totalExercises, 2);
    expect(s.phase, WorkoutSessionPhase.readySet);
    expect(s.currentTotalSets, 3);
    expect(s.currentCompletedSets, 0);
    expect(repository.createSessionCalls, 1);
  });

  group('test 34 — esercizio a ripetizioni', () {
    runTest('set 1/3 -> completa -> set 2 -> completa -> set 3 -> completa -> '
        'esercizio completato', (async) {
      setUpContainer();

      final entry = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 3,
        repetitions: 10,
        restSeconds: null,
      );
      start(async, _details(exercises: [entry]));

      expect(state()!.currentCompletedSets, 0);

      controller().completeCurrentSet();
      expect(state()!.currentCompletedSets, 1);
      expect(state()!.phase, WorkoutSessionPhase.readySet);
      expect(state()!.isCompleted, isFalse);

      controller().completeCurrentSet();
      expect(state()!.currentCompletedSets, 2);

      controller().completeCurrentSet();
      final s = state()!;
      expect(s.isCompleted, isTrue);
      expect(s.completedWorkoutExerciseIds, {10});
    });
  });

  group('test 35 — recupero', () {
    runTest('dopo una serie con restSeconds > 0 -> fase RESTING con il residuo '
        'giusto; salta recupero -> READY_SET', (async) {
      setUpContainer();

      final entry = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 2,
        repetitions: 10,
        restSeconds: 60,
      );
      start(async, _details(exercises: [entry]));

      controller().completeCurrentSet();
      final resting = state()!;
      expect(resting.phase, WorkoutSessionPhase.resting);
      expect(resting.restTimer!.remainingSeconds(_clock), 60);
      expect(
        resting.currentCompletedSets,
        1,
        reason: 'la serie 1 resta comunque contata',
      );

      controller().skipRest();
      final ready = state()!;
      expect(ready.phase, WorkoutSessionPhase.readySet);
      expect(ready.restTimer, isNull);
      expect(ready.currentCompletedSets, 1);
    });
  });

  group('test 36 — nessun recupero', () {
    for (final restSeconds in [null, 0]) {
      runTest('restSeconds = $restSeconds -> serie successiva immediata', (
        async,
      ) {
        setUpContainer();

        final entry = _repsEntry(
          workoutExerciseId: 10,
          exerciseId: 1,
          sets: 2,
          repetitions: 10,
          restSeconds: restSeconds,
        );
        start(async, _details(exercises: [entry]));

        controller().completeCurrentSet();
        final s = state()!;
        expect(s.phase, WorkoutSessionPhase.readySet);
        expect(s.restTimer, isNull);
        expect(s.currentCompletedSets, 1);
      });
    }
  });

  group('test 37 — esercizio a tempo', () {
    runTest('avvia serie -> running; countdown a zero -> serie completata -> '
        'recupero; recupero a zero -> serie 2 pronta', (async) {
      setUpContainer();

      final entry = _timedEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 2,
        durationSeconds: 30,
        restSeconds: 20,
      );
      start(async, _details(exercises: [entry]));

      controller().startTimedSet();
      expect(state()!.phase, WorkoutSessionPhase.timedSetRunning);
      expect(state()!.exerciseTimer!.remainingSeconds(_clock), 30);

      async.elapse(const Duration(seconds: 30));

      final afterFirstSet = state()!;
      expect(afterFirstSet.phase, WorkoutSessionPhase.resting);
      expect(afterFirstSet.currentCompletedSets, 1);
      expect(afterFirstSet.restTimer!.remainingSeconds(_clock), 20);

      async.elapse(const Duration(seconds: 20));

      final readyForSet2 = state()!;
      expect(readyForSet2.phase, WorkoutSessionPhase.readySet);
      expect(readyForSet2.currentCompletedSets, 1);
      // Sezione 12: il timer della serie 2 NON parte da solo.
      expect(readyForSet2.exerciseTimer, isNull);
    });
  });

  group('test 38 — pausa durante serie a tempo', () {
    runTest('il residuo resta invariato, poi riprende da lì', (async) {
      setUpContainer();

      final entry = _timedEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 1,
        durationSeconds: 30,
      );
      start(async, _details(exercises: [entry]));
      controller().startTimedSet();

      async.elapse(const Duration(seconds: 10));
      controller().pause();
      final paused = state()!;
      expect(paused.phase, WorkoutSessionPhase.paused);
      expect(paused.exerciseTimer!.remainingSeconds(_clock), 20);
      expect(repository.pauseSessionCalls, 1);

      async.elapse(const Duration(minutes: 5)); // il tempo passa, ma è in pausa
      expect(state()!.exerciseTimer!.remainingSeconds(_clock), 20);

      controller().resume();
      expect(state()!.phase, WorkoutSessionPhase.timedSetRunning);
      expect(state()!.exerciseTimer!.remainingSeconds(_clock), 20);
      expect(repository.resumeSessionCalls, 1);

      async.elapse(const Duration(seconds: 20));
      expect(state()!.isCompleted, isTrue);
    });
  });

  group('test 39 — pausa durante il recupero', () {
    runTest('stessa logica del countdown esercizio', (async) {
      setUpContainer();

      final entry = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 2,
        restSeconds: 60,
      );
      start(async, _details(exercises: [entry]));
      controller().completeCurrentSet();

      async.elapse(const Duration(seconds: 15));
      controller().pause();
      expect(state()!.restTimer!.remainingSeconds(_clock), 45);

      async.elapse(const Duration(minutes: 2));
      expect(state()!.restTimer!.remainingSeconds(_clock), 45);

      controller().resume();
      expect(state()!.phase, WorkoutSessionPhase.resting);
      async.elapse(const Duration(seconds: 45));
      expect(state()!.phase, WorkoutSessionPhase.readySet);
    });
  });

  group('test 40 — salta esercizio con timer in corso', () {
    runTest('il timer viene annullato, l\'esercizio è saltato, il successivo è '
        'pronto', (async) {
      setUpContainer();

      final entryA = _timedEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 2,
        durationSeconds: 30,
      );
      final entryB = _repsEntry(workoutExerciseId: 11, exerciseId: 2);
      start(async, _details(exercises: [entryA, entryB]));
      controller().startTimedSet();
      async.elapse(const Duration(seconds: 5));

      controller().skipCurrentExercise();

      final s = state()!;
      expect(s.currentExerciseIndex, 1);
      expect(s.skippedWorkoutExerciseIds, {10});
      expect(s.exerciseTimer, isNull);
      expect(s.phase, WorkoutSessionPhase.readySet);

      // Il vecchio timer non deve più produrre alcun effetto: far
      // avanzare il tempo non deve cambiare nulla (nessun Timer
      // rimasto vivo dopo skip, sezione 29).
      final before = state();
      async.elapse(const Duration(seconds: 60));
      expect(state(), same(before));
    });
  });

  group('test 41 — sets null', () {
    runTest('a runtime viene trattato come 1 serie, senza toccare il DB', (
      async,
    ) {
      setUpContainer();

      final entry = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: null,
        repetitions: 8,
      );
      start(async, _details(exercises: [entry]));

      expect(state()!.currentTotalSets, 1);
      // L'oggetto WorkoutExercise originale non viene mai riscritto: il
      // fallback resta un fatto puramente di lettura runtime.
      expect(entry.workoutExercise.sets, isNull);

      controller().completeCurrentSet();
      expect(state()!.isCompleted, isTrue);
    });
  });

  group('test 42 — esercizi duplicati', () {
    runTest('stesso exerciseId, WorkoutExercise.id diversi: le serie sono '
        'indipendenti', (async) {
      setUpContainer();

      final entryA = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        order: 1,
        sets: 3,
        restSeconds: null,
        name: 'Curl',
      );
      final entryB = _repsEntry(
        workoutExerciseId: 11,
        exerciseId: 1,
        order: 2,
        sets: 3,
        restSeconds: null,
        name: 'Curl',
      );
      start(async, _details(exercises: [entryA, entryB]));

      controller().completeCurrentSet();
      controller().completeCurrentSet();
      expect(state()!.completedSetsByWorkoutExerciseId[10], 2);
      expect(
        state()!.completedSetsByWorkoutExerciseId.containsKey(11),
        isFalse,
      );

      controller().completeCurrentSet(); // completa la 3ª serie di A
      final afterA = state()!;
      expect(afterA.completedWorkoutExerciseIds, {10});
      expect(afterA.currentExerciseIndex, 1);
      expect(afterA.currentWorkoutExerciseId, 11);
      expect(afterA.currentCompletedSets, 0);

      controller().completeCurrentSet();
      expect(state()!.completedSetsByWorkoutExerciseId[11], 1);
      expect(
        state()!.completedSetsByWorkoutExerciseId[10],
        3,
        reason: 'il conteggio finale di A (10) resta 3, indipendente da B (11)',
      );
    });
  });

  group('test 43 — previous con esercizio parziale', () {
    runTest(
      'il progresso serie di un esercizio non risolto resta intatto anche '
      'allontanandosene con "Indietro"',
      (async) {
        setUpContainer();

        final entryA = _repsEntry(
          workoutExerciseId: 10,
          exerciseId: 1,
          order: 1,
        );
        final entryB = _repsEntry(
          workoutExerciseId: 11,
          exerciseId: 2,
          order: 2,
          sets: 3,
          restSeconds: null,
        );
        start(async, _details(exercises: [entryA, entryB]));

        // Risolve A per poter avanzare a B senza toccarne le serie.
        controller().completeCurrentSet();
        controller().completeCurrentSet();
        controller().completeCurrentSet();
        expect(state()!.currentWorkoutExerciseId, 11);

        // B: 2 serie su 3, ancora NON risolto (né completato né saltato).
        controller().completeCurrentSet();
        controller().completeCurrentSet();
        expect(state()!.currentCompletedSets, 2);
        expect(state()!.completedWorkoutExerciseIds.contains(11), isFalse);

        controller().previousExercise(); // torna ad A
        expect(state()!.currentWorkoutExerciseId, 10);
        // Il progresso di B (non quello corrente) resta comunque
        // memorizzato, indipendentemente da dove ci si trovi ora.
        expect(state()!.completedSetsByWorkoutExerciseId[11], 2);
      },
    );
  });

  group('test 44 — fine sessione', () {
    runTest('l\'ultima serie dell\'ultimo esercizio completa la sessione con i '
        'conteggi corretti', (async) {
      setUpContainer();

      final entryA = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 1,
        order: 1,
      );
      final entryB = _repsEntry(
        workoutExerciseId: 11,
        exerciseId: 2,
        sets: 1,
        order: 2,
      );
      start(async, _details(exercises: [entryA, entryB]));

      controller().skipCurrentExercise(); // A saltato
      controller().completeCurrentSet(); // B, ultimo -> fine sessione

      final s = state()!;
      expect(s.isCompleted, isTrue);
      expect(s.completedWorkoutExerciseIds, {11});
      expect(s.skippedWorkoutExerciseIds, {10});
      async.flushMicrotasks();
      expect(
        repository.completeSessionCalls,
        1,
        reason:
            'la riga è marcata COMPLETED nell\'istante in cui la '
            'sessione risulta completa, non quando si preme "Fine" '
            '(Milestone 4.4.3, sezione 39)',
      );
    });
  });

  group('altri comportamenti già validi dalla Milestone 4.4.1', () {
    runTest('abort pulisce la sessione, ferma il ticker e marca ABORTED', (
      async,
    ) {
      setUpContainer();

      final entry = _timedEntry(workoutExerciseId: 10, exerciseId: 1);
      start(async, _details(exercises: [entry]));
      controller().startTimedSet();

      controller().abort();
      expect(state(), isNull);

      // Nessun timer sopravvive: far passare del tempo non deve ricreare
      // uno stato dal nulla né lanciare eccezioni.
      async.elapse(const Duration(seconds: 60));
      expect(state(), isNull);
      async.flushMicrotasks();
      expect(repository.abortSessionCalls, 1);
    });

    runTest('finish pulisce la sessione senza scrivere di nuovo sul DB', (
      async,
    ) {
      setUpContainer();

      final entry = _repsEntry(workoutExerciseId: 10, exerciseId: 1, sets: 1);
      start(async, _details(exercises: [entry]));
      controller().completeCurrentSet();
      expect(state()!.isCompleted, isTrue);
      async.flushMicrotasks();
      expect(repository.completeSessionCalls, 1);

      controller().finish();
      expect(state(), isNull);
      async.flushMicrotasks();
      expect(
        repository.completeSessionCalls,
        1,
        reason:
            '"Fine" non deve produrre una seconda scrittura: la riga è '
            'già COMPLETED da quando la sessione è risultata completa',
      );
    });

    runTest('una sola sessione attiva: la seconda richiesta non sostituisce la '
        'prima', (async) {
      setUpContainer();

      final startedFirst = start(
        async,
        _details(
          workoutId: 1,
          name: 'Scheda A',
          exercises: [_repsEntry(workoutExerciseId: 10, exerciseId: 1)],
        ),
      );
      final startedSecond = start(
        async,
        _details(
          workoutId: 2,
          name: 'Scheda B',
          exercises: [_repsEntry(workoutExerciseId: 20, exerciseId: 2)],
        ),
      );

      expect(startedFirst, isTrue);
      expect(startedSecond, isFalse);
      expect(state()!.workoutName, 'Scheda A');
    });
  });

  group('Milestone 4.4.3 — persistenza (wiring)', () {
    runTest('completeCurrentSet persiste il progresso della riga corrente', (
      async,
    ) {
      setUpContainer();

      final entry = _repsEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        sets: 3,
        restSeconds: null,
      );
      start(async, _details(exercises: [entry]));

      controller().completeCurrentSet();
      async.flushMicrotasks();

      expect(repository.updateProgressCalls, 1);
      final update = repository.lastExerciseUpdates!.single;
      expect(update.workoutExerciseId, 10);
      expect(update.completedSets, 1);
      expect(update.isCompleted, isFalse);
      expect(update.isSkipped, isFalse);
    });

    runTest('startTimedSet persiste il timer avviato', (async) {
      setUpContainer();

      final entry = _timedEntry(
        workoutExerciseId: 10,
        exerciseId: 1,
        durationSeconds: 30,
      );
      start(async, _details(exercises: [entry]));

      controller().startTimedSet();
      async.flushMicrotasks();

      expect(repository.lastTimer, isNotNull);
      expect(repository.lastTimer!.targetSeconds, 30);
    });
  });
}
