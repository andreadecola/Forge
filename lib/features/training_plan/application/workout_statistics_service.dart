import '../../../domain/entities/workout_activity_point.dart';
import '../../../domain/entities/workout_session_history_item.dart';
import '../../../domain/entities/workout_session_persistence_status.dart';
import '../../../domain/entities/workout_statistics.dart';
import '../../../domain/entities/workout_statistics_period.dart';

/// Calcola [WorkoutStatistics] da una lista di [WorkoutSessionHistoryItem]
/// (Milestone 4.5.2). Puro e testabile senza database (sezione 39): non
/// legge nulla da sé, [sessions] può anche non essere già filtrata per
/// periodo (il servizio filtra sempre da solo, così resta corretto
/// indipendentemente da come viene chiamato — il repository la filtra
/// comunque già per periodo per ridurre il volume letto dal DB, sezione
/// 40, ma è un'ottimizzazione, non un requisito di correttezza qui).
///
/// Nessuna metrica inventata (sezione 2): niente calorie, carico,
/// tonnellaggio, tempo attivo preciso — solo ciò che è calcolabile da
/// `sessioni_allenamento`/`sessioni_esercizi`.
class WorkoutStatisticsService {
  const WorkoutStatisticsService();

  WorkoutStatistics compute({
    required List<WorkoutSessionHistoryItem> sessions,
    required WorkoutStatisticsPeriod period,
    required DateTime now,
  }) {
    final start = periodStartFor(period, now);
    final inPeriod = start == null
        ? sessions
        : sessions.where((s) => !s.startedAt.isBefore(start)).toList();

    final completed = inPeriod
        .where((s) => s.status == WorkoutSessionPersistenceStatus.completed)
        .toList();
    final aborted = inPeriod
        .where((s) => s.status == WorkoutSessionPersistenceStatus.aborted)
        .toList();

    final totalSessions = inPeriod.length;
    final completionRate = totalSessions == 0
        ? 0.0
        : completed.length / totalSessions;

    final totalSetsCompleted = inPeriod.fold(
      0,
      (sum, s) => sum + s.totalSetsCompleted,
    );
    final totalPlannedSets = inPeriod.fold(
      0,
      (sum, s) => sum + s.totalPlannedSets,
    );
    final setCompletionRate = totalPlannedSets == 0
        ? null
        : totalSetsCompleted / totalPlannedSets;

    final durations = inPeriod
        .map((s) => s.finishedAt?.difference(s.startedAt))
        .whereType<Duration>()
        .toList();
    final totalDuration = durations.fold(Duration.zero, (sum, d) => sum + d);
    final averageDuration = durations.isEmpty
        ? null
        : Duration(seconds: totalDuration.inSeconds ~/ durations.length);

    final activeDays = inPeriod
        .map(
          (s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day),
        )
        .toSet()
        .length;

    final daysInPeriod = _daysInPeriod(period, now, inPeriod);
    final averageSessionsPerWeek = daysInPeriod == 0
        ? 0.0
        : totalSessions / daysInPeriod * 7;

    return WorkoutStatistics(
      period: period,
      totalSessions: totalSessions,
      completedSessions: completed.length,
      abortedSessions: aborted.length,
      completionRate: completionRate,
      totalExercisesCompleted: inPeriod.fold(
        0,
        (sum, s) => sum + s.completedExercises,
      ),
      totalExercisesSkipped: inPeriod.fold(
        0,
        (sum, s) => sum + s.skippedExercises,
      ),
      totalSetsCompleted: totalSetsCompleted,
      totalPlannedSets: totalPlannedSets,
      setCompletionRate: setCompletionRate,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      activeDays: activeDays,
      averageSessionsPerWeek: averageSessionsPerWeek,
      activity: _buildActivity(inPeriod, period, now),
    );
  }

  /// "Giorni nel periodo", usati come base per la frequenza settimanale
  /// (sezione 22): fisso per i periodi a finestra fissa; per `allTime`,
  /// dalla prima sessione a [now], minimo 1 giorno.
  int _daysInPeriod(
    WorkoutStatisticsPeriod period,
    DateTime now,
    List<WorkoutSessionHistoryItem> inPeriod,
  ) {
    switch (period) {
      case WorkoutStatisticsPeriod.last7Days:
        return 7;
      case WorkoutStatisticsPeriod.last30Days:
        return 30;
      case WorkoutStatisticsPeriod.last90Days:
        return 90;
      case WorkoutStatisticsPeriod.allTime:
        if (inPeriod.isEmpty) return 1;
        final earliest = inPeriod
            .map((s) => s.startedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final days = _dayOnly(now).difference(_dayOnly(earliest)).inDays + 1;
        return days < 1 ? 1 : days;
    }
  }

  /// Aggregazione per il grafico (sezione 24/26/55): giornaliera per 7
  /// giorni, settimanale per 30/90, mensile per "Tutto". Vuota se non ci
  /// sono sessioni (sezione 27: nessuna barra finta).
  List<WorkoutActivityPoint> _buildActivity(
    List<WorkoutSessionHistoryItem> inPeriod,
    WorkoutStatisticsPeriod period,
    DateTime now,
  ) {
    if (inPeriod.isEmpty) return const [];

    switch (period) {
      case WorkoutStatisticsPeriod.last7Days:
        final start = periodStartFor(period, now)!;
        return _bucket(inPeriod, _dayOnly, start, _dayOnly(now), _nextDay);
      case WorkoutStatisticsPeriod.last30Days:
      case WorkoutStatisticsPeriod.last90Days:
        final start = _weekStart(periodStartFor(period, now)!);
        return _bucket(
          inPeriod,
          (d) => _weekStart(_dayOnly(d)),
          start,
          _weekStart(_dayOnly(now)),
          _nextWeek,
        );
      case WorkoutStatisticsPeriod.allTime:
        final earliest = inPeriod
            .map((s) => s.startedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final start = DateTime(earliest.year, earliest.month, 1);
        final end = DateTime(now.year, now.month, 1);
        return _bucket(
          inPeriod,
          (d) => DateTime(d.year, d.month, 1),
          start,
          end,
          _nextMonth,
        );
    }
  }

  /// Costruisce un bucket per ogni passo da [start] a [end] (inclusi),
  /// anche quelli senza sessioni (uno zero reale, non un dato mancante —
  /// sezione 27 riguarda l'assenza *totale* di dati, non i singoli
  /// giorni/settimane/mesi vuoti dentro un periodo che ne ha altri).
  List<WorkoutActivityPoint> _bucket(
    List<WorkoutSessionHistoryItem> sessions,
    DateTime Function(DateTime) keyOf,
    DateTime start,
    DateTime end,
    DateTime Function(DateTime) next,
  ) {
    final counts = <DateTime, int>{};
    final completedCounts = <DateTime, int>{};
    for (var bucket = start; !bucket.isAfter(end); bucket = next(bucket)) {
      counts[bucket] = 0;
      completedCounts[bucket] = 0;
    }
    for (final session in sessions) {
      final key = keyOf(session.startedAt);
      if (!counts.containsKey(key)) continue;
      counts[key] = counts[key]! + 1;
      if (session.status == WorkoutSessionPersistenceStatus.completed) {
        completedCounts[key] = completedCounts[key]! + 1;
      }
    }
    return counts.entries
        .map(
          (e) => WorkoutActivityPoint(
            periodStart: e.key,
            sessionCount: e.value,
            completedSessions: completedCounts[e.key]!,
          ),
        )
        .toList()
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _nextDay(DateTime d) => d.add(const Duration(days: 1));

  DateTime _nextWeek(DateTime d) => d.add(const Duration(days: 7));

  DateTime _nextMonth(DateTime d) => d.month == 12
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);

  /// Lunedì della settimana di [day] (settimana ISO, non domenicale).
  DateTime _weekStart(DateTime day) =>
      day.subtract(Duration(days: day.weekday - 1));
}
