import '../entities/planned_activity.dart';
import '../entities/walking_session_status.dart';
import '../entities/workout_session_persistence_status.dart';
import '../repositories/walking_session_repository.dart';
import '../repositories/workout_session_repository.dart';

/// Stato reale (one-shot) della sessione collegata a una `PlannedActivity`
/// (Milestone 8.5/8.6): equivalente di dominio di
/// `PlannedActivitySessionState` (livello presentation, reattivo tramite
/// Riverpod) — qui una singola lettura, usata dagli use case che devono
/// decidere se un'azione (elimina/salta/rinvia) è consentita.
///
/// [none] copre sia "nessuna sessione mai collegata" sia "collegata ma
/// ABORTED" (sezione 15 della Milestone 8.6): in entrambi i casi
/// l'attività torna semanticamente disponibile.
enum LinkedSessionState { none, active, completed }

/// Legge lo stato della sessione reale collegata a [activity], se
/// presente — mai un matching implicito, solo gli id già persistiti su
/// [PlannedActivity.workoutSessionId]/[PlannedActivity.walkingSessionId].
Future<LinkedSessionState> resolveLinkedSessionState(
  PlannedActivity activity,
  WorkoutSessionRepository workoutSessionRepository,
  WalkingSessionRepository walkingSessionRepository,
) async {
  if (activity.workoutSessionId != null) {
    final session = await workoutSessionRepository.getSessionById(
      activity.workoutSessionId!,
    );
    return linkedStateFromWorkoutStatus(session?.status);
  }
  if (activity.walkingSessionId != null) {
    final session = await walkingSessionRepository.getWalkingSession(
      activity.walkingSessionId!,
    );
    return linkedStateFromWalkingStatus(session?.status);
  }
  return LinkedSessionState.none;
}

/// Mappatura pura, riusata sia da [resolveLinkedSessionState] (lettura
/// one-shot sui repository) sia dal resolver reattivo di
/// `weeklyPlanSummaryProvider` (Milestone 8.7 patch, basato su
/// `ref.watch` sugli stessi provider di stato sessione usati da
/// `PlannedActivityPresentation`) — un'unica fonte di verità per "quale
/// `LinkedSessionState` rappresenta questo stato di sessione Workout".
LinkedSessionState linkedStateFromWorkoutStatus(
  WorkoutSessionPersistenceStatus? status,
) => switch (status) {
  WorkoutSessionPersistenceStatus.inProgress ||
  WorkoutSessionPersistenceStatus.paused => LinkedSessionState.active,
  WorkoutSessionPersistenceStatus.completed => LinkedSessionState.completed,
  WorkoutSessionPersistenceStatus.aborted || null => LinkedSessionState.none,
};

/// Stesso principio di [linkedStateFromWorkoutStatus], per Walking.
LinkedSessionState linkedStateFromWalkingStatus(WalkingSessionStatus? status) =>
    switch (status) {
      WalkingSessionStatus.inProgress => LinkedSessionState.active,
      WalkingSessionStatus.completed => LinkedSessionState.completed,
      WalkingSessionStatus.aborted || null => LinkedSessionState.none,
    };

/// Messaggio di blocco per un'azione che richiede "nessuna sessione attiva
/// né già completata" ([SkipPlannedActivity]/[PostponePlannedActivity],
/// sezione 13/14 della Milestone 8.6) — `null` se l'azione è consentita.
/// Una sessione `ABORTED` (derivata come [LinkedSessionState.none]) non
/// blocca mai: l'attività torna semanticamente disponibile (sezione 15).
String? blockReasonForActiveOrCompletedSession(
  PlannedActivity activity,
  LinkedSessionState sessionState,
) {
  final isWorkout = activity.workoutSessionId != null;
  return switch (sessionState) {
    LinkedSessionState.none => null,
    LinkedSessionState.active =>
      isWorkout
          ? 'Termina o interrompi prima la sessione di allenamento in corso.'
          : 'Termina o interrompi prima la camminata in corso.',
    LinkedSessionState.completed =>
      isWorkout
          ? 'Questo allenamento è già stato completato.'
          : 'Questa camminata è già stata completata.',
  };
}
