import '../entities/exercise_details.dart';
import '../entities/forge_evaluation_result.dart';
import '../entities/forge_request.dart';
import '../repositories/exercise_repository.dart';
import '../services/forge_engine.dart';

/// Use case applicativo (Milestone 5.1, sezione 51): recupera il catalogo
/// necessario tramite [ExerciseRepository] e lo passa al [ForgeEngine]
/// domain, che resta ignaro di come i dati sono stati caricati. **Non
/// salva alcun workout** — solo valutazione.
///
/// Nota di performance (limite noto, non un requisito di questa
/// milestone): richiede il dettaglio completo di ogni esercizio del
/// catalogo attivo, una chiamata per esercizio (nessun metodo bulk
/// "tutti i dettagli" esiste ancora in [ExerciseRepository] — introdurlo
/// sarebbe una modifica al repository fuori dallo scopo di questa
/// milestone, puramente domain). Accettabile per l'attuale dimensione del
/// catalogo (118 esercizi); da rivalutare se il catalogo crescesse molto.
class EvaluateForgeRequest {
  EvaluateForgeRequest(this._repository, this._engine);

  final ExerciseRepository _repository;
  final ForgeEngine _engine;

  Future<ForgeEvaluationResult> call(ForgeRequest request) async {
    final exercises = await _repository.getExercises();
    final detailsList = await Future.wait(
      exercises.map((exercise) => _repository.getExerciseDetails(exercise.id)),
    );
    final validDetails = detailsList.whereType<ExerciseDetails>().toList();
    return _engine.evaluateExercises(request, validDetails);
  }
}
