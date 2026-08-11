import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';

void main() {
  final startedAt = DateTime(2026, 1, 1, 10);

  WalkingSession session({
    DateTime? endedAt,
    bool isPaused = false,
    DateTime? pauseStartedAt,
    int accumulatedPauseSeconds = 0,
    WalkingSessionStatus status = WalkingSessionStatus.inProgress,
  }) {
    return WalkingSession(
      profileId: 1,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
      isPaused: isPaused,
      pauseStartedAt: pauseStartedAt,
      accumulatedPauseSeconds: accumulatedPauseSeconds,
    );
  }

  test('durata iniziale: cronologica 10m, pausa 0, attiva 10m', () {
    final now = startedAt.add(const Duration(minutes: 10));
    final walking = session();
    expect(walking.chronologicalDuration(now).inMinutes, 10);
    expect(walking.pauseDuration(now).inMinutes, 0);
    expect(walking.activeDuration(now).inMinutes, 10);
  });

  test('una pausa conclusa produce 30m cronologici, 5m pausa, 25m attivi', () {
    final walking = session(accumulatedPauseSeconds: 5 * 60);
    final now = startedAt.add(const Duration(minutes: 30));
    expect(walking.chronologicalDuration(now).inMinutes, 30);
    expect(walking.pauseDuration(now).inMinutes, 5);
    expect(walking.activeDuration(now).inMinutes, 25);
  });

  test('piu pause sommano solo gli intervalli conclusi', () {
    final walking = session(accumulatedPauseSeconds: 10 * 60);
    final now = startedAt.add(const Duration(minutes: 40));
    expect(walking.pauseDuration(now).inMinutes, 10);
    expect(walking.activeDuration(now).inMinutes, 30);
  });

  test('la pausa corrente viene derivata dal timestamp', () {
    final walking = session(
      isPaused: true,
      pauseStartedAt: startedAt.add(const Duration(minutes: 20)),
    );
    final now = startedAt.add(const Duration(minutes: 30));
    expect(walking.chronologicalDuration(now).inMinutes, 30);
    expect(walking.pauseDuration(now).inMinutes, 10);
    expect(walking.activeDuration(now).inMinutes, 20);
  });

  test('tempo attivo non diventa negativo', () {
    final walking = session(
      isPaused: true,
      pauseStartedAt: startedAt,
      accumulatedPauseSeconds: 1000,
    );
    expect(walking.activeDuration(startedAt).inSeconds, 0);
  });
}
