import '../entities/walking_session.dart';
import '../entities/walking_session_status.dart';
import '../entities/walking_session_validation_result.dart';

class WalkingSessionValidationService {
  const WalkingSessionValidationService();

  WalkingSessionValidationResult validate(WalkingSession session) {
    final errors = <String>[];

    if (session.profileId <= 0) {
      errors.add('Il profilo associato alla camminata non è valido.');
    }
    if (session.distanceMeters != null && session.distanceMeters! < 0) {
      errors.add('La distanza non può essere negativa.');
    }
    if (session.steps != null && session.steps! < 0) {
      errors.add('I passi non possono essere negativi.');
    }
    if (session.accumulatedPauseSeconds < 0) {
      errors.add('La durata della pausa non puo essere negativa.');
    }
    if (session.pauseStartedAt != null &&
        session.pauseStartedAt!.isBefore(session.startedAt)) {
      errors.add('La pausa non puo iniziare prima della camminata.');
    }
    if (session.isPaused && session.pauseStartedAt == null) {
      errors.add('Una camminata in pausa richiede una data di inizio pausa.');
    }
    if (!session.isPaused && session.pauseStartedAt != null) {
      errors.add('Una camminata attiva non puo avere una pausa aperta.');
    }
    if (session.endedAt != null &&
        session.endedAt!.isBefore(session.startedAt)) {
      errors.add('La data di fine non può precedere la data di inizio.');
    }

    switch (session.status) {
      case WalkingSessionStatus.inProgress:
        break;
      case WalkingSessionStatus.completed:
        if (session.endedAt == null) {
          errors.add('Una camminata completata deve avere una data di fine.');
        }
        break;
      case WalkingSessionStatus.aborted:
        if (session.endedAt == null) {
          errors.add('Una camminata interrotta deve avere una data di fine.');
        }
        break;
    }

    if (session.status != WalkingSessionStatus.inProgress &&
        (session.isPaused || session.pauseStartedAt != null)) {
      errors.add('Una camminata terminata non puo essere in pausa.');
    }

    return WalkingSessionValidationResult(errors: errors);
  }
}
