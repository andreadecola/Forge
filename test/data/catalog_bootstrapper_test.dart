import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/seed/catalog_bootstrapper.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<String> diskLoader(String key) async =>
      File('assets/data/exercises_v1.json').readAsString();

  test('database vuoto -> bootstrap importa il catalogo', () async {
    final result = await CatalogBootstrapper(db).run(diskLoader);
    expect(result.alreadyImported, isFalse);
    expect(result.exercises, 118);

    final exercises = await db.eserciziDao.getAll();
    expect(exercises, hasLength(118));
  });

  test('secondo bootstrap -> nessun duplicato', () async {
    await CatalogBootstrapper(db).run(diskLoader);
    final second = await CatalogBootstrapper(db).run(diskLoader);
    expect(second.alreadyImported, isTrue);

    final exercises = await db.eserciziDao.getAll();
    expect(exercises, hasLength(118));
  });

  test('errore seed -> eccezione propagata, non ingoiata', () async {
    Future<String> badLoader(String key) async => '{ not valid json';
    expect(
      () => CatalogBootstrapper(db).run(badLoader),
      throwsA(isA<CatalogSeedException>()),
    );
    final exercises = await db.eserciziDao.getAll();
    expect(exercises, isEmpty);
  });
}
