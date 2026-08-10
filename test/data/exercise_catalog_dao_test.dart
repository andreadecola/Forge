import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

/// Test dei DAO del catalogo su database in-memory seedato dal file reale.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
  });

  tearDown(() => db.close());

  group('CategorieEserciziDao', () {
    test('getAll è ordinato per ordine_visualizzazione', () async {
      final cats = await db.categorieEserciziDao.getAll();
      expect(cats, isNotEmpty);
      final orders = cats.map((c) => c.ordineVisualizzazione).toList();
      final sorted = [...orders]..sort();
      expect(orders, sorted);
    });

    test('getByCode ritorna la categoria giusta', () async {
      final cat = await db.categorieEserciziDao.getByCode('MOBILITA');
      expect(cat, isNotNull);
      expect(cat!.codice, 'MOBILITA');
    });
  });

  group('EserciziDao', () {
    test('getByCode e getById', () async {
      final byCode = await db.eserciziDao.getByCode('PUSH-001');
      expect(byCode, isNotNull);
      final byId = await db.eserciziDao.getById(byCode!.id);
      expect(byId!.codice, 'PUSH-001');
    });

    test(
      'getByCategoryCode ritorna solo esercizi di quella categoria',
      () async {
        final legs = await db.eserciziDao.getByCategoryCode('GAMBE_GLUTEI');
        expect(legs, isNotEmpty);
        expect(legs.every((e) => e.codice.startsWith('LEG-')), isTrue);
      },
    );

    test('getByLevel esclude esercizi con livello minimo superiore', () async {
      final level1 = await db.eserciziDao.getByLevel(1);
      expect(level1.every((e) => e.livelloMinimo <= 1), isTrue);
      // Un esercizio L4 come LEG-008 non deve comparire al livello 1.
      expect(level1.any((e) => e.codice == 'LEG-008'), isFalse);
    });

    test('search trova per codice e per nome', () async {
      final byCode = await db.eserciziDao.search('PUSH-001');
      expect(byCode.any((e) => e.codice == 'PUSH-001'), isTrue);
      final byName = await db.eserciziDao.search('squat');
      expect(byName, isNotEmpty);
    });
  });

  group('GruppiMuscolariDao', () {
    test('muscoli primari e secondari per un esercizio', () async {
      final push = await db.eserciziDao.getByCode('PUSH-001');
      final primary = await db.gruppiMuscolariDao.getPrimaryMusclesForExercise(
        push!.id,
      );
      final secondary = await db.gruppiMuscolariDao
          .getSecondaryMusclesForExercise(push.id);
      expect(primary.map((m) => m.codice), contains('PETTORALI'));
      expect(secondary.map((m) => m.codice), contains('TRICIPITI'));
    });
  });

  group('AttrezzatureDao', () {
    test('required equipment per un esercizio con elastico', () async {
      final band = await db.eserciziDao.getByCode('BACK-001');
      final required = await db.attrezzatureDao.getRequiredEquipmentForExercise(
        band!.id,
      );
      expect(required.map((e) => e.codice), contains('BAND'));
    });
  });

  group('ImmaginiEserciziDao', () {
    test('immagini ordinate per ordine_visualizzazione', () async {
      final push = await db.eserciziDao.getByCode('PUSH-001');
      final images = await db.immaginiEserciziDao.getForExercise(push!.id);
      expect(images, hasLength(2));
      expect(
        images[0].ordineVisualizzazione,
        lessThanOrEqualTo(images[1].ordineVisualizzazione),
      );
    });
  });

  group('ProgressioniEserciziDao', () {
    test('progressione in avanti LEG-001 -> LEG-003', () async {
      final leg001 = await db.eserciziDao.getByCode('LEG-001');
      final leg003 = await db.eserciziDao.getByCode('LEG-003');
      final progs = await db.progressioniEserciziDao.getProgressions(
        leg001!.id,
      );
      expect(progs.any((p) => p.target.id == leg003!.id), isTrue);
    });

    test(
      'regressione inversa: LEG-003 ha LEG-001 tra le regressioni',
      () async {
        final leg001 = await db.eserciziDao.getByCode('LEG-001');
        final leg003 = await db.eserciziDao.getByCode('LEG-003');
        final regs = await db.progressioniEserciziDao.getRegressions(
          leg003!.id,
        );
        expect(regs.any((r) => r.target.id == leg001!.id), isTrue);
      },
    );
  });

  group('AlternativeEserciziDao', () {
    test('alternative ordinate per priorità', () async {
      final leg004 = await db.eserciziDao.getByCode('LEG-004');
      final alts = await db.alternativeEserciziDao.getAlternatives(leg004!.id);
      expect(alts, isNotEmpty);
      final priorities = alts.map((a) => a.alternative.priorita).toList();
      final sorted = [...priorities]..sort();
      expect(priorities, sorted);
    });
  });
}
