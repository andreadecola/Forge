import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_alternative.dart';
import '../../domain/entities/exercise_catalog_enums.dart';
import '../../domain/entities/exercise_category.dart';
import '../../domain/entities/exercise_details.dart';
import '../../domain/entities/exercise_image.dart';
import '../../domain/entities/exercise_progression.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../database/app_database.dart';
import 'catalog_mappers.dart';

class DriftExerciseRepository implements ExerciseRepository {
  DriftExerciseRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<Exercise>> getExercises() async {
    final rows = await db.eserciziDao.getActiveExercises();
    return rows.map(CatalogMappers.exercise).toList();
  }

  @override
  Future<List<ExerciseCategory>> getCategories() async {
    final rows = await db.categorieEserciziDao.getAll();
    return rows.map(CatalogMappers.category).toList();
  }

  @override
  Future<Map<int, Set<String>>> getRequiredEquipmentCodesByExercise() async {
    final links = await db.attrezzatureDao.getAllExerciseEquipmentLinks();
    final requiredByExercise = <int, Set<String>>{};
    for (final link in links) {
      if (!link.required) continue;
      requiredByExercise
          .putIfAbsent(link.exerciseId, () => <String>{})
          .add(link.masterCode);
    }
    return requiredByExercise;
  }

  @override
  Stream<List<Exercise>> watchExercises() {
    return db.eserciziDao.watchAll().map(
      (rows) => rows.map(CatalogMappers.exercise).toList(),
    );
  }

  @override
  Future<Exercise?> getExerciseById(int id) async {
    final row = await db.eserciziDao.getById(id);
    return row == null ? null : CatalogMappers.exercise(row);
  }

  @override
  Future<Exercise?> getExerciseByCode(String code) async {
    final row = await db.eserciziDao.getByCode(code);
    return row == null ? null : CatalogMappers.exercise(row);
  }

  @override
  Future<List<Exercise>> getExercisesByCategory(String categoryCode) async {
    final rows = await db.eserciziDao.getByCategoryCode(categoryCode);
    return rows.map(CatalogMappers.exercise).toList();
  }

  @override
  Future<List<Exercise>> getExercisesByLevel(int userLevel) async {
    final rows = await db.eserciziDao.getByLevel(userLevel);
    return rows.map(CatalogMappers.exercise).toList();
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) return getExercises();
    final rows = await db.eserciziDao.search(query);
    return rows.map(CatalogMappers.exercise).toList();
  }

  @override
  Future<List<Exercise>> getExercisesByAvailableEquipment(
    Set<String> ownedEquipmentCodes,
  ) async {
    final requiredByExercise = await getRequiredEquipmentCodesByExercise();
    final exercises = await getExercises();
    return exercises.where((e) {
      // NONE non è un requisito di inventario: si esclude dal confronto.
      final required = (requiredByExercise[e.id] ?? const <String>{}).where(
        (code) => code != Equipment.noneCode,
      );
      return required.every(ownedEquipmentCodes.contains);
    }).toList();
  }

  @override
  Future<ExerciseDetails?> getExerciseDetails(int exerciseId) async {
    final row = await db.eserciziDao.getById(exerciseId);
    if (row == null) return null;
    final exercise = CatalogMappers.exercise(row);

    final categoryRow = await db.categorieEserciziDao.getById(
      exercise.categoryId,
    );

    final primary = await db.gruppiMuscolariDao.getPrimaryMusclesForExercise(
      exerciseId,
    );
    final secondary = await db.gruppiMuscolariDao
        .getSecondaryMusclesForExercise(exerciseId);
    final equipment = await db.attrezzatureDao.getEquipmentForExercise(
      exerciseId,
    );
    final images = await db.immaginiEserciziDao.getForExercise(exerciseId);
    final progressions = await getProgressions(exerciseId);
    final regressions = await getRegressions(exerciseId);
    final alternatives = await getAlternatives(exerciseId);

    return ExerciseDetails(
      exercise: exercise,
      category: CatalogMappers.category(categoryRow!),
      primaryMuscles: primary.map(CatalogMappers.muscle).toList(),
      secondaryMuscles: secondary.map(CatalogMappers.muscle).toList(),
      equipment: equipment
          .map(
            (e) => ExerciseEquipmentRequirement(
              equipment: CatalogMappers.equipment(e.equipment),
              required: e.required,
            ),
          )
          .toList(),
      images: images.map(CatalogMappers.image).toList(),
      progressions: progressions,
      regressions: regressions,
      alternatives: alternatives,
    );
  }

  @override
  Future<List<ExerciseImage>> getImages(int exerciseId) async {
    final rows = await db.immaginiEserciziDao.getForExercise(exerciseId);
    return rows.map(CatalogMappers.image).toList();
  }

  @override
  Future<List<ExerciseProgression>> getProgressions(int exerciseId) async {
    final rows = await db.progressioniEserciziDao.getProgressions(exerciseId);
    return rows
        .map(
          (r) => ExerciseProgression(
            id: r.progression.id,
            type: ExerciseProgressionType.fromCode(
              r.progression.tipoProgressione,
            ),
            minimumLevel: r.progression.livelloMinimo,
            priority: r.progression.priorita,
            notes: r.progression.note,
            target: CatalogMappers.exercise(r.target),
          ),
        )
        .toList();
  }

  @override
  Future<List<ExerciseProgression>> getRegressions(int exerciseId) async {
    final rows = await db.progressioniEserciziDao.getRegressions(exerciseId);
    return rows
        .map(
          (r) => ExerciseProgression(
            id: r.progression.id,
            type: ExerciseProgressionType.fromCode(
              r.progression.tipoProgressione,
            ),
            minimumLevel: r.progression.livelloMinimo,
            priority: r.progression.priorita,
            notes: r.progression.note,
            target: CatalogMappers.exercise(r.target),
          ),
        )
        .toList();
  }

  @override
  Future<List<ExerciseAlternative>> getAlternatives(int exerciseId) async {
    final rows = await db.alternativeEserciziDao.getAlternatives(exerciseId);
    return rows
        .map(
          (r) => ExerciseAlternative(
            id: r.alternative.id,
            reason: ExerciseAlternativeReason.fromCode(
              r.alternative.codiceMotivo,
            ),
            priority: r.alternative.priorita,
            notes: r.alternative.note,
            target: CatalogMappers.exercise(r.target),
          ),
        )
        .toList();
  }
}
