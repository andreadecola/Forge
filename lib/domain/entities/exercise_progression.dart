import 'exercise.dart';
import 'exercise_catalog_enums.dart';

/// Relazione di progressione/regressione tra esercizi. La stessa entità
/// rappresenta entrambe le direzioni: nella progressione [target] è
/// l'esercizio successivo, nella regressione è quello precedente (ottenuto
/// interrogando al contrario `progressioni_esercizi`).
class ExerciseProgression {
  const ExerciseProgression({
    required this.id,
    required this.type,
    required this.minimumLevel,
    required this.priority,
    this.notes,
    required this.target,
  });

  final int id;
  final ExerciseProgressionType type;
  final int minimumLevel;
  final int priority;
  final String? notes;

  /// Esercizio di destinazione della relazione.
  final Exercise target;
}
