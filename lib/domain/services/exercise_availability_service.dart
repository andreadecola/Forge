import '../entities/equipment.dart';
import '../entities/exercise.dart';
import '../entities/exercise_availability_status.dart';
import 'exercise_level_policy.dart';

/// Valuta la disponibilità di un esercizio in base a livello utente e
/// attrezzatura posseduta.
///
/// In Milestone 3.3 produce solo [ExerciseAvailabilityStatus.available],
/// [ExerciseAvailabilityStatus.lockedLevel] e
/// [ExerciseAvailabilityStatus.lockedEquipment]. Gli stati `recommended`,
/// `temporarilyAvoided`, `mastered` sono demandati al futuro Forge Engine.
///
/// Priorità: prima il livello, poi l'attrezzatura.
class ExerciseAvailabilityService {
  const ExerciseAvailabilityService();

  /// [requiredEquipmentCodes] sono i codici master delle attrezzature
  /// **obbligatorie** dell'esercizio. Il codice speciale `NONE` viene
  /// ignorato: un esercizio che richiede solo `NONE` è sempre disponibile
  /// (a parità di livello), indipendentemente dall'inventario.
  ///
  /// `HOUSEHOLD` è trattato come una normale attrezzatura richiesta: se non
  /// posseduto, l'esercizio risulta [ExerciseAvailabilityStatus.lockedEquipment].
  ExerciseAvailabilityStatus evaluate({
    required Exercise exercise,
    required int userLevel,
    required Set<String> ownedEquipmentCodes,
    required Iterable<String> requiredEquipmentCodes,
  }) {
    if (!ExerciseLevelPolicy.isExerciseCompatible(exercise, userLevel)) {
      return ExerciseAvailabilityStatus.lockedLevel;
    }

    if (missingEquipment(
      requiredEquipmentCodes: requiredEquipmentCodes,
      ownedEquipmentCodes: ownedEquipmentCodes,
    ).isNotEmpty) {
      return ExerciseAvailabilityStatus.lockedEquipment;
    }

    return ExerciseAvailabilityStatus.available;
  }

  /// Attrezzatura obbligatoria (`NONE` escluso) non presente in
  /// [ownedEquipmentCodes]: punto unico della regola, condiviso anche dal
  /// Forge Engine (`ForgeEligibilityService`, Milestone 5.1) — evita una
  /// seconda interpretazione della stessa regola.
  static Iterable<String> missingEquipment({
    required Iterable<String> requiredEquipmentCodes,
    required Set<String> ownedEquipmentCodes,
  }) {
    return requiredEquipmentCodes
        .where((code) => code != Equipment.noneCode)
        .where((code) => !ownedEquipmentCodes.contains(code));
  }
}
