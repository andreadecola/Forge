import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';

import 'workout_test_helpers.dart';

void main() {
  late AppDatabase database;
  late int profileId;
  late int categoryId;
  late int exerciseId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    profileId = await insertProfilo(database);
    categoryId = await insertCategoria(database);
    exerciseId = await insertEsercizio(
      database,
      codice: 'LEG-001',
      idCategoria: categoryId,
    );
  });

  tearDown(() => database.close());

  Future<int> createWorkout(AppDatabase db, {String nome = 'Scheda A'}) {
    final now = DateTime.now();
    return db.allenamentiDao.create(
      AllenamentiTableCompanion.insert(
        idProfilo: profileId,
        nome: nome,
        tipoAllenamento: 'FULL_BODY',
        stato: 'DRAFT',
        origine: 'USER',
        dataCreazione: now,
        dataModifica: now,
      ),
    );
  }

  group('AllenamentiDao', () {
    test('create + getById', () async {
      final id = await createWorkout(database);
      final row = await database.allenamentiDao.getById(id);
      expect(row, isNotNull);
      expect(row!.nome, 'Scheda A');
      expect(row.stato, 'DRAFT');
    });

    test(
      'getAllByProfile elenca solo le schede del profilo indicato',
      () async {
        final otherProfileId = await insertProfilo(database);
        await createWorkout(database, nome: 'Scheda A');
        await createWorkout(database, nome: 'Scheda B');
        final now = DateTime.now();
        await database.allenamentiDao.create(
          AllenamentiTableCompanion.insert(
            idProfilo: otherProfileId,
            nome: 'Scheda di un altro profilo',
            tipoAllenamento: 'FULL_BODY',
            stato: 'DRAFT',
            origine: 'USER',
            dataCreazione: now,
            dataModifica: now,
          ),
        );

        final rows = await database.allenamentiDao.getAllByProfile(profileId);
        expect(rows, hasLength(2));
        expect(rows.map((r) => r.nome), containsAll(['Scheda A', 'Scheda B']));
      },
    );

    test('watchAllByProfile riflette lo stato corrente del profilo', () async {
      await createWorkout(database);
      final rows = await database.allenamentiDao
          .watchAllByProfile(profileId)
          .first;
      expect(rows, hasLength(1));
    });

    test('updateWorkout aggiorna la riga esistente', () async {
      final id = await createWorkout(database);
      final row = await database.allenamentiDao.getById(id);
      await database.allenamentiDao.updateWorkout(
        row!.copyWith(nome: 'Scheda rinominata').toCompanion(false),
      );

      final updated = await database.allenamentiDao.getById(id);
      expect(updated!.nome, 'Scheda rinominata');
    });

    test('setStatus aggiorna stato e attivo senza toccare il resto', () async {
      final id = await createWorkout(database);
      await database.allenamentiDao.setStatus(
        id,
        stato: 'ARCHIVED',
        attivo: false,
        dataModifica: DateTime.now(),
      );

      final row = await database.allenamentiDao.getById(id);
      expect(row!.stato, 'ARCHIVED');
      expect(row.attivo, isFalse);
      expect(row.nome, 'Scheda A');
    });

    test('deleteById elimina la scheda', () async {
      final id = await createWorkout(database);
      await database.allenamentiDao.deleteById(id);
      expect(await database.allenamentiDao.getById(id), isNull);
    });
  });

  group('AllenamentiEserciziDao', () {
    Future<int> createWorkoutRow() => createWorkout(database);

    test('insert + getById', () async {
      final workoutId = await createWorkoutRow();
      final now = DateTime.now();
      final id = await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 1,
          dataCreazione: now,
          dataModifica: now,
        ),
      );

      final row = await database.allenamentiEserciziDao.getById(id);
      expect(row, isNotNull);
      expect(row!.idAllenamento, workoutId);
      expect(row.idEsercizio, exerciseId);
      expect(row.ordine, 1);
    });

    test('getByWorkoutId ordina sempre per ordine ASC', () async {
      final workoutId = await createWorkoutRow();
      final now = DateTime.now();
      // Inserite fuori ordine di proposito.
      await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 3,
          dataCreazione: now,
          dataModifica: now,
        ),
      );
      final id1 = await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 1,
          dataCreazione: now,
          dataModifica: now,
        ),
      );
      await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 2,
          dataCreazione: now,
          dataModifica: now,
        ),
      );

      final rows = await database.allenamentiEserciziDao.getByWorkoutId(
        workoutId,
      );
      expect(rows.map((r) => r.ordine), [1, 2, 3]);
      expect(rows.first.id, id1);
    });

    test('updateWorkoutExercise aggiorna la riga esistente', () async {
      final workoutId = await createWorkoutRow();
      final now = DateTime.now();
      final id = await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 1,
          dataCreazione: now,
          dataModifica: now,
        ),
      );
      final row = await database.allenamentiEserciziDao.getById(id);
      await database.allenamentiEserciziDao.updateWorkoutExercise(
        row!.copyWith(serie: const Value(3)).toCompanion(false),
      );

      final updated = await database.allenamentiEserciziDao.getById(id);
      expect(updated!.serie, 3);
    });

    test('deleteById rimuove la riga', () async {
      final workoutId = await createWorkoutRow();
      final now = DateTime.now();
      final id = await database.allenamentiEserciziDao.insert(
        AllenamentiEserciziTableCompanion.insert(
          idAllenamento: workoutId,
          idEsercizio: exerciseId,
          ordine: 1,
          dataCreazione: now,
          dataModifica: now,
        ),
      );
      await database.allenamentiEserciziDao.deleteById(id);
      expect(await database.allenamentiEserciziDao.getById(id), isNull);
    });

    test(
      'getNextOrder restituisce 1 su scheda vuota e max+1 altrimenti',
      () async {
        final workoutId = await createWorkoutRow();
        expect(
          await database.allenamentiEserciziDao.getNextOrder(workoutId),
          1,
        );

        final now = DateTime.now();
        await database.allenamentiEserciziDao.insert(
          AllenamentiEserciziTableCompanion.insert(
            idAllenamento: workoutId,
            idEsercizio: exerciseId,
            ordine: 1,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
        await database.allenamentiEserciziDao.insert(
          AllenamentiEserciziTableCompanion.insert(
            idAllenamento: workoutId,
            idEsercizio: exerciseId,
            ordine: 5,
            dataCreazione: now,
            dataModifica: now,
          ),
        );

        expect(
          await database.allenamentiEserciziDao.getNextOrder(workoutId),
          6,
        );
      },
    );
  });
}
