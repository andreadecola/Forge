import 'exercise_catalog_enums.dart';

/// Esercizio del catalogo (dati scalari). Le relazioni complete (categoria
/// risolta, muscoli, attrezzatura, immagini, progressioni, alternative) sono
/// aggregate in [ExerciseDetails]: `Exercise` resta leggero per le query di
/// elenco/ricerca ed espone `categoryCode` per il collegamento.
class Exercise {
  const Exercise({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.instructions,
    this.breathingInstructions,
    this.safetyNotes,
    this.commonMistakes,
    required this.categoryId,
    required this.minimumLevel,
    this.maximumLevel,
    required this.impactLevel,
    this.cardioIntensity,
    required this.balanceRequired,
    required this.floorRequired,
    required this.standingRequired,
    required this.supportAllowed,
    this.defaultSets,
    this.defaultReps,
    this.defaultDurationSeconds,
    this.defaultRestSeconds,
    required this.isSystem,
    required this.isActive,
    required this.catalogVersion,
  });

  final int id;
  final String code;
  final String name;
  final String description;
  final String instructions;
  final String? breathingInstructions;
  final String? safetyNotes;
  final String? commonMistakes;
  final int categoryId;
  final int minimumLevel;
  final int? maximumLevel;
  final ExerciseImpactLevel impactLevel;
  final ExerciseCardioIntensity? cardioIntensity;
  final bool balanceRequired;
  final bool floorRequired;
  final bool standingRequired;
  final bool supportAllowed;
  final int? defaultSets;
  final int? defaultReps;
  final int? defaultDurationSeconds;
  final int? defaultRestSeconds;
  final bool isSystem;
  final bool isActive;
  final int catalogVersion;
}
