import 'forge_generation_warning.dart';
import 'persist_generated_workout_error.dart';

/// Esito della persistenza di un piano generato (Milestone 5.3): mai un
/// semplice `int` — si perderebbe la spiegabilità di *perché* non è
/// stato salvato (sezione 23).
class PersistGeneratedWorkoutResult {
  const PersistGeneratedWorkoutResult({
    this.workoutId,
    required this.errors,
    required this.warnings,
  });

  /// `errors.isEmpty` — un getter, non un campo indipendente, stesso
  /// principio di `ForgeGenerationResult.success` (Milestone 5.2).
  bool get success => errors.isEmpty;

  /// L'id della scheda persistita, `null` se e solo se [success] è
  /// `false`.
  final int? workoutId;

  final List<PersistGeneratedWorkoutError> errors;

  /// Propagati da `ForgeGenerationResult.warnings` (sezione 25): un piano
  /// con warning ma altrimenti valido viene comunque salvato — i warning
  /// non sono un motivo di blocco, solo informazione conservata.
  final List<ForgeGenerationWarning> warnings;
}
