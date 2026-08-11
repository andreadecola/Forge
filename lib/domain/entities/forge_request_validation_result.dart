/// Esito della validazione di una [ForgeRequest] (Milestone 5.1). Stesso
/// pattern di `WorkoutValidationResult`: messaggi già in italiano, pronti
/// per la UI (a differenza di [ForgeExclusionReason], che riguarda gli
/// esercizi e resta invece a codici domain — sezione 15/44).
class ForgeRequestValidationResult {
  const ForgeRequestValidationResult({required this.errors});

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}
