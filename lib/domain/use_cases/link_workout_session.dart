import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';
import '../repositories/workout_session_repository.dart';

/// Collega esplicitamente una `WorkoutSession` reale appena creata a una
/// `PlannedActivity` (Milestone 8.5): nessun matching implicito per
/// data/workoutId (sezione 15) — il chiamante passa l'id della sessione
/// appena avviata, ottenuto direttamente da `WorkoutSessionController`
/// (mai una query "ultima sessione", sezione 20/114).
///
/// Type safety (sezione 41) e isolamento profilo (sezione 40/73):
/// validati qui, non solo a livello SQL.
class LinkWorkoutSession {
  const LinkWorkoutSession(
    this._plannedActivityRepository,
    this._workoutSessionRepository,
  );

  final PlannedActivityRepository _plannedActivityRepository;
  final WorkoutSessionRepository _workoutSessionRepository;

  Future<void> call({
    required PlannedActivity activity,
    required int workoutSessionId,
  }) async {
    if (activity.type != PlannedActivityType.workout) {
      throw ArgumentError(
        'Solo un\'attività di tipo allenamento può collegare una sessione '
        'di allenamento.',
      );
    }
    final session = await _workoutSessionRepository.getSessionById(
      workoutSessionId,
    );
    if (session == null || session.profileId != activity.profileId) {
      throw ArgumentError(
        'La sessione di allenamento non appartiene a questo profilo.',
      );
    }
    await _plannedActivityRepository.linkWorkoutSession(
      activityId: activity.id!,
      workoutSessionId: workoutSessionId,
    );
  }
}
