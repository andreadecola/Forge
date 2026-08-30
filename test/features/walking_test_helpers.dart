import 'dart:async';

import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/repositories/walking_session_repository.dart';
import 'package:forge/domain/services/clock.dart';

class FakeWalkingClock implements Clock {
  FakeWalkingClock([DateTime? initial])
    : current = initial ?? DateTime(2026, 1, 1, 10);

  DateTime current;

  void advance(Duration duration) => current = current.add(duration);

  @override
  DateTime now() => current;
}

class FakeWalkingSessionRepository implements WalkingSessionRepository {
  final Map<int, WalkingSession> sessions = {};
  int _nextId = 1;

  WalkingSession seed({
    int profileId = 1,
    DateTime? startedAt,
    WalkingSessionStatus status = WalkingSessionStatus.inProgress,
    int? distanceMeters,
    int? steps,
    bool isPaused = false,
    DateTime? pauseStartedAt,
    int accumulatedPauseSeconds = 0,
    String? notes,
  }) {
    final session = WalkingSession(
      id: _nextId++,
      profileId: profileId,
      startedAt: startedAt ?? DateTime(2026, 1, 1, 10),
      status: status,
      distanceMeters: distanceMeters,
      steps: steps,
      isPaused: isPaused,
      pauseStartedAt: pauseStartedAt,
      accumulatedPauseSeconds: accumulatedPauseSeconds,
      notes: notes,
      endedAt: status == WalkingSessionStatus.inProgress
          ? null
          : (startedAt ?? DateTime(2026, 1, 1, 10)).add(
              const Duration(minutes: 1),
            ),
    );
    sessions[session.id!] = session;
    return session;
  }

  @override
  Future<int> createWalkingSession(WalkingSession session) async {
    if (await getActiveWalkingSession(profileId: session.profileId) != null) {
      throw ActiveWalkingSessionAlreadyExistsException(
        (await getActiveWalkingSession(profileId: session.profileId))!.id!,
      );
    }
    final id = _nextId++;
    sessions[id] = WalkingSession(
      id: id,
      profileId: session.profileId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      distanceMeters: session.distanceMeters,
      steps: session.steps,
      isPaused: session.isPaused,
      pauseStartedAt: session.pauseStartedAt,
      accumulatedPauseSeconds: session.accumulatedPauseSeconds,
      status: session.status,
      notes: session.notes,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    );
    return id;
  }

  @override
  Future<WalkingSession?> getWalkingSession(int id) async => sessions[id];

  @override
  Stream<WalkingSession?> watchWalkingSessionById(int id) =>
      Stream.value(sessions[id]);

  @override
  Future<List<WalkingSession>> getWalkingSessions({required int profileId}) =>
      Future.value(
        sessions.values
            .where((session) => session.profileId == profileId)
            .toList(),
      );

  @override
  Future<List<WalkingSession>> getWalkingHistory({
    required int profileId,
    DateTime? since,
  }) => Future.value(_history(profileId, since: since));

  @override
  Stream<List<WalkingSession>> watchWalkingSessions({required int profileId}) =>
      Stream<List<WalkingSession>>.value(
        sessions.values
            .where((session) => session.profileId == profileId)
            .toList(),
      );

  @override
  Stream<List<WalkingSession>> watchWalkingHistory({
    required int profileId,
    DateTime? since,
  }) => Stream<List<WalkingSession>>.value(_history(profileId, since: since));

  List<WalkingSession> _history(int profileId, {DateTime? since}) {
    final history = sessions.values
        .where(
          (session) =>
              session.profileId == profileId &&
              session.status != WalkingSessionStatus.inProgress &&
              (since == null || !session.startedAt.isBefore(since)),
        )
        .toList();
    history.sort((a, b) {
      final started = b.startedAt.compareTo(a.startedAt);
      if (started != 0) return started;
      return b.id!.compareTo(a.id!);
    });
    return history;
  }

  @override
  Future<WalkingSession?> getActiveWalkingSession({required int profileId}) =>
      Future.value(
        sessions.values
            .where(
              (session) =>
                  session.profileId == profileId &&
                  session.status == WalkingSessionStatus.inProgress,
            )
            .firstOrNull,
      );

  @override
  Future<void> updateWalkingSession(WalkingSession session) async {
    sessions[session.id!] = session;
  }

  @override
  Future<WalkingSession?> pauseWalkingSession({
    required int sessionId,
    required DateTime pausedAt,
  }) async {
    final current = sessions[sessionId]!;
    if (current.status != WalkingSessionStatus.inProgress || current.isPaused) {
      return null;
    }
    final updated = current.copyWith(
      isPaused: true,
      pauseStartedAt: () => pausedAt,
    );
    sessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<WalkingSession?> resumeWalkingSession({
    required int sessionId,
    required DateTime resumedAt,
  }) async {
    final current = sessions[sessionId]!;
    if (current.status != WalkingSessionStatus.inProgress ||
        !current.isPaused) {
      return null;
    }
    final updated = current.copyWith(
      isPaused: false,
      pauseStartedAt: () => null,
      accumulatedPauseSeconds: current.pauseDuration(resumedAt).inSeconds,
    );
    sessions[sessionId] = updated;
    return updated;
  }

  bool failMetricsUpdate = false;

  @override
  Future<void> updateWalkingMetrics({
    required int sessionId,
    required int? distanceMeters,
    required int? steps,
  }) async {
    if (failMetricsUpdate) throw StateError('metric update failed');
    final current = sessions[sessionId]!;
    sessions[sessionId] = current.copyWith(
      distanceMeters: () => distanceMeters,
      steps: () => steps,
    );
  }

  @override
  Future<void> completeWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  }) async {
    final current = sessions[sessionId]!;
    sessions[sessionId] = current.copyWith(
      endedAt: () => endedAt,
      isPaused: false,
      pauseStartedAt: () => null,
      accumulatedPauseSeconds: current.pauseDuration(endedAt).inSeconds,
      status: WalkingSessionStatus.completed,
    );
  }

  @override
  Future<void> abortWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  }) async {
    final current = sessions[sessionId]!;
    sessions[sessionId] = current.copyWith(
      endedAt: () => endedAt,
      isPaused: false,
      pauseStartedAt: () => null,
      accumulatedPauseSeconds: current.pauseDuration(endedAt).inSeconds,
      status: WalkingSessionStatus.aborted,
    );
  }
}
