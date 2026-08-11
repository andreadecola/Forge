import '../../../domain/entities/walking_session.dart';
import '../../../domain/entities/walking_session_status.dart';
import '../../../domain/services/clock.dart';

/// Runtime projection of a persisted walking session.
///
/// Duration formulas are delegated to the domain entity so the page,
/// controller and repository do not maintain separate time semantics.
class WalkingSessionRuntimeState {
  const WalkingSessionRuntimeState({
    required this.sessionId,
    required this.profileId,
    required this.startedAt,
    required this.status,
    this.isPaused = false,
    this.pauseStartedAt,
    this.accumulatedPauseSeconds = 0,
    this.endedAt,
    this.distanceMeters,
    this.steps,
  });

  final int sessionId;
  final int profileId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isPaused;
  final DateTime? pauseStartedAt;
  final int accumulatedPauseSeconds;
  final int? distanceMeters;
  final int? steps;
  final WalkingSessionStatus status;

  bool get isTerminal =>
      status == WalkingSessionStatus.completed ||
      status == WalkingSessionStatus.aborted;

  WalkingSession toWalkingSession() => WalkingSession(
    id: sessionId,
    profileId: profileId,
    startedAt: startedAt,
    endedAt: endedAt,
    distanceMeters: distanceMeters,
    steps: steps,
    status: status,
    isPaused: isPaused,
    pauseStartedAt: pauseStartedAt,
    accumulatedPauseSeconds: accumulatedPauseSeconds,
  );

  int chronologicalSeconds(Clock clock) =>
      toWalkingSession().chronologicalDuration(clock.now()).inSeconds;

  int pauseSeconds(Clock clock) =>
      toWalkingSession().pauseDuration(clock.now()).inSeconds;

  int activeSeconds(Clock clock) =>
      toWalkingSession().activeDuration(clock.now()).inSeconds;

  /// Backward-compatible name used by the M6.2 timer UI.
  int elapsedSeconds(Clock clock) => chronologicalSeconds(clock);

  WalkingSessionRuntimeState copyWith({
    bool? isPaused,
    DateTime? Function()? pauseStartedAt,
    int? accumulatedPauseSeconds,
    WalkingSessionStatus? status,
    DateTime? Function()? endedAt,
    int? Function()? distanceMeters,
    int? Function()? steps,
  }) {
    return WalkingSessionRuntimeState(
      sessionId: sessionId,
      profileId: profileId,
      startedAt: startedAt,
      isPaused: isPaused ?? this.isPaused,
      pauseStartedAt: pauseStartedAt != null
          ? pauseStartedAt()
          : this.pauseStartedAt,
      accumulatedPauseSeconds:
          accumulatedPauseSeconds ?? this.accumulatedPauseSeconds,
      status: status ?? this.status,
      endedAt: endedAt != null ? endedAt() : this.endedAt,
      distanceMeters: distanceMeters != null
          ? distanceMeters()
          : this.distanceMeters,
      steps: steps != null ? steps() : this.steps,
    );
  }
}
