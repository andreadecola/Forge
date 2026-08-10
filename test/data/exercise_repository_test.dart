import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

void main() {
  late AppDatabase db;
  late DriftExerciseRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    repo = DriftExerciseRepository(db);
  });

  tearDown(() => db.close());

  test(
    'getExercises ritorna i 118 esercizi attivi come entità di dominio',
    () async {
      final exercises = await repo.getExercises();
      expect(exercises, hasLength(118));
      expect(exercises.first.code, isNotEmpty);
    },
  );

  test('getExerciseByCode risolve gli enum (impatto/cardio)', () async {
    final push = await repo.getExerciseByCode('PUSH-001');
    expect(push, isNotNull);
    expect(push!.name, isNotEmpty);

    final cardio = await repo.getExerciseByCode('CARD-002');
    expect(cardio!.cardioIntensity, isNotNull);
  });

  test('getExercisesByCategory', () async {
    final legs = await repo.getExercisesByCategory('GAMBE_GLUTEI');
    expect(legs, hasLength(20));
  });

  test('searchExercises', () async {
    final results = await repo.searchExercises('squat');
    expect(results, isNotEmpty);
  });

  test(
    'getExerciseDetails aggrega categoria, muscoli, attrezzatura, immagini',
    () async {
      final push = await repo.getExerciseByCode('PUSH-001');
      final details = await repo.getExerciseDetails(push!.id);
      expect(details, isNotNull);
      expect(details!.category.code, 'PETTO_SPINTA');
      expect(details.primaryMuscles.map((m) => m.code), contains('PETTORALI'));
      expect(details.equipment.map((e) => e.equipment.code), contains('WALL'));
      expect(details.images, hasLength(2));
    },
  );

  test('getExerciseDetails include progressioni e alternative', () async {
    final leg004 = await repo.getExerciseByCode('LEG-004');
    final details = await repo.getExerciseDetails(leg004!.id);
    expect(details!.progressions, isNotEmpty);
    expect(details.alternatives, isNotEmpty);
  });

  test('progressioni e regressioni', () async {
    final leg003 = await repo.getExerciseByCode('LEG-003');
    final progressions = await repo.getProgressions(leg003!.id);
    final regressions = await repo.getRegressions(leg003.id);
    expect(progressions.map((p) => p.target.code), contains('LEG-004'));
    expect(regressions.map((r) => r.target.code), contains('LEG-001'));
  });

  test(
    'getExercisesByAvailableEquipment: solo NONE quando inventario vuoto',
    () async {
      final available = await repo.getExercisesByAvailableEquipment(const {});
      // Un esercizio a corpo libero (NONE) come LEG-006 è disponibile.
      expect(available.any((e) => e.code == 'LEG-006'), isTrue);
      // Un esercizio che richiede BAND non lo è.
      expect(available.any((e) => e.code == 'BACK-001'), isFalse);
    },
  );

  test(
    'getExercisesByAvailableEquipment: con BAND sblocca gli esercizi con elastico',
    () async {
      final available = await repo.getExercisesByAvailableEquipment({'BAND'});
      expect(available.any((e) => e.code == 'BACK-001'), isTrue);
    },
  );
}
