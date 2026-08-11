/// Periodi disponibili per le statistiche aggregate delle camminate.
enum WalkingStatisticsPeriod { last7Days, last30Days, last90Days, allTime }

/// Confine locale incluso del periodo. Il giorno corrente è sempre incluso.
DateTime? walkingStatisticsPeriodStartFor(
  WalkingStatisticsPeriod period,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case WalkingStatisticsPeriod.last7Days:
      return today.subtract(const Duration(days: 6));
    case WalkingStatisticsPeriod.last30Days:
      return today.subtract(const Duration(days: 29));
    case WalkingStatisticsPeriod.last90Days:
      return today.subtract(const Duration(days: 89));
    case WalkingStatisticsPeriod.allTime:
      return null;
  }
}
