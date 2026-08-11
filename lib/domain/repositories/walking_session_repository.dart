import '../entities/walking_session.dart';

abstract class WalkingSessionRepository {
  Future<int> createWalkingSession(WalkingSession session);

  Future<WalkingSession?> getWalkingSession(int id);

  Future<List<WalkingSession>> getWalkingSessions({required int profileId});

  Future<List<WalkingSession>> getWalkingHistory({
    required int profileId,
    DateTime? since,
  });

  Stream<List<WalkingSession>> watchWalkingSessions({required int profileId});

  Stream<List<WalkingSession>> watchWalkingHistory({
    required int profileId,
    DateTime? since,
  });

  Future<WalkingSession?> getActiveWalkingSession({required int profileId});

  Future<WalkingSession?> pauseWalkingSession({
    required int sessionId,
    required DateTime pausedAt,
  });

  Future<WalkingSession?> resumeWalkingSession({
    required int sessionId,
    required DateTime resumedAt,
  });

  Future<void> updateWalkingSession(WalkingSession session);

  /// Updates both optional metrics atomically without changing session state.
  Future<void> updateWalkingMetrics({
    required int sessionId,
    required int? distanceMeters,
    required int? steps,
  });

  Future<void> completeWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  });

  Future<void> abortWalkingSession({
    required int sessionId,
    required DateTime endedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
  });
}

class InvalidWalkingSessionException implements Exception {
  const InvalidWalkingSessionException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'InvalidWalkingSessionException: ${errors.join(' ')}';
}

class ActiveWalkingSessionAlreadyExistsException implements Exception {
  const ActiveWalkingSessionAlreadyExistsException(this.activeSessionId);

  final int activeSessionId;

  @override
  String toString() =>
      'ActiveWalkingSessionAlreadyExistsException: camminata '
      '$activeSessionId già attiva.';
}

class WalkingSessionNotFoundException implements Exception {
  const WalkingSessionNotFoundException(this.sessionId);

  final int sessionId;

  @override
  String toString() => 'WalkingSessionNotFoundException: $sessionId.';
}
