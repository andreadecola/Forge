/// Punto di attività aggregato per la UI (Milestone 4.5.2, sezione 25):
/// [periodStart] è l'inizio del bucket (giorno/settimana/mese secondo la
/// granularità scelta da `WorkoutStatisticsService`), mai una riga DB
/// grezza passata al widget.
class WorkoutActivityPoint {
  const WorkoutActivityPoint({
    required this.periodStart,
    required this.sessionCount,
    required this.completedSessions,
  });

  final DateTime periodStart;
  final int sessionCount;
  final int completedSessions;
}
