import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/walking_session.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/domain/entities/walking_statistics_period.dart';
import 'package:forge/domain/services/walking_statistics_service.dart';

void main() {
  const service = WalkingStatisticsService();
  final now = DateTime(2026, 8, 10, 12);
  var nextId = 1;

  WalkingSession session({
    DateTime? startedAt,
    Duration? duration,
    WalkingSessionStatus status = WalkingSessionStatus.completed,
    int? distanceMeters,
    int? steps,
    int pauseSeconds = 0,
  }) {
    final start = startedAt ?? now;
    return WalkingSession(
      id: nextId++,
      profileId: 1,
      startedAt: start,
      endedAt: duration == null ? null : start.add(duration),
      distanceMeters: distanceMeters,
      steps: steps,
      accumulatedPauseSeconds: pauseSeconds,
      status: status,
    );
  }

  test('nessuna sessione non produce zeri fittizi o divisioni per zero', () {
    final stats = service.compute(
      sessions: const [],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );

    expect(stats.totalSessions, 0);
    expect(stats.completedSessions, 0);
    expect(stats.abortedSessions, 0);
    expect(stats.totalActiveDuration, Duration.zero);
    expect(stats.totalChronologicalDuration, Duration.zero);
    expect(stats.totalPauseDuration, Duration.zero);
    expect(stats.totalDistanceMeters, isNull);
    expect(stats.totalSteps, isNull);
    expect(stats.averageActiveDuration, isNull);
    expect(stats.averageDistanceMeters, isNull);
    expect(stats.averageSteps, isNull);
    expect(stats.averageSessionsPerWeek, 0);
    expect(stats.activity, isEmpty);
  });

  test('conteggi e tempi usano completed, aborted e pause persistite', () {
    final stats = service.compute(
      sessions: [
        session(duration: const Duration(minutes: 30), pauseSeconds: 300),
        session(
          status: WalkingSessionStatus.aborted,
          duration: const Duration(minutes: 20),
        ),
        session(status: WalkingSessionStatus.completed),
        session(status: WalkingSessionStatus.inProgress),
      ],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );

    expect(stats.totalSessions, 3);
    expect(stats.completedSessions, 2);
    expect(stats.abortedSessions, 1);
    expect(stats.totalChronologicalDuration, const Duration(minutes: 50));
    expect(stats.totalPauseDuration, const Duration(minutes: 5));
    expect(stats.totalActiveDuration, const Duration(minutes: 45));
    expect(
      stats.averageActiveDuration,
      const Duration(minutes: 22, seconds: 30),
    );
  });

  test('distance e passi rispettano null, zero, totale, conteggio e media', () {
    final stats = service.compute(
      sessions: [
        session(
          distanceMeters: 3000,
          steps: 3000,
          duration: const Duration(minutes: 1),
        ),
        session(
          distanceMeters: null,
          steps: null,
          duration: const Duration(minutes: 1),
        ),
        session(
          distanceMeters: 2000,
          steps: 5000,
          duration: const Duration(minutes: 1),
        ),
        session(
          distanceMeters: 0,
          steps: 0,
          duration: const Duration(minutes: 1),
        ),
      ],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );

    expect(stats.totalDistanceMeters, 5000);
    expect(stats.sessionsWithDistance, 3);
    expect(stats.averageDistanceMeters, 1666);
    expect(stats.totalSteps, 8000);
    expect(stats.sessionsWithSteps, 3);
    expect(stats.averageSteps, 2666);
  });

  test('tutte le metriche opzionali null restano null', () {
    final stats = service.compute(
      sessions: [session(duration: const Duration(minutes: 10))],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );
    expect(stats.totalDistanceMeters, isNull);
    expect(stats.averageDistanceMeters, isNull);
    expect(stats.totalSteps, isNull);
    expect(stats.averageSteps, isNull);
  });

  test('active days conta giorni locali distinti', () {
    final stats = service.compute(
      sessions: [
        session(startedAt: DateTime(2026, 8, 1, 9)),
        session(startedAt: DateTime(2026, 8, 1, 18)),
        session(startedAt: DateTime(2026, 8, 2, 9)),
      ],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );
    expect(stats.activeDays, 2);
  });

  test('periodi includono il giorno corrente e applicano i boundary', () {
    final stats = service.compute(
      sessions: [
        session(startedAt: DateTime(2026, 8, 4, 0)),
        session(startedAt: DateTime(2026, 8, 3, 23, 59)),
        session(startedAt: DateTime(2026, 7, 11)),
        session(startedAt: DateTime(2026, 7, 10)),
      ],
      period: WalkingStatisticsPeriod.last7Days,
      now: now,
    );
    expect(stats.totalSessions, 1);

    final thirty = service.compute(
      sessions: [
        session(startedAt: DateTime(2026, 7, 12)),
        session(startedAt: DateTime(2026, 7, 11, 23, 59)),
      ],
      period: WalkingStatisticsPeriod.last30Days,
      now: now,
    );
    expect(thirty.totalSessions, 1);
  });

  test('frequenza settimanale usa giorni del periodo e allTime', () {
    final fixed = [session(startedAt: now), session(startedAt: now)];
    final seven = service.compute(
      sessions: fixed,
      period: WalkingStatisticsPeriod.last7Days,
      now: now,
    );
    expect(seven.averageSessionsPerWeek, closeTo(2, 0.001));

    final allTime = service.compute(
      sessions: [
        session(startedAt: DateTime(2026, 8, 1)),
        session(startedAt: DateTime(2026, 8, 10)),
      ],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );
    expect(allTime.averageSessionsPerWeek, closeTo(1.4, 0.001));
  });

  test('activity points sono giornalieri, settimanali e mensili', () {
    final seven = service.compute(
      sessions: [
        session(
          startedAt: now.subtract(const Duration(days: 2)),
          duration: const Duration(minutes: 1),
        ),
      ],
      period: WalkingStatisticsPeriod.last7Days,
      now: now,
    );
    expect(seven.activity, hasLength(7));
    expect(
      seven.activity.where((point) => point.sessionCount > 0),
      hasLength(1),
    );
    expect(
      seven.activity
          .singleWhere((point) => point.sessionCount > 0)
          .activeDuration,
      const Duration(minutes: 1),
    );

    final thirty = service.compute(
      sessions: [session(startedAt: now.subtract(const Duration(days: 5)))],
      period: WalkingStatisticsPeriod.last30Days,
      now: now,
    );
    expect(thirty.activity.length, inInclusiveRange(4, 6));

    final allTime = service.compute(
      sessions: [
        session(startedAt: DateTime(2026, 5, 15)),
        session(startedAt: DateTime(2026, 8, 5)),
      ],
      period: WalkingStatisticsPeriod.allTime,
      now: now,
    );
    expect(allTime.activity, hasLength(4));
    expect(allTime.activity.first.periodStart, DateTime(2026, 5, 1));
    expect(allTime.activity.last.periodStart, DateTime(2026, 8, 1));
  });

  test('ordine input non cambia il risultato', () {
    final sessions = [
      session(distanceMeters: 1000, steps: 100),
      session(
        status: WalkingSessionStatus.aborted,
        distanceMeters: 2000,
        steps: 200,
      ),
    ];
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
    expect(reverse.totalSessions, forward.totalSessions);
    expect(reverse.totalDistanceMeters, forward.totalDistanceMeters);
    expect(reverse.totalSteps, forward.totalSteps);
    expect(
      reverse.activity.map((point) => point.sessionCount),
      forward.activity.map((point) => point.sessionCount),
    );
  });
}
