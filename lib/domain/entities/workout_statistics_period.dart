/// Periodo per le statistiche allenamenti (Milestone 4.5.2).
enum WorkoutStatisticsPeriod { last7Days, last30Days, last90Days, allTime }

/// Confine inferiore (incluso) del periodo, secondo [now] — **il giorno
/// corrente è sempre incluso** (sezione 6): per `last7Days` il confine è
/// la mezzanotte di 6 giorni fa, così i 7 giorni compresi sono
/// oggi + i 6 precedenti. `null` per [WorkoutStatisticsPeriod.allTime]
/// (nessun confine inferiore).
///
/// Confronto per giorno di calendario locale (`DateTime` non-UTC, come
/// usato ovunque nell'app — sezione 41): non serve alcuna conversione,
/// basta troncare l'ora.
DateTime? periodStartFor(WorkoutStatisticsPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case WorkoutStatisticsPeriod.last7Days:
      return today.subtract(const Duration(days: 6));
    case WorkoutStatisticsPeriod.last30Days:
      return today.subtract(const Duration(days: 29));
    case WorkoutStatisticsPeriod.last90Days:
      return today.subtract(const Duration(days: 89));
    case WorkoutStatisticsPeriod.allTime:
      return null;
  }
}
