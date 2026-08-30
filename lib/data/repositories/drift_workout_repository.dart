import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_details.dart';
import '../../domain/entities/workout_enums.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_exercise_details.dart';
import '../../domain/repositories/workout_repository.dart';
import '../database/app_database.dart';
import 'catalog_mappers.dart';
import 'workout_mappers.dart';

class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this.db);

  final AppDatabase db;

  /// Base per gli ordini temporanei usati da [reorderExercises] (vedi
  /// commento lì): ben oltre qualunque numero plausibile di esercizi in una
  /// scheda, per garantire nessuna collisione con i valori 1..N esistenti.
  static const int _reorderTemporaryOffset = 1000000;

  @override
  Future<List<Workout>> getWorkouts({required int profileId}) async {
    final rows = await db.allenamentiDao.getAllByProfile(profileId);
    return rows.map(WorkoutMappers.workout).toList();
  }

  @override
  Stream<List<Workout>> watchWorkouts({required int profileId}) {
    return db.allenamentiDao
        .watchAllByProfile(profileId)
        .map((rows) => rows.map(WorkoutMappers.workout).toList());
  }

  @override
  Future<List<Workout>> getAllWorkouts({required int profileId}) async {
    final rows = await db.allenamentiDao.getAllIncludingArchivedByProfile(
      profileId,
    );
    return rows.map(WorkoutMappers.workout).toList();
  }

  @override
  Stream<List<Workout>> watchArchivedWorkouts({required int profileId}) {
    return db.allenamentiDao
        .watchArchivedByProfile(profileId)
        .map((rows) => rows.map(WorkoutMappers.workout).toList());
  }

  @override
  Future<Workout?> getWorkoutById(int id) async {
    final row = await db.allenamentiDao.getById(id);
    return row == null ? null : WorkoutMappers.workout(row);
  }

  @override
  Future<WorkoutDetails?> getWorkoutDetails(int id) async {
    final row = await db.allenamentiDao.getById(id);
    if (row == null) return null;

    final rows = await db.allenamentiEserciziDao.getByWorkoutIdWithExercise(id);
    final exercises = rows
        .map(
          (r) => WorkoutExerciseDetails(
            workoutExercise: WorkoutMappers.workoutExercise(r.workoutExercise),
            exercise: CatalogMappers.exercise(r.exercise),
          ),
        )
        .toList();

    return WorkoutDetails(
      workout: WorkoutMappers.workout(row),
      exercises: exercises,
    );
  }

  @override
  Future<int> createWorkout(Workout workout) {
    return db.allenamentiDao.create(WorkoutMappers.workoutToCompanion(workout));
  }

  @override
  Future<int> createWorkoutWithExercises({
    required Workout workout,
    required List<WorkoutExercise> exercises,
  }) {
    return db.transaction(() async {
      final workoutId = await db.allenamentiDao.create(
        WorkoutMappers.workoutToCompanion(workout),
      );
      for (final exercise in exercises) {
        await db.allenamentiEserciziDao.insert(
          WorkoutMappers.workoutExerciseToCompanion(
            exercise.copyWith(workoutId: workoutId),
          ),
        );
      }
      return workoutId;
    });
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    assert(
      workout.id != null,
      'updateWorkout richiede un Workout già persistito (id non nullo).',
    );
    await db.allenamentiDao.updateWorkout(
      WorkoutMappers.workoutToCompanion(workout),
    );
  }

  @override
  Future<void> archiveWorkout(int id) async {
    await db.allenamentiDao.setStatus(
      id,
      stato: WorkoutDefinitionStatus.archived.code,
      attivo: false,
      dataModifica: DateTime.now(),
    );
  }

  @override
  Future<void> deleteWorkout(int id) async {
    // Le righe allenamenti_esercizi vengono eliminate in CASCADE dal DB
    // (foreign_keys = ON dalla Milestone 4.1); il catalogo esercizi non è
    // coinvolto in nessun modo da questa cancellazione.
    await db.allenamentiDao.deleteById(id);
  }

  @override
  Future<int> addExercise({
    required int workoutId,
    required WorkoutExercise exercise,
  }) async {
    final order = exercise.order > 0
        ? exercise.order
        : await db.allenamentiEserciziDao.getNextOrder(workoutId);
    final toInsert = exercise.copyWith(workoutId: workoutId, order: order);
    return db.allenamentiEserciziDao.insert(
      WorkoutMappers.workoutExerciseToCompanion(toInsert),
    );
  }

  @override
  Future<void> updateExercise(WorkoutExercise exercise) async {
    assert(
      exercise.id != null,
      'updateExercise richiede una WorkoutExercise già persistita (id non '
      'nullo).',
    );
    await db.allenamentiEserciziDao.updateWorkoutExercise(
      WorkoutMappers.workoutExerciseToCompanion(exercise),
    );
  }

  @override
  Future<void> removeExercise(int workoutExerciseId) {
    return db.transaction(() async {
      final row = await db.allenamentiEserciziDao.getById(workoutExerciseId);
      if (row == null) return;

      await db.allenamentiEserciziDao.deleteById(workoutExerciseId);

      // Richiude eventuali "buchi" lasciati dalla rimozione: le righe
      // rimanenti sono già ordinate per `ordine` ASC dal DAO, quindi
      // assegnare 1..N in quell'ordine non collide mai con un valore non
      // ancora aggiornato (ogni riga successiva ha già un `ordine`
      // originale strettamente maggiore del nuovo target — a differenza di
      // [reorderExercises], qui non serve la fase intermedia negativa).
      final remaining = await db.allenamentiEserciziDao.getByWorkoutId(
        row.idAllenamento,
      );
      final now = DateTime.now();
      for (var i = 0; i < remaining.length; i++) {
        final target = i + 1;
        if (remaining[i].ordine != target) {
          await db.allenamentiEserciziDao.updateOrder(
            id: remaining[i].id,
            ordine: target,
            dataModifica: now,
          );
        }
      }
    });
  }

  @override
  Future<void> reorderExercises({
    required int workoutId,
    required List<int> orderedWorkoutExerciseIds,
  }) {
    return db.transaction(() async {
      final current = await db.allenamentiEserciziDao.getByWorkoutId(workoutId);
      final currentIds = current.map((r) => r.id).toSet();
      final requestedIds = orderedWorkoutExerciseIds;
      final requestedIdSet = requestedIds.toSet();

      if (requestedIds.length != currentIds.length ||
          requestedIdSet.length != requestedIds.length ||
          !requestedIdSet.every(currentIds.contains)) {
        throw const WorkoutReorderException(
          'La lista di riordino deve contenere, senza duplicati, esattamente '
          'gli ID delle righe attuali della scheda.',
        );
      }

      final now = DateTime.now();

      // Fase 1: sposta tutte le righe coinvolte su ordini temporanei alti
      // (univoci tra loro e mai in collisione con un valore 1..N esistente),
      // per evitare la violazione del vincolo UNIQUE(idAllenamento, ordine)
      // che si otterrebbe assegnando subito i valori definitivi (es. uno
      // scambio 1<->3 collide se applicato in un solo passaggio). Non si
      // possono usare valori negativi come offset temporaneo: la tabella ha
      // anche un CHECK (ordine > 0).
      for (var i = 0; i < requestedIds.length; i++) {
        await db.allenamentiEserciziDao.updateOrder(
          id: requestedIds[i],
          ordine: _reorderTemporaryOffset + i,
          dataModifica: now,
        );
      }

      // Fase 2: assegna gli ordini definitivi (1-based) nella sequenza
      // voluta dal chiamante.
      for (var i = 0; i < requestedIds.length; i++) {
        await db.allenamentiEserciziDao.updateOrder(
          id: requestedIds[i],
          ordine: i + 1,
          dataModifica: now,
        );
      }
    });
  }
}
