import '../entities/workout.dart';
import '../entities/workout_details.dart';
import '../entities/workout_exercise.dart';

/// Segnala un [WorkoutRepository.reorderExercises] con input non valido
/// (lista incompleta, ID duplicati o estranei alla scheda): nessuna
/// modifica viene applicata quando questa eccezione viene lanciata.
class WorkoutReorderException implements Exception {
  const WorkoutReorderException(this.message);

  final String message;

  @override
  String toString() => 'WorkoutReorderException: $message';
}

abstract class WorkoutRepository {
  Future<List<Workout>> getWorkouts({required int profileId});

  Stream<List<Workout>> watchWorkouts({required int profileId});

  Future<Workout?> getWorkoutById(int id);

  Future<WorkoutDetails?> getWorkoutDetails(int id);

  Future<int> createWorkout(Workout workout);

  Future<void> updateWorkout(Workout workout);

  /// Archivia la scheda (`status = ARCHIVED`, `isActive = false`): non
  /// elimina il record. Per l'eliminazione reale vedi [deleteWorkout].
  Future<void> archiveWorkout(int id);

  /// Hard delete: elimina la scheda e le sue righe scheda (CASCADE a
  /// livello DB). Non elimina mai l'esercizio master dal catalogo.
  Future<void> deleteWorkout(int id);

  /// Aggiunge un esercizio alla scheda. Se [exercise] ha `order <= 0`
  /// (valore "non specificato"), l'ordine viene assegnato automaticamente
  /// in coda alla scheda.
  Future<int> addExercise({
    required int workoutId,
    required WorkoutExercise exercise,
  });

  Future<void> updateExercise(WorkoutExercise exercise);

  /// Rimuove una riga scheda e normalizza gli ordini delle righe rimanenti
  /// (nessun "buco" nella sequenza).
  Future<void> removeExercise(int workoutExerciseId);

  /// Riordina atomicamente le righe scheda secondo [orderedWorkoutExerciseIds]
  /// (l'elemento in posizione N riceve `order = N + 1`). Lancia
  /// [WorkoutReorderException] — senza applicare alcuna modifica — se la
  /// lista non corrisponde esattamente alle righe attuali della scheda
  /// (conteggio diverso, ID duplicati, o ID di un'altra scheda).
  Future<void> reorderExercises({
    required int workoutId,
    required List<int> orderedWorkoutExerciseIds,
  });
}
