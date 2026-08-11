import 'forge_adaptation_decision.dart';
import 'forge_exercise_adaptation_decision.dart';
import 'generated_workout_plan.dart';

/// Piano generato dopo l'adattamento da storico (Milestone 5.4, sezione
/// 33): **non** un secondo modello del piano — racchiude il
/// [GeneratedWorkoutPlan] finale (Milestone 5.2, già con le sostituzioni/
/// aumenti di parametro applicati e già rivalidato) più i metadati che
/// spiegano *cosa* è cambiato e perché, senza duplicare i campi del piano
/// stesso.
class AdaptedGeneratedWorkoutPlan {
  const AdaptedGeneratedWorkoutPlan({
    required this.plan,
    required this.decision,
    required this.exerciseDecisions,
  });

  /// Il piano finale (identico al piano base se [decision] è `maintain` —
  /// sezione 46: "Piano equivalente alla generazione M5.2").
  final GeneratedWorkoutPlan plan;

  final ForgeAdaptationDecision decision;

  /// Una voce per ogni esercizio di [plan], nello stesso ordine (sezione
  /// 34: il piano deve poter spiegare ogni cambiamento — nessuno,
  /// parametro aumentato, esercizio progredito/regredito, alternativa
  /// scelta — con soli enum/motivi domain, mai una stringa UI).
  final List<ForgeExerciseAdaptationDecision> exerciseDecisions;
}
