import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';

import 'workout_test_helpers.dart';

/// Test di repository per lo storico sessioni (Milestone 4.5.1): usa un
/// `DriftWorkoutSessionRepository` vero su un database SQLite in memoria
/// — copre sezioni 37-41 dello spec.
void main() {
  late AppDatabase database;
  late DriftWorkoutRepository workoutRepository;
  late DriftWorkoutSessionRepository sessionRepository;
  late int profileId;
  late int workoutId;
  late int workoutExerciseId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    workoutRepository = DriftWorkoutRepository(database);
    sessionRepository = DriftWorkoutSessionRepository(database);

    profileId = await insertProfilo(database);
    final categoryId = await insertCategoria(database);
    final exerciseId = await insertEsercizio(
      database,
      codice: 'HIST-001',
      idCategoria: categoryId,
    );

    workoutId = await workoutRepository.createWorkout(
      Workout(
        profileId: profileId,
        name: 'Scheda storico',
        type: WorkoutType.fullBody,
        status: WorkoutDefinitionStatus.ready,
        origin: WorkoutOrigin.user,
      ),
    );
    workoutExerciseId = await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: 1,
        sets: 2,
        repetitions: 10,
      ),
    );
  });

  tearDown(() => database.close());

  Future<int> startSession({required DateTime startedAt}) async {
    final details = (await workoutRepository.getWorkoutDetails(workoutId))!;
    return sessionRepository.createSession(
      profileId: profileId,
      details: details,
      startedAt: startedAt,
    );
  }

  test('getSessionHistory restituisce solo COMPLETED/ABORTED, non '
      'IN_PROGRESS/PAUSED', () async {
    final completedId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.completeSession(
      sessionId: completedId,
      endedAt: DateTime(2026, 1, 1, 0, 30),
    );

    final history = await sessionRepository.getSessionHistory(
      profileId: profileId,
    );
    expect(history, hasLength(1));
    expect(history.single.sessionId, completedId);
    expect(history.single.status, WorkoutSessionPersistenceStatus.completed);
  });

  test('ordine cronologico: più recente prima (dataInizio DESC)', () async {
    final oldest = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.abortSession(
      sessionId: oldest,
      endedAt: DateTime(2026, 1, 1, 0, 10),
    );

    // Serve una seconda sessione: la prima è già conclusa (ABORTED), può
    // essercene una nuova per lo stesso profilo.
    final newest = await startSession(startedAt: DateTime(2026, 1, 3));
    await sessionRepository.completeSession(
      sessionId: newest,
      endedAt: DateTime(2026, 1, 3, 0, 20),
    );

    final history = await sessionRepository.getSessionHistory(
      profileId: profileId,
    );
    expect(history.map((h) => h.sessionId).toList(), [newest, oldest]);
  });

  test(
    'sessione COMPLETED: conteggi esercizi completati/saltati corretti',
    () async {
      final sessionId = await startSession(startedAt: DateTime(2026, 1, 1));
      await sessionRepository.updateProgress(
        sessionId: sessionId,
        exercises: [
          SessionExerciseProgressUpdate(
            workoutExerciseId: workoutExerciseId,
            completedSets: 2,
            isSkipped: false,
            isCompleted: true,
          ),
        ],
        updatedAt: DateTime(2026, 1, 1, 0, 5),
      );
      await sessionRepository.completeSession(
        sessionId: sessionId,
        endedAt: DateTime(2026, 1, 1, 0, 10),
      );

      final history = await sessionRepository.getSessionHistory(
        profileId: profileId,
      );
      final item = history.single;
      expect(item.totalExercises, 1);
      expect(item.completedExercises, 1);
      expect(item.skippedExercises, 0);
      expect(item.finishedAt, DateTime(2026, 1, 1, 0, 10));
    },
  );

  test('sessione ABORTED: progresso parziale raggiunto rappresentato '
      'correttamente (nessun esercizio risolto)', () async {
    final sessionId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.updateProgress(
      sessionId: sessionId,
      exercises: [
        SessionExerciseProgressUpdate(
          workoutExerciseId: workoutExerciseId,
          completedSets: 1,
          isSkipped: false,
          isCompleted: false,
        ),
      ],
      updatedAt: DateTime(2026, 1, 1, 0, 3),
    );
    await sessionRepository.abortSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 1, 1, 0, 5),
    );

    final history = await sessionRepository.getSessionHistory(
      profileId: profileId,
    );
    final item = history.single;
    expect(item.status, WorkoutSessionPersistenceStatus.aborted);
    expect(item.completedExercises, 0);
    expect(item.skippedExercises, 0);

    final details = await sessionRepository.getSessionHistoryDetails(sessionId);
    final exercise = details!.exercises.single;
    expect(exercise.completedSets, 1);
    expect(exercise.isCompleted, isFalse);
    expect(exercise.isSkipped, isFalse);
  });

  test('getSessionHistoryDetails risolve il nome esercizio dal catalogo e '
      'ordina le righe per ordine crescente', () async {
    final categoryId = await insertCategoria(database, codice: 'HIST-CAT2');
    final secondExerciseId = await insertEsercizio(
      database,
      codice: 'HIST-002',
      idCategoria: categoryId,
    );
    await workoutRepository.addExercise(
      workoutId: workoutId,
      exercise: WorkoutExercise(
        workoutId: workoutId,
        exerciseId: secondExerciseId,
        order: 2,
        sets: 1,
        durationSeconds: 20,
      ),
    );

    final sessionId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 1, 1, 0, 10),
    );

    final details = await sessionRepository.getSessionHistoryDetails(sessionId);
    expect(details!.exercises, hasLength(2));
    expect(details.exercises[0].order, 1);
    expect(details.exercises[0].exerciseName, 'Esercizio HIST-001');
    expect(details.exercises[1].order, 2);
    expect(details.exercises[1].exerciseName, 'Esercizio HIST-002');
    expect(details.exercises[1].durationSeconds, 20);
  });

  test('snapshot dei parametri: modificare la scheda live dopo la sessione '
      'non cambia lo storico (sezione 22/23)', () async {
    final sessionId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 1, 1, 0, 10),
    );

    // La scheda viene modificata *dopo* la sessione: 2x10 diventa 3x15.
    final row = await database.allenamentiEserciziDao.getById(
      workoutExerciseId,
    );
    await workoutRepository.updateExercise(
      WorkoutExercise(
        id: workoutExerciseId,
        workoutId: workoutId,
        exerciseId: row!.idEsercizio,
        order: row.ordine,
        sets: 3,
        repetitions: 15,
      ),
    );

    final details = await sessionRepository.getSessionHistoryDetails(sessionId);
    final exercise = details!.exercises.single;
    expect(
      exercise.totalSets,
      2,
      reason:
          'lo storico mostra i parametri con cui è iniziata la '
          'sessione, non quelli attuali della scheda',
    );
    expect(exercise.repetitions, 10);
  });

  test('scheda eliminata dopo la sessione: lo storico resta disponibile con '
      'il nome snapshot, nessun errore (sezione 24/25)', () async {
    final sessionId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.completeSession(
      sessionId: sessionId,
      endedAt: DateTime(2026, 1, 1, 0, 10),
    );

    await workoutRepository.deleteWorkout(workoutId);

    final history = await sessionRepository.getSessionHistory(
      profileId: profileId,
    );
    final item = history.single;
    expect(item.workoutId, isNull);
    expect(item.workoutName, 'Scheda storico');

    final details = await sessionRepository.getSessionHistoryDetails(sessionId);
    expect(details, isNotNull);
    expect(details!.exercises.single.workoutExerciseId, isNull);
    expect(
      details.exercises.single.exerciseName,
      'Esercizio HIST-001',
      reason:
          'il nome esercizio si risolve dal catalogo (idEsercizio), '
          'indipendente dalla riga scheda eliminata',
    );
  });

  test('`since` limita la query alle sessioni con dataInizio >= since '
      '(Milestone 4.5.2, sezione 40)', () async {
    final oldId = await startSession(startedAt: DateTime(2026, 1, 1));
    await sessionRepository.completeSession(
      sessionId: oldId,
      endedAt: DateTime(2026, 1, 1, 0, 10),
    );
    final recentId = await startSession(startedAt: DateTime(2026, 6, 1));
    await sessionRepository.completeSession(
      sessionId: recentId,
      endedAt: DateTime(2026, 6, 1, 0, 10),
    );

    final filtered = await sessionRepository.getSessionHistory(
      profileId: profileId,
      since: DateTime(2026, 3, 1),
    );
    expect(filtered.map((h) => h.sessionId).toList(), [recentId]);

    final unfiltered = await sessionRepository.getSessionHistory(
      profileId: profileId,
    );
    expect(unfiltered, hasLength(2));
  });
}
