/// Esito di una validazione [WorkoutValidationService]. Mai solo un bool:
/// [errors] contiene messaggi già in italiano, pronti per essere mostrati
/// in UI (Milestone 4.3) senza ulteriore traduzione.
class WorkoutValidationResult {
  const WorkoutValidationResult({required this.errors});

  static const WorkoutValidationResult valid = WorkoutValidationResult(
    errors: [],
  );

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}
