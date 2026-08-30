import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';
import '../repositories/walking_session_repository.dart';

/// Stesso principio di [LinkWorkoutSession], per `camminate` (Milestone
/// 8.5, sezione 15/40/41/114).
class LinkWalkingSession {
  const LinkWalkingSession(
    this._plannedActivityRepository,
    this._walkingSessionRepository,
  );

  final PlannedActivityRepository _plannedActivityRepository;
  final WalkingSessionRepository _walkingSessionRepository;

  Future<void> call({
    required PlannedActivity activity,
    required int walkingSessionId,
  }) async {
    if (activity.type != PlannedActivityType.walk) {
      throw ArgumentError(
        'Solo un\'attività di tipo camminata può collegare una sessione di '
        'camminata.',
      );
    }
    final session = await _walkingSessionRepository.getWalkingSession(
      walkingSessionId,
    );
    if (session == null || session.profileId != activity.profileId) {
      throw ArgumentError(
        'La sessione di camminata non appartiene a questo profilo.',
      );
    }
    await _plannedActivityRepository.linkWalkingSession(
      activityId: activity.id!,
      walkingSessionId: walkingSessionId,
    );
  }
}
