import 'package:drift/drift.dart';
import '../../domain/entities/walking_session.dart';
import '../../domain/entities/walking_session_status.dart';
import '../../domain/entities/workout_walking_block.dart';
import 'drift_walking_session_repository.dart';
import '../../domain/entities/persisted_session_exercise.dart';
import '../../domain/entities/persisted_session_timer.dart';
import '../../domain/entities/persisted_workout_session.dart';
import '../../domain/entities/workout_details.dart';
import '../../domain/entities/workout_session_history_details.dart';
import '../../domain/entities/workout_session_history_item.dart';
import '../../domain/entities/workout_session_persistence_status.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../database/app_database.dart';
import 'workout_session_mappers.dart';

class DriftWorkoutSessionRepository implements WorkoutSessionRepository {
  DriftWorkoutSessionRepository(this.db);

  final AppDatabase db;

  @override
  Future<WalkingSession?> getWalkingBlockSession(int sessionId) async {
    final session = await getSessionById(sessionId);
    final id = session?.walkingSessionId;
    return id == null
        ? null
        : DriftWalkingSessionRepository(db).getWalkingSession(id);
  }

  @override
  Future<WalkingSession> startWalkingBlock({
    required int sessionId,
    required DateTime startedAt,
  }) => db.transaction(() async {
    final session = await getSessionById(sessionId);
    final block = session?.walkingBlock;
    if (session == null ||
        block == null ||
        !['IN_PROGRESS', 'PAUSED'].contains(session.status.code)) {
      throw StateError('Nessuna camminata prevista nella sessione attiva.');
    }
    final walking = DriftWalkingSessionRepository(db);
    final existing = await getWalkingBlockSession(sessionId);
    if (existing != null && existing.status != WalkingSessionStatus.aborted) {
      return existing;
    }
    final snapshots = await getSessionExercises(sessionId);
    if (block.placement == WalkingPlacement.afterExercises &&
        snapshots.any((e) => !e.isCompleted && !e.isSkipped)) {
      throw StateError('Completa gli esercizi prima della camminata.');
    }
    if (await walking.getActiveWalkingSession(profileId: session.profileId) !=
        null) {
      throw StateError(
        'È già in corso un’altra camminata. Termina quella prima di iniziare questa fase.',
      );
    }
    final id = await walking.createWalkingSession(
      WalkingSession(
        profileId: session.profileId,
        startedAt: startedAt,
        status: WalkingSessionStatus.inProgress,
      ),
    );
    await (db.update(
      db.sessioniAllenamentoTable,
    )..where((t) => t.id.equals(sessionId))).write(
      SessioniAllenamentoTableCompanion(
        idCamminata: Value(id),
        dataModifica: Value(startedAt),
      ),
    );
    return (await walking.getWalkingSession(id))!;
  });

  @override
  Future<PersistedWorkoutSession?> getActiveSession({
    required int profileId,
  }) async {
    final row = await db.sessioniAllenamentoDao.getActiveByProfile(profileId);
    return row == null ? null : WorkoutSessionMappers.session(row);
  }

  @override
  Future<PersistedWorkoutSession?> getSessionById(int sessionId) async {
    final row = await db.sessioniAllenamentoDao.getById(sessionId);
    return row == null ? null : WorkoutSessionMappers.session(row);
  }

  @override
  Stream<PersistedWorkoutSession?> watchSessionById(int sessionId) {
    return db.sessioniAllenamentoDao
        .watchById(sessionId)
        .map((row) => row == null ? null : WorkoutSessionMappers.session(row));
  }

  @override
  Future<List<PersistedSessionExercise>> getSessionExercises(
    int sessionId,
  ) async {
    final rows = await db.sessioniEserciziDao.getBySessionId(sessionId);
    return rows.map(WorkoutSessionMappers.sessionExercise).toList();
  }

  @override
  Future<List<PersistedSessionExercise>> getSessionExercisesForSessions(
    List<int> sessionIds,
  ) async {
    final rows = await db.sessioniEserciziDao.getBySessionIds(sessionIds);
    return rows.map(WorkoutSessionMappers.sessionExercise).toList();
  }

  @override
  Future<int> createSession({
    required int profileId,
    required WorkoutDetails details,
    required DateTime startedAt,
  }) {
    return db.transaction(() async {
      final active = await db.sessioniAllenamentoDao.getActiveByProfile(
        profileId,
      );
      if (active != null) {
        throw ActiveSessionAlreadyExistsException(active.id);
      }

      final sessionId = await db.sessioniAllenamentoDao.create(
        WorkoutSessionMappers.sessionToInsertCompanion(
          workoutId: details.workout.id,
          profileId: profileId,
          workoutNameSnapshot: details.workout.name,
          startedAt: startedAt,
          walkingBlock: details.workout.walkingBlock,
        ),
      );

      for (final entry in details.exercises) {
        final we = entry.workoutExercise;
        await db.sessioniEserciziDao.insert(
          WorkoutSessionMappers.sessionExerciseToInsertCompanion(
            sessionId: sessionId,
            workoutExerciseId: we.id!,
            exerciseId: we.exerciseId,
            order: we.order,
            // `sets == null` -> 1 serie, solo per la sessione (Milestone
            // 4.4.2, sezione 18): non riscrive mai `allenamenti_esercizi`.
            totalSets: we.sets ?? 1,
            repetitions: we.repetitions,
            durationSeconds: we.durationSeconds,
            restSeconds: we.restSeconds,
            now: startedAt,
          ),
        );
      }

      return sessionId;
    });
  }

  @override
  Future<void> updateProgress({
    required int sessionId,
    int? currentExerciseIndex,
    List<SessionExerciseProgressUpdate> exercises = const [],
    PersistedSessionTimer? Function()? timer,
    required DateTime updatedAt,
  }) {
    return db.transaction(() async {
      await db.sessioniAllenamentoDao.updateState(
        sessionId,
        WorkoutSessionMappers.stateChanges(
          currentExerciseIndex: currentExerciseIndex,
          clearTimer: timer != null,
          timer: timer?.call(),
          updatedAt: updatedAt,
        ),
      );

      for (final update in exercises) {
        final row = await db.sessioniEserciziDao.getBySessionAndWorkoutExercise(
          sessionId,
          update.workoutExerciseId,
        );
        // La riga può mancare se `id_allenamento_esercizio` è già stato
        // azzerato da un `ON DELETE SET NULL` (scheda eliminata mentre la
        // sessione era attiva, sezione 9 — caso limite fuori dal perimetro
        // di questa milestone): si ignora silenziosamente piuttosto che
        // far fallire l'intero aggiornamento di stato.
        if (row == null) continue;
        await db.sessioniEserciziDao.updateProgress(
          row.id,
          WorkoutSessionMappers.progressChanges(
            completedSets: update.completedSets,
            isSkipped: update.isSkipped,
            isCompleted: update.isCompleted,
            updatedAt: updatedAt,
          ),
        );
      }
    });
  }

  @override
  Future<void> updateTimerState({
    required int sessionId,
    PersistedSessionTimer? timer,
    required DateTime updatedAt,
  }) {
    return updateProgress(
      sessionId: sessionId,
      timer: () => timer,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> pauseSession({
    required int sessionId,
    PersistedSessionTimer? frozenTimer,
    required DateTime updatedAt,
  }) {
    return db.sessioniAllenamentoDao.updateState(
      sessionId,
      WorkoutSessionMappers.stateChanges(
        status: WorkoutSessionPersistenceStatus.paused,
        isPaused: true,
        clearTimer: true,
        timer: frozenTimer,
        updatedAt: updatedAt,
      ),
    );
  }

  @override
  Future<void> resumeSession({
    required int sessionId,
    PersistedSessionTimer? resumedTimer,
    required DateTime updatedAt,
  }) {
    return db.sessioniAllenamentoDao.updateState(
      sessionId,
      WorkoutSessionMappers.stateChanges(
        status: WorkoutSessionPersistenceStatus.inProgress,
        isPaused: false,
        clearTimer: true,
        timer: resumedTimer,
        updatedAt: updatedAt,
      ),
    );
  }

  @override
  Future<void> completeSession({
    required int sessionId,
    required DateTime endedAt,
  }) {
    return db.transaction(() async {
      final session = await getSessionById(sessionId);
      if (session?.walkingBlock != null &&
          session?.status == WorkoutSessionPersistenceStatus.completed) {
        return;
      }
      if (session?.walkingBlock != null &&
          (await getWalkingBlockSession(sessionId))?.status !=
              WalkingSessionStatus.completed) {
        throw StateError(
          'Completa anche la camminata prima di concludere la scheda.',
        );
      }
      await db.sessioniAllenamentoDao.updateState(
        sessionId,
        WorkoutSessionMappers.stateChanges(
          status: WorkoutSessionPersistenceStatus.completed,
          isCompleted: true,
          isPaused: false,
          endedAt: endedAt,
          clearTimer: true,
          updatedAt: endedAt,
        ),
      );
    });
  }

  @override
  Future<void> abortSession({
    required int sessionId,
    required DateTime endedAt,
  }) {
    return db.transaction(() async {
      final walk = await getWalkingBlockSession(sessionId);
      if (walk?.status == WalkingSessionStatus.inProgress) {
        await DriftWalkingSessionRepository(
          db,
        ).abortWalkingSession(sessionId: walk!.id!, endedAt: endedAt);
      }
      await db.sessioniAllenamentoDao.updateState(
        sessionId,
        WorkoutSessionMappers.stateChanges(
          status: WorkoutSessionPersistenceStatus.aborted,
          endedAt: endedAt,
          clearTimer: true,
          updatedAt: endedAt,
        ),
      );
    });
  }

  @override
  Future<List<WorkoutSessionHistoryItem>> getSessionHistory({
    required int profileId,
    DateTime? since,
  }) async {
    final sessions = await db.sessioniAllenamentoDao.getHistoryByProfile(
      profileId,
      since: since,
    );
    return _toHistoryItems(sessions);
  }

  @override
  Stream<List<WorkoutSessionHistoryItem>> watchSessionHistory({
    required int profileId,
    DateTime? since,
  }) {
    return db.sessioniAllenamentoDao
        .watchHistoryByProfile(profileId, since: since)
        .asyncMap(_toHistoryItems);
  }

  /// Aggrega i conteggi completati/saltati di ogni sessione con **una
  /// sola** query aggiuntiva per tutta la lista (sezione 36 — "NO N+1"),
  /// non una per sessione.
  Future<List<WorkoutSessionHistoryItem>> _toHistoryItems(
    List<SessioniAllenamentoTableData> sessions,
  ) async {
    if (sessions.isEmpty) return const [];
    final exerciseRows = await db.sessioniEserciziDao.getBySessionIds(
      sessions.map((s) => s.id).toList(),
    );
    final bySession = <int, List<SessioniEserciziTableData>>{};
    for (final row in exerciseRows) {
      bySession.putIfAbsent(row.idSessione, () => []).add(row);
    }
    return sessions
        .map(
          (s) =>
              WorkoutSessionMappers.historyItem(s, bySession[s.id] ?? const []),
        )
        .toList();
  }

  @override
  Future<WorkoutSessionHistoryDetails?> getSessionHistoryDetails(
    int sessionId,
  ) async {
    final session = await db.sessioniAllenamentoDao.getById(sessionId);
    if (session == null) return null;

    final rows = await db.sessioniEserciziDao.getBySessionIdWithExercise(
      sessionId,
    );
    final exerciseRows = rows.map((r) => r.sessionExercise).toList();
    return WorkoutSessionHistoryDetails(
      session: WorkoutSessionMappers.historyItem(session, exerciseRows),
      exercises: rows
          .map(
            (r) => WorkoutSessionMappers.exerciseHistoryItem(
              r.sessionExercise,
              r.exercise,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<PersistedWorkoutSession>> getAllSessions({
    required int profileId,
  }) async {
    final rows = await db.sessioniAllenamentoDao.getAllByProfile(profileId);
    return rows.map(WorkoutSessionMappers.session).toList();
  }
}
