import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/services/walking_session_validation_service.dart';

void main() {
  final service = const WalkingSessionValidationService();
  final startedAt = DateTime(2026, 1, 1, 10);

  WalkingSession session({
    WalkingSessionStatus status = WalkingSessionStatus.inProgress,
    DateTime? endedAt,
    int? distanceMeters,
    int? steps,
    bool isPaused = false,
    DateTime? pauseStartedAt,
    int accumulatedPauseSeconds = 0,
  }) {
    return WalkingSession(
      profileId: 1,
      startedAt: startedAt,
      endedAt: endedAt,
      distanceMeters: distanceMeters,
      steps: steps,
      status: status,
      isPaused: isPaused,
      pauseStartedAt: pauseStartedAt,
      accumulatedPauseSeconds: accumulatedPauseSeconds,
    );
  }

  test('IN_PROGRESS è valido', () {
    expect(service.validate(session()).isValid, isTrue);
  });

  test('COMPLETED e ABORTED validi richiedono una fine', () {
    final endedAt = startedAt.add(const Duration(minutes: 20));
    expect(
      service
          .validate(
            session(status: WalkingSessionStatus.completed, endedAt: endedAt),
          )
          .isValid,
      isTrue,
    );
    expect(
      service
          .validate(
            session(status: WalkingSessionStatus.aborted, endedAt: endedAt),
          )
          .isValid,
      isTrue,
    );
  });

  test('COMPLETED senza fine e ABORTED senza fine sono invalidi', () {
    expect(
      service.validate(session(status: WalkingSessionStatus.completed)).isValid,
      isFalse,
    );
    expect(
      service.validate(session(status: WalkingSessionStatus.aborted)).isValid,
      isFalse,
    );
  });

  test('la fine precedente all inizio è invalida', () {
    expect(
      service
          .validate(
            session(
              status: WalkingSessionStatus.completed,
              endedAt: startedAt.subtract(const Duration(seconds: 1)),
            ),
          )
          .isValid,
      isFalse,
    );
  });

  test('passi e distanza negativi sono invalidi', () {
    expect(service.validate(session(steps: -1)).isValid, isFalse);
    expect(service.validate(session(distanceMeters: -1)).isValid, isFalse);
  });

  test('zero passi e zero metri sono validi', () {
    expect(
      service.validate(session(steps: 0, distanceMeters: 0)).isValid,
      isTrue,
    );
  });

  test('stato pausa coerente e durata pausa non negativa', () {
    final pauseStartedAt = startedAt.add(const Duration(minutes: 10));
    expect(
      service
          .validate(session(isPaused: true, pauseStartedAt: pauseStartedAt))
          .isValid,
      isTrue,
    );
    expect(
      service.validate(session(accumulatedPauseSeconds: -1)).isValid,
      isFalse,
    );
    expect(
      service
          .validate(
            session(
              status: WalkingSessionStatus.completed,
              endedAt: startedAt.add(const Duration(minutes: 1)),
              isPaused: true,
              pauseStartedAt: pauseStartedAt,
            ),
          )
          .isValid,
      isFalse,
    );
  });

  test('la durata è derivata senza essere una seconda fonte di verità', () {
    final walkingSession = session(
      status: WalkingSessionStatus.completed,
      endedAt: startedAt.add(const Duration(seconds: 61)),
    );
    expect(walkingSession.durationSeconds, 61);
  });
}
