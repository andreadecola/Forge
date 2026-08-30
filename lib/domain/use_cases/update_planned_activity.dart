import '../../core/validation/onboarding_validators.dart';
import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';

/// Valida e corregge un'attività pianificata già persistita (Milestone 8.1):
/// stessa validazione di [AddPlannedActivity], più il vincolo di coerenza
/// con una sessione già collegata (Milestone 8.5, sezione 30-32): una
/// volta collegata una sessione reale (attiva o completata), tipo e scheda
/// referenziata non possono più cambiare — altrimenti il piano
/// mostrerebbe un tipo/scheda diversi da quelli della sessione realmente
/// avviata (sezione 31, "PlannedActivity type WALK ma collegata a
/// WorkoutSession"). `scheduledDate`/`plannedDurationMinutes` restano
/// liberamente modificabili: spostare un'attività già eseguita in un altro
/// giorno del piano non crea alcuna incoerenza con la sessione.
///
/// "Sposta" (Milestone 8.6, sezione 16/31) non è un use case a parte: è
/// esattamente questo stesso metodo con una nuova `scheduledDate`. Quando
/// la data cambia rispetto a quella esistente e lo stato persistito era
/// `SKIPPED`/`POSTPONED`, questo metodo lo riporta a `PLANNED` — la nuova
/// data rappresenta un nuovo piano attivo, mai un'attività ancora saltata/
/// rinviata per un altro giorno. La regola vive qui (non nel form/widget)
/// così ogni chiamante — il form generico M8.2 e l'azione dedicata
/// "Sposta" — resta automaticamente coerente (sezione 46).
class UpdatePlannedActivity {
  const UpdatePlannedActivity(this._repository);

  final PlannedActivityRepository _repository;

  Future<void> call(PlannedActivity activity) async {
    final error = _validate(activity);
    if (error != null) throw ArgumentError(error);

    final existing = await _repository.getById(activity.id!);
    var toPersist = activity;
    if (existing != null) {
      final linkError = _validateSessionLinkUnchanged(existing, activity);
      if (linkError != null) throw ArgumentError(linkError);
      toPersist = _resetStatusIfMoved(existing, activity);
    }

    return _repository.updatePlannedActivity(toPersist);
  }

  static PlannedActivity _resetStatusIfMoved(
    PlannedActivity existing,
    PlannedActivity updated,
  ) {
    final dateChanged = updated.scheduledDate != existing.scheduledDate;
    final wasSkippedOrPostponed =
        existing.status == PlannedActivityStatus.skipped ||
        existing.status == PlannedActivityStatus.postponed;
    if (!dateChanged || !wasSkippedOrPostponed) return updated;
    return updated.copyWith(status: PlannedActivityStatus.planned);
  }

  static String? _validate(PlannedActivity activity) {
    return OnboardingValidators.profileId(activity.profileId) ??
        _validateWorkoutReference(activity) ??
        _validateSessionReferences(activity);
  }

  static String? _validateWorkoutReference(PlannedActivity activity) {
    final requiresWorkout = activity.type == PlannedActivityType.workout;
    if (requiresWorkout && activity.workoutId == null) {
      return 'Indica la scheda da collegare all\'allenamento pianificato.';
    }
    if (!requiresWorkout && activity.workoutId != null) {
      return 'Solo un\'attività di tipo allenamento può referenziare una scheda.';
    }
    return null;
  }

  static String? _validateSessionReferences(PlannedActivity activity) {
    if (activity.type != PlannedActivityType.workout &&
        activity.workoutSessionId != null) {
      return 'Solo un\'attività di tipo allenamento può referenziare una '
          'sessione di allenamento.';
    }
    if (activity.type != PlannedActivityType.walk &&
        activity.walkingSessionId != null) {
      return 'Solo un\'attività di tipo camminata può referenziare una '
          'sessione di camminata.';
    }
    return null;
  }

  static String? _validateSessionLinkUnchanged(
    PlannedActivity existing,
    PlannedActivity updated,
  ) {
    final hasSession =
        existing.workoutSessionId != null || existing.walkingSessionId != null;
    if (!hasSession) return null;
    if (existing.type != updated.type) {
      return 'Non puoi cambiare il tipo di un\'attività già collegata a una '
          'sessione.';
    }
    if (existing.workoutId != updated.workoutId) {
      return 'Non puoi cambiare la scheda di un\'attività già collegata a '
          'una sessione.';
    }
    return null;
  }
}
