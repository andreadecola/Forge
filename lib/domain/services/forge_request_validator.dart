import '../entities/forge_request.dart';
import '../entities/forge_request_validation_result.dart';
import '../entities/workout_enums.dart';

/// Valida una [ForgeRequest] (Milestone 5.1, sezione 11). Da chiamare su
/// una richiesta già normalizzata (`ForgeRequestNormalizer`), anche se le
/// regole qui non dipendono dalla normalizzazione in sé.
abstract final class ForgeRequestValidator {
  static ForgeRequestValidationResult validate(ForgeRequest request) {
    final errors = <String>[];

    if (request.userLevel <= 0) {
      errors.add('Il livello utente deve essere maggiore di zero.');
    }
    if (request.targetDurationMinutes <= 0) {
      errors.add('La durata target deve essere maggiore di zero minuti.');
    }
    // CUSTOM rappresenta una composizione manuale dell'utente (sezione
    // 32): non è un tipo che il Forge Engine possa generare da solo.
    if (request.workoutType == WorkoutType.custom) {
      errors.add(
        'Il tipo di allenamento CUSTOM non è generabile dal Forge Engine.',
      );
    }

    return ForgeRequestValidationResult(errors: errors);
  }
}
