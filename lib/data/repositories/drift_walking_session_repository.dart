import 'package:drift/drift.dart';

import '../../domain/entities/walking_session.dart';
import '../../domain/entities/walking_session_status.dart';
import '../../domain/repositories/walking_session_repository.dart';
import '../../domain/services/clock.dart';
import '../../domain/services/walking_session_validation_service.dart';
import '../database/app_database.dart';
import 'walking_session_mappers.dart';

class DriftWalkingSessionRepository implements WalkingSessionRepository {
  DriftWalkingSessionRepository(
    this.db, {
    this._clock = const SystemClock(),
    this._validationService = const WalkingSessionValidationService(),
  });

  final AppDatabase db;
  final Clock _clock;
  final WalkingSessionValidationService _validationService;

  @override
  Future<int> createWalkingSession(WalkingSession session) async {
    _validate(session);

    try {
      return await db.transaction(() async {
        if (session.status == WalkingSessionStatus.inProgress) {
          final active = await db.camminateDao.getActiveByProfile(
            session.profileId,
          );
          if (active != null) {
            throw ActiveWalkingSessionAlreadyExistsException(active.id);
          }
        }

        return db.camminateDao.create(
          WalkingSessionMappers.toCompanion(session, now: _clock.now()),
        );
      });
    } catch (_) {
      final active = await db.camminateDao.getActiveByProfile(
        session.profileId,
      );
      if (active != null && session.status == WalkingSessionStatus.inProgress) {
        throw ActiveWalkingSessionAlreadyExistsException(active.id);
      }
      rethrow;
    }
  }

  @override
  Future<WalkingSession?> getWalkingSession(int id) async {
    final row = await db.camminateDao.getById(id);
    return row == null ? null : WalkingSessionMappers.walkingSession(row);
  }

  @override
  Future<List<WalkingSession>> getWalkingSessions({
    required int profileId,
  }) async {
    final rows = await db.camminateDao.getByProfile(profileId);
    return rows.map(WalkingSessionMappers.walkingSession).toList();
  }

  @override
  Future<List<WalkingSession>> getWalkingHistory({
    required int profileId,
    DateTime? since,
  }) async {
    final rows = await db.camminateDao.getHistoryByProfile(
      profileId,
      since: since,
    );
    return rows.map(WalkingSessionMappers.walkingSession).toList();
  }

  @override
  Stream<List<WalkingSession>> watchWalkingSessions({required int profileId}) {
    return db.camminateDao
        .watchByProfile(profileId)
        .map((rows) => rows.map(WalkingSessionMappers.walkingSession).toList());
  }

  @override
  Stream<List<WalkingSession>> watchWalkingHistory({
    required int profileId,
    DateTime? since,
  }) {
    return db.camminateDao
        .watchHistoryByProfile(profileId, since: since)
        .map((rows) => rows.map(WalkingSessionMappers.walkingSession).toList());
  }

  @override
  Future<WalkingSession?> getActiveWalkingSession({
    required int profileId,
  }) async {
    final row = await db.camminateDao.getActiveByProfile(profileId);
    return row == null ? null : WalkingSessionMappers.walkingSession(row);
  }

  @override
  Future<WalkingSession?> pauseWalkingSession({
    required int sessionId,
    required DateTime pausedAt,
  }) async {
    return db.transaction(() async {
      final current = await getWalkingSession(sessionId);
      if (current == null) {
        throw WalkingSessionNotFoundException(sessionId);
      }
      if (current.status != WalkingSessionStatus.inProgress ||
          current.isPaused) {
        return null;
      }

      final paused = current.copyWith(
        isPaused: true,
        pauseStartedAt: () => pausedAt,
      );
      _validate(paused);
      final updated = await db.camminateDao.pause(
        sessionId,
        CamminateTableCompanion(
          pausaInCorso: const Value(true),
          dataInizioPausa: Value(pausedAt),
          dataModifica: Value(_clock.now()),
        ),
      );
      if (updated == 0) return null;
      return getWalkingSession(sessionId);
    });
  }

  @override
  Future<WalkingSession?> resumeWalkingSession({
    required int sessionId,
    required DateTime resumedAt,
  }) async {
    return db.transaction(() async {
      final current = await getWalkingSession(sessionId);
      if (current == null) {
        throw WalkingSessionNotFoundException(sessionId);
      }
      if (current.status != WalkingSessionStatus.inProgress ||
          !current.isPaused) {
        return null;
      }

      final resumed = current.copyWith(
        isPaused: false,
        pauseStartedAt: () => null,
        accumulatedPauseSeconds: current.pauseDuration(resumedAt).inSeconds,
      );
      _validate(resumed);
      final updated = await db.camminateDao.resume(
        sessionId,
        CamminateTableCompanion(
          pausaInCorso: const Value(false),
          dataInizioPausa: const Value(null),
          durataPausaSecondi: Value(resumed.accumulatedPauseSeconds),
          dataModifica: Value(_clock.now()),
        ),
      );
      if (updated == 0) return null;
      return getWalkingSession(sessionId);
    });
  }

  @override
  Future<void> updateWalkingSession(WalkingSession session) async {
    final id = session.id;
    if (id == null) {
      throw const WalkingSessionNotFoundException(0);
    }
    _validate(session);

    final updated = await db.camminateDao.updateWalkingSession(
      id,
      WalkingSessionMappers.toCompanion(session, now: _clock.now()),
    );
    if (updated == 0) throw WalkingSessionNotFoundException(id);
  }

  @override
  Future<void> updateWalkingMetrics({
    required int sessionId,
    required int? distanceMeters,
    required int? steps,
  }) async {
    await db.transaction(() async {
      final current = await getWalkingSession(sessionId);
      if (current == null) {
        throw WalkingSessionNotFoundException(sessionId);
      }

      final updatedSession = current.copyWith(
        distanceMeters: () => distanceMeters,
        steps: () => steps,
      );
      _validate(updatedSession);

      final updated = await db.camminateDao.updateWalkingSession(
        sessionId,
        CamminateTableCompanion(
          distanzaMetri: Value(distanceMeters),
          passi: Value(steps),
          dataModifica: Value(_clock.now()),
        ),
      );
      if (updated == 0) throw WalkingSessionNotFoundException(sessionId);
    });
  }

  @override
  Future<void> completeWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  }) => _finishWalkingSession(
    sessionId: sessionId,
    endedAt: endedAt,
    status: WalkingSessionStatus.completed,
    distanceMeters: distanceMeters,
    steps: steps,
    notes: notes,
  );

  @override
  Future<void> abortWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  }) => _finishWalkingSession(
    sessionId: sessionId,
    endedAt: endedAt,
    status: WalkingSessionStatus.aborted,
    distanceMeters: distanceMeters,
    steps: steps,
    notes: notes,
  );

  Future<void> _finishWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    required WalkingSessionStatus status,
    required int? distanceMeters,
    required int? steps,
    required String? notes,
  }) async {
    await db.transaction(() async {
      final current = await getWalkingSession(sessionId);
      if (current == null) throw WalkingSessionNotFoundException(sessionId);
      if (current.status != WalkingSessionStatus.inProgress) {
        return;
      }

      final finished = current.copyWith(
        endedAt: () => endedAt,
        distanceMeters: () => distanceMeters ?? current.distanceMeters,
        steps: () => steps ?? current.steps,
        notes: () => notes ?? current.notes,
        status: status,
        isPaused: false,
        pauseStartedAt: () => null,
        accumulatedPauseSeconds: current.pauseDuration(endedAt).inSeconds,
      );
      _validate(finished);

      final changes = WalkingSessionMappers.stateChanges(
        status: status,
        endedAt: endedAt,
        updatedAt: _clock.now(),
        distanceMeters: finished.distanceMeters,
        steps: finished.steps,
        notes: finished.notes,
        isPaused: false,
        pauseStartedAt: null,
        accumulatedPauseSeconds: finished.accumulatedPauseSeconds,
      );
      final updated = status == WalkingSessionStatus.completed
          ? await db.camminateDao.complete(sessionId, changes)
          : await db.camminateDao.abort(sessionId, changes);
      if (updated == 0) {
        return;
      }
    });
  }

  void _validate(WalkingSession session) {
    final result = _validationService.validate(session);
    if (!result.isValid) {
      throw InvalidWalkingSessionException(result.errors);
    }
  }
}
