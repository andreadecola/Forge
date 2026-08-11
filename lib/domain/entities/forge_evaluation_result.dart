import 'forge_exercise_evaluation.dart';
import 'forge_request.dart';

/// Esito completo di una valutazione del Forge Engine (Milestone 5.1,
/// sezione 47): **non** un `Workout` — la generazione vera arriva con la
/// Milestone 5.2. Contiene sia gli eleggibili (già ordinati per punteggio,
/// sezione 48) sia gli esclusi con i loro motivi (sezione 49: mai
/// scartati, servono a spiegabilità/debug/test).
class ForgeEvaluationResult {
  const ForgeEvaluationResult({
    required this.normalizedRequest,
    required this.eligible,
    required this.excluded,
    this.warnings = const [],
  });

  final ForgeRequest normalizedRequest;

  /// Ordinati per punteggio decrescente, con tie-break stabile (sezione
  /// 43) — mai in ordine di scoperta/catalogo.
  final List<ForgeExerciseEvaluation> eligible;

  final List<ForgeExerciseEvaluation> excluded;

  /// Es. la richiesta non era valida (sezione 11): il motore non lancia
  /// un'eccezione, riporta comunque un risultato (vuoto) con la
  /// spiegazione qui.
  final List<String> warnings;
}
