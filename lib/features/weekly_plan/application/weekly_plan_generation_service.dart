import '../../../domain/entities/forge_request.dart';
import '../../../domain/entities/planned_activity_enums.dart';
import '../../../domain/entities/weekly_plan_generation_error.dart';
import '../../../domain/entities/weekly_plan_generation_proposal.dart';
import '../../../domain/entities/weekly_plan_generation_result.dart';
import '../../../domain/entities/workout_enums.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/planned_activity_repository.dart';
import '../../../domain/services/clock.dart';
import '../../../domain/services/forge_week_distribution_service.dart';
import '../../../domain/services/user_equipment_resolver.dart';
import '../../../domain/services/weekly_planning_date_service.dart';
import '../../../domain/use_cases/generate_adapted_forge_workout.dart';

/// Orchestratore della generazione automatica settimanale (Milestone 8.4).
///
/// Separazione di responsabilità (sezione 72/73), nessuna sovrapposta:
/// - **Forge Engine** ([GenerateAdaptedForgeWorkout], Milestone 5): decide
///   "che allenamento genero?" — invariato, mai reimplementato qui.
/// - **Questo servizio**: decide "in quali giorni della settimana lo
///   colloco?" e costruisce la proposta — nessuna scelta di esercizi,
///   punteggio, eleggibilità o adattamento.
/// - **`WeeklyPlanGenerationRepository`** (data layer): persiste la
///   proposta confermata in modo atomico.
///
/// [buildProposal] non scrive mai sul database (sezione 26/76): usa solo
/// [GenerateAdaptedForgeWorkout], che di per sé non persiste nulla (Milestone
/// 5.2/5.4), e una lettura one-shot delle attività già pianificate.
class WeeklyPlanGenerationService {
  // Parametri posizionali (stesso stile dei use case Forge Engine, es.
  // `GenerateAdaptedForgeWorkout`/`PersistGeneratedWorkout`): un initializing
  // formal `this._campo` su un named parameter renderebbe il nome privato
  // (`_campo:`) non richiamabile da fuori questo file.
  const WeeklyPlanGenerationService(
    this._plannedActivityRepository,
    this._generateAdaptedForgeWorkout,
    this._equipmentRepository,
    this._clock,
  );

  final PlannedActivityRepository _plannedActivityRepository;
  final GenerateAdaptedForgeWorkout _generateAdaptedForgeWorkout;
  final EquipmentRepository _equipmentRepository;
  final Clock _clock;

  Future<WeeklyPlanGenerationResult> buildProposal({
    required int profileId,
    required DateTime weekReference,
    required WorkoutType workoutType,
    required int targetDurationMinutes,
    required int userLevel,
    required int requestedCount,
  }) async {
    if (requestedCount <= 0) {
      return const WeeklyPlanGenerationResult(
        errors: [WeeklyPlanGenerationError.invalidRequestedCount],
      );
    }

    final weekStart = WeeklyPlanningDateService.weekStart(weekReference);
    final weekEnd = WeeklyPlanningDateService.weekEnd(weekReference);
    final today = WeeklyPlanningDateService.atMidnight(_clock.now());

    final existingActivities = await _plannedActivityRepository.getForWeek(
      profileId: profileId,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );
    // Strategia minima di rigenerazione (sezione 32/33/34): bloccare una
    // seconda generazione se la settimana contiene già attività
    // FORGE_ENGINE, invece di sostituirle/duplicarle silenziosamente — le
    // semantiche di sostituzione esplicita appartengono a Milestone 8.7+.
    // Il controllo guarda solo `origin`, mai `status` (Milestone 8.6,
    // sezione 34/80): una FORGE_ENGINE SKIPPED/POSTPONED conta comunque
    // come "attività Forge presente" — l'utente la elimina esplicitamente
    // (flusso già disponibile) se vuole rigenerare la settimana.
    if (existingActivities.any(
      (activity) => activity.origin == PlannedActivityOrigin.forgeEngine,
    )) {
      return const WeeklyPlanGenerationResult(
        errors: [WeeklyPlanGenerationError.weekAlreadyHasForgeActivities],
      );
    }

    final eligibleDays = ForgeWeekDistributionService.eligibleDays(
      weekStart: weekStart,
      weekEnd: weekEnd,
      today: today,
    );
    if (eligibleDays == null) {
      return const WeeklyPlanGenerationResult(
        errors: [WeeklyPlanGenerationError.weekEntirelyInPast],
      );
    }

    final occupiedDaySet = existingActivities
        .map((activity) => activity.scheduledDate)
        .toSet();
    final freeDays = eligibleDays
        .where((day) => !occupiedDaySet.contains(day))
        .toList();
    final occupiedDays = eligibleDays
        .where((day) => occupiedDaySet.contains(day))
        .toList();

    final days = ForgeWeekDistributionService.distribute(
      freeDays: freeDays,
      occupiedDays: occupiedDays,
      count: requestedCount,
    );

    final ownedEquipment = await _equipmentRepository.getOwnedEquipment(
      profileId,
    );
    final equipmentCodes = UserEquipmentResolver.toMasterCodes(
      ownedEquipment.map((state) => state.item.code),
    );
    final request = ForgeRequest(
      profileId: profileId,
      userLevel: userLevel,
      availableEquipmentCodes: equipmentCodes,
      targetDurationMinutes: targetDurationMinutes,
      workoutType: workoutType,
    );

    final entries = <ProposedForgeWorkout>[];
    for (final day in days) {
      final result = await _generateAdaptedForgeWorkout(
        request: request,
        profileId: profileId,
        now: _clock.now(),
      );
      if (!result.success || result.plan == null) {
        // Deterministico (Milestone 5): la stessa richiesta fallisce
        // sempre allo stesso modo, quindi il primo fallimento vale per
        // tutti i giorni rimanenti — nessun bisogno di tentare gli altri.
        return WeeklyPlanGenerationResult(
          errors: const [],
          forgeErrors: result.errors,
          forgeWarnings: result.warnings,
        );
      }
      entries.add(
        ProposedForgeWorkout(scheduledDate: day, generationResult: result),
      );
    }

    return WeeklyPlanGenerationResult(
      proposal: WeeklyPlanGenerationProposal(
        weekStart: weekStart,
        weekEnd: weekEnd,
        entries: entries,
      ),
    );
  }
}
