import 'package:forge/domain/entities/equipment.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_catalog_enums.dart';
import 'package:forge/domain/entities/exercise_category.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/forge_candidate.dart';
import 'package:forge/domain/entities/forge_eligibility_result.dart';
import 'package:forge/domain/entities/forge_exercise_evaluation.dart';
import 'package:forge/domain/entities/forge_score.dart';
import 'package:forge/domain/entities/muscle_group.dart';

/// Fixture condivise dai test del Forge Engine (Milestone 5.1): stesso
/// stile di `exercise_availability_service_test.dart`.
Exercise buildExercise({
  int id = 1,
  String code = 'X-001',
  int minimumLevel = 1,
  int? maximumLevel,
  bool isActive = true,
  int? defaultSets,
  int? defaultReps,
  int? defaultDurationSeconds,
  int? defaultRestSeconds,
}) {
  return Exercise(
    id: id,
    code: code,
    name: 'Esercizio $code',
    description: 'desc',
    instructions: 'istr',
    categoryId: 1,
    minimumLevel: minimumLevel,
    maximumLevel: maximumLevel,
    impactLevel: ExerciseImpactLevel.low,
    balanceRequired: false,
    floorRequired: false,
    standingRequired: false,
    supportAllowed: false,
    defaultSets: defaultSets,
    defaultReps: defaultReps,
    defaultDurationSeconds: defaultDurationSeconds,
    defaultRestSeconds: defaultRestSeconds,
    isSystem: true,
    isActive: isActive,
    catalogVersion: 1,
  );
}

ExerciseCategory buildCategory({int id = 1, String code = 'CORE'}) {
  return ExerciseCategory(
    id: id,
    code: code,
    name: 'Categoria $code',
    displayOrder: 1,
    active: true,
  );
}

ExerciseDetails buildExerciseDetails({
  required Exercise exercise,
  String categoryCode = 'CORE',
  List<String> requiredEquipmentCodes = const [],
  List<String> primaryMuscleCodes = const [],
}) {
  return ExerciseDetails(
    exercise: exercise,
    category: buildCategory(code: categoryCode),
    primaryMuscles: [
      for (final code in primaryMuscleCodes)
        MuscleGroup(id: 1, code: code, name: code, active: true),
    ],
    secondaryMuscles: const [],
    equipment: [
      for (final code in requiredEquipmentCodes)
        ExerciseEquipmentRequirement(
          equipment: Equipment(
            id: 1,
            code: code,
            name: code,
            priority: 1,
            active: true,
            catalogVersion: 1,
          ),
          required: true,
        ),
    ],
    images: const [],
    progressions: const [],
    regressions: const [],
    alternatives: const [],
  );
}

ForgeCandidate buildCandidate({
  required Exercise exercise,
  String categoryCode = 'CORE',
  Set<String> requiredEquipmentCodes = const {},
  Set<String> primaryMuscleCodes = const {},
}) {
  return ForgeCandidate(
    exercise: exercise,
    categoryCode: categoryCode,
    primaryMuscleCodes: primaryMuscleCodes,
    secondaryMuscleCodes: const {},
    requiredEquipmentCodes: requiredEquipmentCodes,
  );
}

/// Valutazione eleggibile pronta all'uso per i test del
/// `ForgeWorkoutComposer` (Milestone 5.2): costruita direttamente, senza
/// passare per `ForgeEligibilityService`/`ForgeScoringService` — questi
/// sono già testati dalla Milestone 5.1, qui serve solo controllare
/// categoria/muscoli/punteggio/durata in modo esplicito per isolare
/// l'algoritmo di composizione.
ForgeExerciseEvaluation buildEvaluation({
  required Exercise exercise,
  String categoryCode = 'CORE',
  Set<String> primaryMuscleCodes = const {},
  required double scoreTotal,
  required int estimatedDurationSeconds,
}) {
  return ForgeExerciseEvaluation(
    candidate: buildCandidate(
      exercise: exercise,
      categoryCode: categoryCode,
      primaryMuscleCodes: primaryMuscleCodes,
    ),
    eligibility: const ForgeEligibilityResult.eligible(),
    estimatedDurationSeconds: estimatedDurationSeconds,
    score: ForgeScore(
      total: scoreTotal,
      components: const [],
      reasons: const [],
    ),
  );
}
