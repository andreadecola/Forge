import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';
import '../repositories/walking_session_repository.dart';
import '../repositories/workout_session_repository.dart';
import 'planned_activity_session_lookup.dart';

/// Segna esplicitamente una `PlannedActivity` come rinviata (Milestone 8.6,
/// sezione 7/30): l'utente rinvia senza assegnare subito una nuova data —
/// [PlannedActivity.scheduledDate] resta la data originariamente prevista
/// (mostrata come riferimento, mai una nuova data nulla o inventata).
/// Per assegnare una nuova data si usa "Sposta" (`UpdatePlannedActivity`),
/// che riporta lo stato a [PlannedActivityStatus.planned] (sezione 31).
///
/// Stesse guardie di [SkipPlannedActivity]: bloccato se la sessione reale
/// collegata è ancora attiva o già completata.
class PostponePlannedActivity {
  const PostponePlannedActivity(
    this._plannedActivityRepository,
    this._workoutSessionRepository,
    this._walkingSessionRepository,
  );

  final PlannedActivityRepository _plannedActivityRepository;
  final WorkoutSessionRepository _workoutSessionRepository;
  final WalkingSessionRepository _walkingSessionRepository;

  Future<void> call(int activityId) async {
    final activity = await _plannedActivityRepository.getById(activityId);
    if (activity == null) return;
    if (activity.status == PlannedActivityStatus.postponed) return;

    final sessionState = await resolveLinkedSessionState(
      activity,
      _workoutSessionRepository,
      _walkingSessionRepository,
    );
    final blockReason = blockReasonForActiveOrCompletedSession(
      activity,
      sessionState,
    );
    if (blockReason != null) throw ArgumentError(blockReason);

    await _plannedActivityRepository.updatePlannedActivity(
      activity.copyWith(status: PlannedActivityStatus.postponed),
    );
  }
}
