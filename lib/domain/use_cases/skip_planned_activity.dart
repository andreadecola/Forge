import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';
import '../repositories/walking_session_repository.dart';
import '../repositories/workout_session_repository.dart';
import 'planned_activity_session_lookup.dart';

/// Segna esplicitamente una `PlannedActivity` come saltata (Milestone 8.6,
/// sezione 9/28): **sempre** una decisione dell'utente — mai dedotto da
/// `scheduledDate < oggi` (vietato, sezione 107). Nessuna sessione viene
/// creata né eliminata da questa azione.
///
/// Bloccato se la sessione reale collegata è ancora attiva o già
/// completata (sezione 13/14): "la realtà è già successa" non può essere
/// silenziosamente rietichettata come "saltata". Una sessione `ABORTED`
/// non blocca (sezione 15).
class SkipPlannedActivity {
  const SkipPlannedActivity(
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
    // Idempotente (sezione 43): già saltata, nessun effetto duplicato.
    if (activity.status == PlannedActivityStatus.skipped) return;

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
      activity.copyWith(status: PlannedActivityStatus.skipped),
    );
  }
}
