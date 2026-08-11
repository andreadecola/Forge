/// Punto aggregato per il grafico di attività walking.
class WalkingActivityPoint {
  const WalkingActivityPoint({
    required this.periodStart,
    required this.sessionCount,
    required this.completedSessions,
    required this.activeDuration,
  });

  final DateTime periodStart;
  final int sessionCount;
  final int completedSessions;
  final Duration activeDuration;
}
