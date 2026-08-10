import '../entities/workout.dart';
import '../entities/workout_details.dart';
import '../entities/workout_enums.dart';
import '../entities/workout_exercise.dart';
import '../entities/workout_validation_result.dart';

/// Valida una scheda allenamento distinguendo lo stato dichiarato:
/// - DRAFT può essere incompleta (nessun esercizio, valori assenti), ma deve
///   rispettare gli stessi vincoli base già imposti dal DB (livello > 0,
///   ordine > 0, ecc. — qui ridondanti col CHECK SQLite, ma verificati
///   anche lato domain per poter mostrare l'errore prima di un tentativo di
///   scrittura).
/// - READY deve essere realmente eseguibile: almeno un esercizio attivo,
///   ogni esercizio valido e con ripetizioni o durata.
class WorkoutValidationService {
  const WorkoutValidationService();

  WorkoutValidationResult validateWorkout(Workout workout) {
    final errors = <String>[];
    if (workout.name.trim().isEmpty) {
      errors.add('Il nome della scheda non può essere vuoto.');
    }
    if (workout.level <= 0) {
      errors.add('Il livello deve essere maggiore di zero.');
    }
    final duration = workout.estimatedDurationMinutes;
    if (duration != null && duration <= 0) {
      errors.add(
        'La durata stimata deve essere maggiore di zero, se indicata.',
      );
    }
    if (workout.profileId <= 0) {
      errors.add('Il profilo associato alla scheda non è valido.');
    }
    return WorkoutValidationResult(errors: errors);
  }

  WorkoutValidationResult validateWorkoutExercise(WorkoutExercise exercise) {
    final errors = <String>[];
    if (exercise.order <= 0) {
      errors.add('L\'ordine dell\'esercizio deve essere maggiore di zero.');
    }
    final sets = exercise.sets;
    if (sets != null && sets <= 0) {
      errors.add('Le serie devono essere maggiori di zero, se indicate.');
    }
    final repetitions = exercise.repetitions;
    if (repetitions != null && repetitions <= 0) {
      errors.add('Le ripetizioni devono essere maggiori di zero, se indicate.');
    }
    final duration = exercise.durationSeconds;
    if (duration != null && duration <= 0) {
      errors.add('La durata deve essere maggiore di zero, se indicata.');
    }
    final rest = exercise.restSeconds;
    if (rest != null && rest < 0) {
      errors.add('Il recupero non può essere negativo.');
    }
    return WorkoutValidationResult(errors: errors);
  }

  /// Una bozza può non avere esercizi e può contenere voci incomplete
  /// (ripetizioni/durata assenti): vengono comunque segnalati i vincoli
  /// base violati (es. ordine <= 0), ma non la mancanza di ripetizioni o
  /// durata.
  WorkoutValidationResult validateDraft(WorkoutDetails details) {
    final errors = <String>[...validateWorkout(details.workout).errors];
    for (final entry in details.exercises) {
      errors.addAll(validateWorkoutExercise(entry.workoutExercise).errors);
    }
    return WorkoutValidationResult(errors: errors);
  }

  WorkoutValidationResult validateReady(WorkoutDetails details) {
    final errors = <String>[...validateWorkout(details.workout).errors];
    final activeExercises = details.exercises
        .where((e) => e.workoutExercise.isActive)
        .toList();

    if (activeExercises.isEmpty) {
      errors.add('Una scheda pronta deve avere almeno un esercizio.');
    }

    for (final entry in activeExercises) {
      final workoutExercise = entry.workoutExercise;
      errors.addAll(validateWorkoutExercise(workoutExercise).errors);
      if (workoutExercise.repetitions == null &&
          workoutExercise.durationSeconds == null) {
        errors.add(
          'L\'esercizio "${entry.exercise.name}" deve avere ripetizioni o '
          'durata.',
        );
      }
    }

    return WorkoutValidationResult(errors: errors);
  }

  /// Applica [validateReady] o [validateDraft] in base a
  /// `details.workout.status` (le schede archiviate seguono le stesse
  /// regole di una bozza: non devono più essere "eseguibili" per essere
  /// valide).
  WorkoutValidationResult validate(WorkoutDetails details) {
    switch (details.workout.status) {
      case WorkoutDefinitionStatus.ready:
        return validateReady(details);
      case WorkoutDefinitionStatus.draft:
      case WorkoutDefinitionStatus.archived:
        return validateDraft(details);
    }
  }
}
