import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/workout_providers.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/workout_details.dart';
import '../../../domain/entities/workout_walking_block.dart';
import '../../../domain/entities/workout_enums.dart';
import '../../../domain/entities/workout_exercise.dart';
import '../../../domain/entities/workout_validation_result.dart';

/// Editor applicativo di una scheda (Milestone 4.3): incapsula tutte le
/// mutazioni (metadati, esercizi, transizioni di stato) dietro un'unica API,
/// così le pagine restano prive di logica di business (nessuna chiamata a
/// [WorkoutRepository]/[WorkoutValidationService] diretta da un widget).
///
/// Persistenza sempre immediata: ogni metodo scrive subito sul repository e
/// ricarica lo stato. Non esiste un buffer di modifiche "non salvate" da
/// intercettare al Back — vedi la decisione documentata in
/// 07_Training_Engine.md (sezione "Modifiche e salvataggio").
class WorkoutEditorController
    extends FamilyAsyncNotifier<WorkoutDetails?, int> {
  bool _addingExercise = false;
  @override
  Future<WorkoutDetails?> build(int workoutId) {
    return ref.watch(workoutRepositoryProvider).getWorkoutDetails(workoutId);
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).getWorkoutDetails(arg),
    );
  }

  /// Le schermate lista/dettaglio leggono i dettagli tramite il provider
  /// condiviso, mentre l'editor mantiene il proprio stato AsyncNotifier.
  /// Dopo una mutazione bisogna invalidare esplicitamente quel provider:
  /// altrimenti la UI può conservare un conteggio esercizi precedente (per
  /// esempio `0`) anche se la riga è stata salvata correttamente nel DB.
  void _invalidateSharedDetails() {
    ref.invalidate(workoutDetailsProvider(arg));
  }

  /// Se la scheda è attualmente PRONTA e la modifica appena applicata la
  /// rende non più valida, la riporta automaticamente in BOZZA: una scheda
  /// "pronta" deve restare sempre realmente eseguibile (decisione
  /// architetturale, vedi doc).
  Future<void> _downgradeIfNoLongerReady() async {
    final repository = ref.read(workoutRepositoryProvider);
    final details = await repository.getWorkoutDetails(arg);
    if (details == null ||
        details.workout.status != WorkoutDefinitionStatus.ready) {
      return;
    }

    final result = ref
        .read(workoutValidationServiceProvider)
        .validateReady(details);
    if (!result.isValid) {
      await repository.updateWorkout(
        details.workout.copyWith(status: WorkoutDefinitionStatus.draft),
      );
    }
  }

  Future<void> updateMetadata({
    required String name,
    required String? description,
    required WorkoutType type,
    required int level,
    required Set<int> selectedLevels,
    required int? estimatedDurationMinutes,
    WorkoutWalkingBlock? Function()? walkingBlock,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref
        .read(workoutRepositoryProvider)
        .updateWorkout(
          current.workout.copyWith(
            name: name,
            description: () => description,
            type: type,
            level: level,
            selectedLevels: selectedLevels,
            walkingBlock: walkingBlock,
            estimatedDurationMinutes: () => estimatedDurationMinutes,
          ),
        );
    _invalidateSharedDetails();
    await _downgradeIfNoLongerReady();
    await _reload();
  }

  /// Aggiunge un esercizio del catalogo alla scheda. I valori
  /// serie/ripetizioni/durata/recupero/note sono quelli scelti dall'utente
  /// nella schermata di configurazione — che li pre-compila con i default
  /// del catalogo tramite [WorkoutExerciseFactory.fromExercise] prima di
  /// arrivare qui (Milestone 4.3, sezione 14): il controller non inventa
  /// altri valori.
  Future<bool> addExerciseFromCatalog({
    required Exercise exercise,
    int? sets,
    int? repetitions,
    int? durationSeconds,
    int? restSeconds,
    String? notes,
  }) async {
    if (_addingExercise) return false;
    _addingExercise = true;
    try {
      final details = await ref
          .read(workoutRepositoryProvider)
          .getWorkoutDetails(arg);
      if (details == null) throw StateError('Scheda non disponibile');
      if (details.exercises.any(
        (entry) => entry.workoutExercise.exerciseId == exercise.id,
      )) {
        await _reload();
        return false;
      }
      final order = details.exercises.length + 1;
      final workoutExercise = WorkoutExercise(
        workoutId: arg,
        exerciseId: exercise.id,
        order: order,
        sets: sets,
        repetitions: repetitions,
        durationSeconds: durationSeconds,
        restSeconds: restSeconds,
        notes: notes,
      );
      await ref
          .read(workoutRepositoryProvider)
          .addExercise(workoutId: arg, exercise: workoutExercise);
      _invalidateSharedDetails();
      await _reload();
      return true;
    } finally {
      _addingExercise = false;
    }
  }

  Future<void> updateExercise(WorkoutExercise exercise) async {
    await ref.read(workoutRepositoryProvider).updateExercise(exercise);
    _invalidateSharedDetails();
    await _downgradeIfNoLongerReady();
    await _reload();
  }

  Future<void> removeExercise(int workoutExerciseId) async {
    await ref.read(workoutRepositoryProvider).removeExercise(workoutExerciseId);
    _invalidateSharedDetails();
    await _downgradeIfNoLongerReady();
    await _reload();
  }

  Future<void> reorderExercises(List<int> orderedWorkoutExerciseIds) async {
    await ref
        .read(workoutRepositoryProvider)
        .reorderExercises(
          workoutId: arg,
          orderedWorkoutExerciseIds: orderedWorkoutExerciseIds,
        );
    _invalidateSharedDetails();
    await _reload();
  }

  /// Riporta esplicitamente la scheda a BOZZA (es. l'utente vuole tornare a
  /// modificarla liberamente anche se era PRONTA).
  Future<void> saveAsDraft() async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref
        .read(workoutRepositoryProvider)
        .updateWorkout(
          current.workout.copyWith(status: WorkoutDefinitionStatus.draft),
        );
    _invalidateSharedDetails();
    await _reload();
  }

  /// Valida la scheda e, se eseguibile, la porta a PRONTA. Se non lo è, NON
  /// modifica lo stato e ritorna gli errori (già frasi italiane pronte per
  /// la UI) perché il chiamante li mostri.
  Future<WorkoutValidationResult> markReady() async {
    final current = state.valueOrNull;
    if (current == null) {
      return const WorkoutValidationResult(
        errors: ['La scheda non è disponibile.'],
      );
    }
    final result = ref
        .read(workoutValidationServiceProvider)
        .validateReady(current);
    if (!result.isValid) return result;

    await ref
        .read(workoutRepositoryProvider)
        .updateWorkout(
          current.workout.copyWith(status: WorkoutDefinitionStatus.ready),
        );
    _invalidateSharedDetails();
    await _reload();
    return result;
  }

  Future<void> archive() async {
    await ref.read(workoutRepositoryProvider).archiveWorkout(arg);
    _invalidateSharedDetails();
    await _reload();
  }
}

final workoutEditorControllerProvider =
    AsyncNotifierProvider.family<WorkoutEditorController, WorkoutDetails?, int>(
      WorkoutEditorController.new,
    );
