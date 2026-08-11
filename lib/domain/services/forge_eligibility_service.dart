import '../entities/forge_candidate.dart';
import '../entities/forge_eligibility_result.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_exclusion_reason.dart';
import 'exercise_availability_service.dart';
import 'exercise_duration_estimator.dart';
import 'exercise_level_policy.dart';

/// Stabilisce se un [ForgeCandidate] può entrare nel pool dei candidati
/// (Milestone 5.1, sezione 13): solo vincoli **HARD** — esercizio
/// attivo, livello compatibile, attrezzatura disponibile, parametri
/// sufficienti a stimare una durata. Le preferenze di categoria
/// (`ForgeWorkoutTypePolicy`) sono un vincolo SOFT: non influenzano
/// l'eleggibilità, solo il punteggio (sezione 14, vedi `ForgeScoringService`).
///
/// Riusa le stesse policy già esistenti — [ExerciseLevelPolicy] e la
/// regola di attrezzatura mancante di [ExerciseAvailabilityService] —
/// senza reinterpretarle (sezione 7/8, STOP 3): un esercizio che il
/// catalogo giudica `lockedLevel`/`lockedEquipment` è escluso qui con lo
/// stesso identico criterio, solo riportato con motivi domain espliciti
/// invece di un unico stato UI.
class ForgeEligibilityService {
  const ForgeEligibilityService();

  ForgeEligibilityResult evaluate({
    required ForgeCandidate candidate,
    required int userLevel,
    required Set<String> availableEquipmentCodes,
    required ForgeEngineConfig config,
  }) {
    final reasons = <ForgeExclusionReason>[];
    final exercise = candidate.exercise;

    if (!exercise.isActive) {
      reasons.add(ForgeExclusionReason.inactive);
    }

    // Il booleano di compatibilità è sempre quello di `ExerciseLevelPolicy`
    // (nessuna seconda interpretazione, STOP 3): qui si aggiunge solo la
    // distinzione *quale* delle due direzioni ha fallito, per un motivo
    // di esclusione più preciso — un'informazione che la sola risposta
    // booleana della policy condivisa non porta.
    if (!ExerciseLevelPolicy.isExerciseCompatible(exercise, userLevel)) {
      reasons.add(
        exercise.minimumLevel > userLevel
            ? ForgeExclusionReason.levelTooHigh
            : ForgeExclusionReason.levelTooLow,
      );
    }

    if (ExerciseAvailabilityService.missingEquipment(
      requiredEquipmentCodes: candidate.requiredEquipmentCodes,
      ownedEquipmentCodes: availableEquipmentCodes,
    ).isNotEmpty) {
      reasons.add(ForgeExclusionReason.missingEquipment);
    }

    if (ExerciseDurationEstimator.estimateSeconds(
          exercise: exercise,
          config: config,
        ) ==
        null) {
      reasons.add(ForgeExclusionReason.unsupportedParameters);
    }

    return reasons.isEmpty
        ? const ForgeEligibilityResult.eligible()
        : ForgeEligibilityResult(eligible: false, reasons: reasons);
  }
}
