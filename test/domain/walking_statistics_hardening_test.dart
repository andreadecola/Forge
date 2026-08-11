import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/walking_statistics_period.dart';
import 'package:forge/domain/services/walking_statistics_service.dart';

void main() {
  final service = const WalkingStatisticsService();
  final now = DateTime(2026, 8, 11, 12);

  test('un dataset ampio resta deterministico e senza eccezioni', () {
    final sessions = List.generate(1000, (index) {
      final startedAt = DateTime(
        2026,
        7,
        1,
      ).add(Duration(days: index % 42, minutes: index));
      final status = index.isEven
          ? WalkingSessionStatus.completed
          : WalkingSessionStatus.aborted;
      return WalkingSession(
        id: index + 1,
        profileId: 1,
        startedAt: startedAt,
        endedAt: startedAt.add(Duration(minutes: index % 90 + 1)),
        distanceMeters: index % 3 == 0 ? index * 100 : null,
        steps: index % 4 == 0 ? index * 1000 : null,
        accumulatedPauseSeconds: index % 5 == 0 ? 30 : 0,
        status: status,
      );
    });

    final forward = service.compute(
      sessions: sessions,
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );
    final reverse = service.compute(
      sessions: sessions.reversed.toList(),
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );

    expect(forward.totalSessions, 1000);
    expect(forward.completedSessions, 500);
    expect(forward.abortedSessions, 500);
    expect(forward.sessionsWithDistance, 334);
    expect(forward.sessionsWithSteps, 250);
    expect(reverse.totalActiveDuration, forward.totalActiveDuration);
    expect(reverse.totalDistanceMeters, forward.totalDistanceMeters);
    expect(reverse.totalSteps, forward.totalSteps);
    expect(
      reverse.activity.map((point) => point.sessionCount),
      forward.activity.map((point) => point.sessionCount),
    );
  });
}
