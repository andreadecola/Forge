import 'exercise.dart';
import 'exercise_details.dart';

/// Proiezione di [ExerciseDetails] con solo ciò che serve alle decisioni
/// del Forge Engine (Milestone 5.1, sezione 12): niente immagini,
/// progressioni, alternative — informazioni utili alla UI del catalogo,
/// irrilevanti per eleggibilità/punteggio.
class ForgeCandidate {
  const ForgeCandidate({
    required this.exercise,
    required this.categoryCode,
    required this.primaryMuscleCodes,
    required this.secondaryMuscleCodes,
    required this.requiredEquipmentCodes,
  });

  factory ForgeCandidate.fromExerciseDetails(ExerciseDetails details) {
    return ForgeCandidate(
      exercise: details.exercise,
      categoryCode: details.category.code,
      primaryMuscleCodes: details.primaryMuscles.map((m) => m.code).toSet(),
      secondaryMuscleCodes: details.secondaryMuscles.map((m) => m.code).toSet(),
      requiredEquipmentCodes: details.equipment
          .where((e) => e.required)
          .map((e) => e.equipment.code)
          .toSet(),
    );
  }

  final Exercise exercise;
  final String categoryCode;
  final Set<String> primaryMuscleCodes;
  final Set<String> secondaryMuscleCodes;

  /// Codici master delle attrezzature **obbligatorie** (`NONE` incluso se
  /// presente così com'è nel catalogo — è compito di chi valuta
  /// l'eleggibilità ignorarlo, stesso principio di
  /// `ExerciseAvailabilityService`).
  final Set<String> requiredEquipmentCodes;
}
