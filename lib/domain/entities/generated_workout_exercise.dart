import 'exercise.dart';
import 'forge_composition_reason.dart';
import 'forge_score.dart';
import 'workout_exercise.dart';

/// Riga di un piano generato (Milestone 5.2, sezione 5). Compatibile per
/// costruzione con un futuro `WorkoutExercise` persistito (sezione 75):
/// [workoutExercise] **è** già un `WorkoutExercise` — solo non persistito
/// (`id` nullo, `workoutId` un placeholder, vedi
/// [GeneratedWorkoutExercise.placeholderWorkoutId]). Una futura milestone
/// di salvataggio dovrà solo copiarlo con il vero `workoutId`, non
/// ricostruirlo da zero.
///
/// I parametri (`sets`/`repetitions`/`durationSeconds`/`restSeconds`)
/// derivano dai default del catalogo tramite
/// `ForgeExerciseParameterPolicy` (che riusa `WorkoutExerciseFactory`,
/// Milestone 4.2) — mai un valore inventato qui: se il catalogo non ha un
/// default, il campo resta `null`, esattamente come accadrebbe scegliendo
/// lo stesso esercizio a mano in `WorkoutEditorController`.
class GeneratedWorkoutExercise {
  const GeneratedWorkoutExercise({
    required this.workoutExercise,
    required this.exercise,
    required this.estimatedDurationSeconds,
    required this.score,
    required this.decisionReasons,
  });

  /// `workoutId` placeholder usato per ogni `WorkoutExercise` non ancora
  /// persistito prodotto da questa milestone: nessun `Workout` reale
  /// esiste ancora a cui appartenere.
  static const int placeholderWorkoutId = 0;

  final WorkoutExercise workoutExercise;
  final Exercise exercise;

  /// Stima isolata dell'esercizio (`ExerciseDurationEstimator`, Milestone
  /// 5.1) — **non** include le transizioni tra esercizi, quelle si
  /// contano solo a livello di `GeneratedWorkoutPlan`.
  final int estimatedDurationSeconds;

  /// Punteggio "isolato" della Milestone 5.1, riportato invariato — non
  /// esiste un secondo punteggio più aggiornato per il candidato: il
  /// punteggio *contestuale* usato per selezionarlo
  /// (`ForgeSelectionScore`) non sostituisce mai questo (sezione 29).
  final ForgeScore score;

  final List<ForgeCompositionReason> decisionReasons;
}
