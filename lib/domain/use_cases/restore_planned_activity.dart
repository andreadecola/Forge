import '../entities/planned_activity_enums.dart';
import '../repositories/planned_activity_repository.dart';

/// Riporta una `PlannedActivity` `SKIPPED`/`POSTPONED` a `PLANNED`
/// (Milestone 8.6, sezione 29): reversibilità semplice, senza toccare
/// `scheduledDate` né alcun altro campo.
///
/// Nessuna guardia di sessione necessaria: [PlannedActivityStatus.skipped]/
/// [PlannedActivityStatus.postponed] implicano già l'assenza di una
/// sessione attiva o completata (garantito da [SkipPlannedActivity]/
/// [PostponePlannedActivity] all'origine, e la UI non offre mai di avviare
/// una sessione su un'attività in questi stati).
class RestorePlannedActivity {
  const RestorePlannedActivity(this._plannedActivityRepository);

  final PlannedActivityRepository _plannedActivityRepository;

  Future<void> call(int activityId) async {
    final activity = await _plannedActivityRepository.getById(activityId);
    if (activity == null) return;
    // Idempotente (sezione 43): già pianificata, nessun effetto duplicato.
    if (activity.status == PlannedActivityStatus.planned) return;

    await _plannedActivityRepository.updatePlannedActivity(
      activity.copyWith(status: PlannedActivityStatus.planned),
    );
  }
}
