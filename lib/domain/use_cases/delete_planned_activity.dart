import '../repositories/planned_activity_repository.dart';
import '../repositories/walking_session_repository.dart';
import '../repositories/workout_session_repository.dart';
import 'planned_activity_session_lookup.dart';

/// Elimina una `PlannedActivity`, con una guardia minima (Milestone 8.5,
/// sezione 28): se la sessione reale collegata è ancora ATTIVA (Workout
/// IN_PROGRESS/PAUSED, Walk IN_PROGRESS), l'eliminazione è rifiutata —
/// eliminare il piano lasciando una sessione attiva "orfana" e non più
/// raggiungibile dal Piano Settimanale sarebbe uno stato confuso, non un
/// vantaggio reale per l'utente (che può comunque terminarla dai flussi
/// M4/M6 esistenti prima di riprovare). Una sessione COMPLETED o ABORTED
/// non blocca mai l'eliminazione (sezione 29): la sessione reale resta
/// comunque nello storico, mai toccata da questa operazione (sezione 27).
class DeletePlannedActivity {
  const DeletePlannedActivity(
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

    final sessionState = await resolveLinkedSessionState(
      activity,
      _workoutSessionRepository,
      _walkingSessionRepository,
    );
    if (sessionState == LinkedSessionState.active) {
      final message = activity.workoutSessionId != null
          ? 'Termina o interrompi prima la sessione di allenamento in corso.'
          : 'Termina o interrompi prima la camminata in corso.';
      throw ArgumentError(message);
    }

    await _plannedActivityRepository.deletePlannedActivity(activityId);
  }
}
