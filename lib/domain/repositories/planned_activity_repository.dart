import '../entities/planned_activity.dart';

abstract class PlannedActivityRepository {
  Future<PlannedActivity?> getById(int id);

  /// [weekStart]/[weekEnd] sono calcolati da `WeeklyPlanningDateService`:
  /// il repository si limita a filtrare per intervallo (sezione 37, nessuna
  /// logica di dominio nel DAO), non ricalcola la settimana da solo.
  Future<List<PlannedActivity>> getForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  });

  Stream<List<PlannedActivity>> watchForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  });

  /// Tutte le attività pianificate del profilo, senza vincolo di
  /// settimana (Backup.2): copre l'intero Piano Settimanale storico,
  /// presente e futuro in un'unica lettura.
  Future<List<PlannedActivity>> getAllForProfile({required int profileId});

  Future<int> addPlannedActivity(PlannedActivity activity);

  Future<void> updatePlannedActivity(PlannedActivity activity);

  /// Elimina solo l'attività pianificata: non elimina mai la scheda
  /// referenziata da [PlannedActivity.workoutId] (sezione 57).
  Future<void> deletePlannedActivity(int id);

  /// Collega la `WorkoutSession` reale nata avviando [activityId]
  /// (Milestone 8.5): sovrascrive un eventuale collegamento precedente
  /// (es. una sessione abortita) — quella resta comunque nello storico di
  /// `sessioni_allenamento`, mai eliminata da questa scrittura.
  Future<void> linkWorkoutSession({
    required int activityId,
    required int workoutSessionId,
  });

  /// Stesso principio per `camminate`.
  Future<void> linkWalkingSession({
    required int activityId,
    required int walkingSessionId,
  });
}
