import 'forge_coverage_requirement.dart';

/// Stato di copertura di una selezione di esercizi rispetto ai requisiti
/// di un `WorkoutType` (Milestone 5.2, sezione 25): calcolato in modo
/// deterministico da [ForgeWorkoutComposer] man mano che seleziona
/// esercizi, e in forma finale su [GeneratedWorkoutPlan].
class ForgeCoverageState {
  const ForgeCoverageState({
    required this.covered,
    required this.missing,
    required this.categoryCounts,
  });

  /// Requisiti già soddisfatti (almeno `minCount` esercizi in una delle
  /// categorie del requisito).
  final List<ForgeCoverageRequirement> covered;

  /// Requisiti non ancora soddisfatti.
  final List<ForgeCoverageRequirement> missing;

  /// Quante volte ogni categoria compare nella selezione corrente — usato
  /// anche per il vincolo `maxExercisesPerCategory` (sezione 26).
  final Map<String, int> categoryCounts;

  bool get isFullyCovered => missing.isEmpty;
}
