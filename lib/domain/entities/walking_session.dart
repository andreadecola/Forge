import 'walking_session_status.dart';

/// Domain representation of one offline walking session.
class WalkingSession {
  const WalkingSession({
    this.id,
    required this.profileId,
    required this.startedAt,
    this.endedAt,
    this.distanceMeters,
    this.steps,
    this.isPaused = false,
    this.pauseStartedAt,
    this.accumulatedPauseSeconds = 0,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int profileId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? distanceMeters;
  final int? steps;
  final bool isPaused;
  final DateTime? pauseStartedAt;
  final int accumulatedPauseSeconds;
  final WalkingSessionStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Derived duration. It is null while the session has no end timestamp.
  Duration? get duration => endedAt?.difference(startedAt);

  /// Derived duration in whole seconds, matching the persisted data model.
  int? get durationSeconds => duration?.inSeconds;

  Duration chronologicalDuration(DateTime now) {
    final end = endedAt ?? now;
    final seconds = end.difference(startedAt).inSeconds;
    return Duration(seconds: seconds < 0 ? 0 : seconds);
  }

  Duration pauseDuration(DateTime now) {
    final completedPauseSeconds = accumulatedPauseSeconds < 0
        ? 0
        : accumulatedPauseSeconds;
    var totalSeconds = completedPauseSeconds;
    if (isPaused && pauseStartedAt != null) {
      final currentSeconds = now.difference(pauseStartedAt!).inSeconds;
      totalSeconds += currentSeconds < 0 ? 0 : currentSeconds;
    }
    final chronologicalSeconds = chronologicalDuration(now).inSeconds;
    return Duration(
      seconds: totalSeconds > chronologicalSeconds
          ? chronologicalSeconds
          : totalSeconds,
    );
  }

  Duration activeDuration(DateTime now) {
    final seconds =
        chronologicalDuration(now).inSeconds - pauseDuration(now).inSeconds;
    return Duration(seconds: seconds < 0 ? 0 : seconds);
  }

  WalkingSession copyWith({
    int? id,
    int? profileId,
    DateTime? startedAt,
    DateTime? Function()? endedAt,
    int? Function()? distanceMeters,
    int? Function()? steps,
    bool? isPaused,
    DateTime? Function()? pauseStartedAt,
    int? accumulatedPauseSeconds,
    WalkingSessionStatus? status,
    String? Function()? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkingSession(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt != null ? endedAt() : this.endedAt,
      distanceMeters: distanceMeters != null
          ? distanceMeters()
          : this.distanceMeters,
      steps: steps != null ? steps() : this.steps,
      isPaused: isPaused ?? this.isPaused,
      pauseStartedAt: pauseStartedAt != null
          ? pauseStartedAt()
          : this.pauseStartedAt,
      accumulatedPauseSeconds:
          accumulatedPauseSeconds ?? this.accumulatedPauseSeconds,
      status: status ?? this.status,
      notes: notes != null ? notes() : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
