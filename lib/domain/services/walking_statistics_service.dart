import '../entities/walking_activity_point.dart';
import '../entities/walking_session.dart';
import '../entities/walking_session_status.dart';
import '../entities/walking_statistics.dart';
import '../entities/walking_statistics_period.dart';

/// Calcola statistiche walking senza dipendenze da database o Flutter.
class WalkingStatisticsService {
  const WalkingStatisticsService();

  WalkingStatistics compute({
    required List<WalkingSession> sessions,
    required WalkingStatisticsPeriod period,
    required DateTime now,
  }) {
    final start = walkingStatisticsPeriodStartFor(period, now);
    final inPeriod = sessions
        .where(
          (session) =>
              (session.status == WalkingSessionStatus.completed ||
                  session.status == WalkingSessionStatus.aborted) &&
              (start == null || !session.startedAt.isBefore(start)),
        )
        .toList();

    final completedSessions = inPeriod
        .where((session) => session.status == WalkingSessionStatus.completed)
        .length;
    final abortedSessions = inPeriod
        .where((session) => session.status == WalkingSessionStatus.aborted)
        .length;

    final validDurationSessions = inPeriod
        .where((session) => session.endedAt != null)
        .toList();
    var totalActiveDuration = Duration.zero;
    var totalChronologicalDuration = Duration.zero;
    var totalPauseDuration = Duration.zero;
    for (final session in validDurationSessions) {
      final endedAt = session.endedAt!;
      totalActiveDuration += session.activeDuration(endedAt);
      totalChronologicalDuration += session.chronologicalDuration(endedAt);
      totalPauseDuration += session.pauseDuration(endedAt);
    }

    final distances = inPeriod
        .map((session) => session.distanceMeters)
        .whereType<int>()
        .toList();
    final steps = inPeriod
        .map((session) => session.steps)
        .whereType<int>()
        .toList();

    final daysInPeriod = _daysInPeriod(period, now, inPeriod);
    final averageSessionsPerWeek = daysInPeriod == 0
        ? 0.0
        : inPeriod.length / daysInPeriod * 7;

    return WalkingStatistics(
      period: period,
      totalSessions: inPeriod.length,
      completedSessions: completedSessions,
      abortedSessions: abortedSessions,
      totalActiveDuration: totalActiveDuration,
      totalChronologicalDuration: totalChronologicalDuration,
      totalPauseDuration: totalPauseDuration,
      totalDistanceMeters: _sumOrNull(distances),
      totalSteps: _sumOrNull(steps),
      sessionsWithDistance: distances.length,
      sessionsWithSteps: steps.length,
      averageActiveDuration: validDurationSessions.isEmpty
          ? null
          : Duration(
              seconds:
                  totalActiveDuration.inSeconds ~/ validDurationSessions.length,
            ),
      averageDistanceMeters: distances.isEmpty
          ? null
          : distances.reduce((a, b) => a + b) ~/ distances.length,
      averageSteps: steps.isEmpty
          ? null
          : steps.reduce((a, b) => a + b) ~/ steps.length,
      activeDays: inPeriod
          .map(
            (session) => DateTime(
              session.startedAt.year,
              session.startedAt.month,
              session.startedAt.day,
            ),
          )
          .toSet()
          .length,
      averageSessionsPerWeek: averageSessionsPerWeek,
      activity: _buildActivity(inPeriod, period, now),
    );
  }

  int? _sumOrNull(List<int> values) =>
      values.isEmpty ? null : values.fold<int>(0, (sum, value) => sum + value);

  int _daysInPeriod(
    WalkingStatisticsPeriod period,
    DateTime now,
    List<WalkingSession> sessions,
  ) {
    switch (period) {
      case WalkingStatisticsPeriod.last7Days:
        return 7;
      case WalkingStatisticsPeriod.last30Days:
        return 30;
      case WalkingStatisticsPeriod.last90Days:
        return 90;
      case WalkingStatisticsPeriod.allTime:
        if (sessions.isEmpty) return 1;
        final earliest = sessions
            .map((session) => session.startedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final days = _dayOnly(now).difference(_dayOnly(earliest)).inDays + 1;
        return days < 1 ? 1 : days;
    }
  }

  List<WalkingActivityPoint> _buildActivity(
    List<WalkingSession> sessions,
    WalkingStatisticsPeriod period,
    DateTime now,
  ) {
    if (sessions.isEmpty) return const [];

    switch (period) {
      case WalkingStatisticsPeriod.last7Days:
        final start = walkingStatisticsPeriodStartFor(period, now)!;
        return _bucket(sessions, _dayOnly, start, _dayOnly(now), _nextDay);
      case WalkingStatisticsPeriod.last30Days:
      case WalkingStatisticsPeriod.last90Days:
        final start = _weekStart(walkingStatisticsPeriodStartFor(period, now)!);
        return _bucket(
          sessions,
          (date) => _weekStart(_dayOnly(date)),
          start,
          _weekStart(_dayOnly(now)),
          _nextWeek,
        );
      case WalkingStatisticsPeriod.allTime:
        final earliest = sessions
            .map((session) => session.startedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final start = DateTime(earliest.year, earliest.month, 1);
        final end = DateTime(now.year, now.month, 1);
        return _bucket(
          sessions,
          (date) => DateTime(date.year, date.month, 1),
          start,
          end,
          _nextMonth,
        );
    }
  }

  List<WalkingActivityPoint> _bucket(
    List<WalkingSession> sessions,
    DateTime Function(DateTime) keyOf,
    DateTime start,
    DateTime end,
    DateTime Function(DateTime) next,
  ) {
    final counts = <DateTime, int>{};
    final completedCounts = <DateTime, int>{};
    final activeDurations = <DateTime, Duration>{};
    for (var bucket = start; !bucket.isAfter(end); bucket = next(bucket)) {
      counts[bucket] = 0;
      completedCounts[bucket] = 0;
      activeDurations[bucket] = Duration.zero;
    }
    for (final session in sessions) {
      final key = keyOf(session.startedAt);
      if (!counts.containsKey(key)) continue;
      counts[key] = counts[key]! + 1;
      if (session.status == WalkingSessionStatus.completed) {
        completedCounts[key] = completedCounts[key]! + 1;
      }
      if (session.endedAt != null) {
        activeDurations[key] =
            activeDurations[key]! + session.activeDuration(session.endedAt!);
      }
    }
    return counts.entries
        .map(
          (entry) => WalkingActivityPoint(
            periodStart: entry.key,
            sessionCount: entry.value,
            completedSessions: completedCounts[entry.key]!,
            activeDuration: activeDurations[entry.key]!,
          ),
        )
        .toList()
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _nextDay(DateTime date) => date.add(const Duration(days: 1));

  DateTime _nextWeek(DateTime date) => date.add(const Duration(days: 7));

  DateTime _nextMonth(DateTime date) => date.month == 12
      ? DateTime(date.year + 1, 1, 1)
      : DateTime(date.year, date.month + 1, 1);

  DateTime _weekStart(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));
}
