import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';

import 'workout_test_helpers.dart';

/// Test di struttura per la Milestone 4.4.3: verifica che le nuove tabelle
/// `sessioni_allenamento`/`sessioni_esercizi` esistano con i vincoli
/// attesi. Stesso stile di `workout_schema_test.dart` (Milestone 4.1).
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<int> insertAllenamento(
    AppDatabase db, {
    required int idProfilo,
    String nome = 'Scheda A',
  }) {
    final now = DateTime.now();
    return db
        .into(db.allenamentiTable)
        .insert(
          AllenamentiTableCompanion.insert(
            idProfilo: idProfilo,
            nome: nome,
            tipoAllenamento: 'FULL_BODY',
            stato: 'READY',
            origine: 'USER',
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<int> insertAllenamentoEsercizio(
    AppDatabase db, {
    required int idAllenamento,
    required int idEsercizio,
    int ordine = 1,
  }) {
    final now = DateTime.now();
    return db
        .into(db.allenamentiEserciziTable)
        .insert(
          AllenamentiEserciziTableCompanion.insert(
            idAllenamento: idAllenamento,
            idEsercizio: idEsercizio,
            ordine: ordine,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<int> insertSessione(
    AppDatabase db, {
    int? idAllenamento,
    required int idProfilo,
    String nome = 'Scheda A',
    String stato = 'IN_PROGRESS',
  }) {
    final now = DateTime.now();
    return db
        .into(db.sessioniAllenamentoTable)
        .insert(
          SessioniAllenamentoTableCompanion.insert(
            idAllenamento: Value(idAllenamento),
            idProfilo: idProfilo,
            nomeAllenamentoSnapshot: nome,
            stato: stato,
            dataInizio: now,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<int> insertSessioneEsercizio(
    AppDatabase db, {
    required int idSessione,
    int? idAllenamentoEsercizio,
    required int idEsercizio,
    int ordine = 1,
    int serieTotali = 3,
  }) {
    final now = DateTime.now();
    return db
        .into(db.sessioniEserciziTable)
        .insert(
          SessioniEserciziTableCompanion.insert(
            idSessione: idSessione,
            idAllenamentoEsercizio: Value(idAllenamentoEsercizio),
            idEsercizio: idEsercizio,
            ordine: ordine,
            serieTotali: serieTotali,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<Set<String>> indexNamesFor(AppDatabase db, String tableName) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = ?",
          variables: [Variable.withString(tableName)],
        )
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  test('schemaVersion è 6', () {
    expect(database.schemaVersion, 6);
  });

  test('le tabelle sessioni_allenamento e sessioni_esercizi esistono e sono '
      'vuote', () async {
    expect(
      await database.select(database.sessioniAllenamentoTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.sessioniEserciziTable).get(),
      isEmpty,
    );
  });

  test('una sessione richiede un profilo esistente (FK id_profilo)', () async {
    expect(() => insertSessione(database, idProfilo: 999), throwsA(anything));
  });

  test('una sessione può essere creata senza scheda collegata (id_allenamento '
      'nullable)', () async {
    final idProfilo = await insertProfilo(database);
    final id = await insertSessione(
      database,
      idProfilo: idProfilo,
      nome: 'Orfana',
    );
    final rows = await database.select(database.sessioniAllenamentoTable).get();
    expect(rows.single.id, id);
    expect(rows.single.idAllenamento, isNull);
  });

  test('eliminare la scheda collegata azzera id_allenamento della sessione '
      '(ON DELETE SET NULL, non CASCADE): la sessione sopravvive', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idSessione = await insertSessione(
      database,
      idAllenamento: idAllenamento,
      idProfilo: idProfilo,
      nome: 'Scheda che verrà eliminata',
    );

    await (database.delete(
      database.allenamentiTable,
    )..where((t) => t.id.equals(idAllenamento))).go();

    final rows = await database.select(database.sessioniAllenamentoTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, idSessione);
    expect(rows.single.idAllenamento, isNull);
    expect(rows.single.nomeAllenamentoSnapshot, 'Scheda che verrà eliminata');
  });

  test('una riga sessioni_esercizi richiede una sessione e un esercizio '
      'esistenti', () async {
    final idProfilo = await insertProfilo(database);
    final idSessione = await insertSessione(database, idProfilo: idProfilo);
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'SESS-001',
      idCategoria: idCategoria,
    );

    final id = await insertSessioneEsercizio(
      database,
      idSessione: idSessione,
      idEsercizio: idEsercizio,
    );

    final rows = await database.select(database.sessioniEserciziTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, id);
  });

  test(
    'eliminare la sessione elimina in CASCADE le sue righe snapshot',
    () async {
      final idProfilo = await insertProfilo(database);
      final idSessione = await insertSessione(database, idProfilo: idProfilo);
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'SESS-002',
        idCategoria: idCategoria,
      );
      await insertSessioneEsercizio(
        database,
        idSessione: idSessione,
        idEsercizio: idEsercizio,
      );

      await (database.delete(
        database.sessioniAllenamentoTable,
      )..where((t) => t.id.equals(idSessione))).go();

      expect(
        await database.select(database.sessioniEserciziTable).get(),
        isEmpty,
      );
    },
  );

  test('eliminare la scheda azzera id_allenamento_esercizio delle righe '
      'snapshot collegate (CASCADE su allenamenti_esercizi, poi SET NULL qui): '
      'lo snapshot resta leggibile', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'SESS-003',
      idCategoria: idCategoria,
    );
    final idAllenamentoEsercizio = await insertAllenamentoEsercizio(
      database,
      idAllenamento: idAllenamento,
      idEsercizio: idEsercizio,
    );
    final idSessione = await insertSessione(
      database,
      idAllenamento: idAllenamento,
      idProfilo: idProfilo,
    );
    await insertSessioneEsercizio(
      database,
      idSessione: idSessione,
      idAllenamentoEsercizio: idAllenamentoEsercizio,
      idEsercizio: idEsercizio,
      serieTotali: 4,
    );

    await (database.delete(
      database.allenamentiTable,
    )..where((t) => t.id.equals(idAllenamento))).go();

    final rows = await database.select(database.sessioniEserciziTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.idAllenamentoEsercizio, isNull);
    expect(
      rows.single.serieTotali,
      4,
      reason: 'lo snapshot dei parametri resta intatto',
    );
  });

  test('eliminare un esercizio ancora referenziato da uno snapshot è rifiutato '
      '(nessun cascade su id_esercizio)', () async {
    final idProfilo = await insertProfilo(database);
    final idSessione = await insertSessione(database, idProfilo: idProfilo);
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'SESS-004',
      idCategoria: idCategoria,
    );
    await insertSessioneEsercizio(
      database,
      idSessione: idSessione,
      idEsercizio: idEsercizio,
    );

    expect(
      () => (database.delete(
        database.eserciziTable,
      )..where((t) => t.id.equals(idEsercizio))).go(),
      throwsA(anything),
    );
  });

  test('ordine duplicato nella stessa sessione è rifiutato (UNIQUE)', () async {
    final idProfilo = await insertProfilo(database);
    final idSessione = await insertSessione(database, idProfilo: idProfilo);
    final idCategoria = await insertCategoria(database);
    final idEsercizio1 = await insertEsercizio(
      database,
      codice: 'SESS-005',
      idCategoria: idCategoria,
    );
    final idEsercizio2 = await insertEsercizio(
      database,
      codice: 'SESS-006',
      idCategoria: idCategoria,
    );

    await insertSessioneEsercizio(
      database,
      idSessione: idSessione,
      idEsercizio: idEsercizio1,
      ordine: 1,
    );

    expect(
      () => insertSessioneEsercizio(
        database,
        idSessione: idSessione,
        idEsercizio: idEsercizio2,
        ordine: 1,
      ),
      throwsA(anything),
    );
  });

  test('serie_totali <= 0 è rifiutata (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idSessione = await insertSessione(database, idProfilo: idProfilo);
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'SESS-007',
      idCategoria: idCategoria,
    );

    expect(
      () => insertSessioneEsercizio(
        database,
        idSessione: idSessione,
        idEsercizio: idEsercizio,
        serieTotali: 0,
      ),
      throwsA(anything),
    );
  });

  test('indice_esercizio_corrente < 0 è rifiutato (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final now = DateTime.now();

    expect(
      () => database
          .into(database.sessioniAllenamentoTable)
          .insert(
            SessioniAllenamentoTableCompanion.insert(
              idProfilo: idProfilo,
              nomeAllenamentoSnapshot: 'Scheda',
              stato: 'IN_PROGRESS',
              indiceEsercizioCorrente: const Value(-1),
              dataInizio: now,
              dataCreazione: now,
              dataModifica: now,
            ),
          ),
      throwsA(anything),
    );
  });

  test('indice su sessioni_allenamento.id_allenamento esiste', () async {
    expect(
      await indexNamesFor(database, 'sessioni_allenamento'),
      contains('idx_sessioni_allenamento_id_allenamento'),
    );
  });

  test('indice su sessioni_allenamento.id_profilo esiste', () async {
    expect(
      await indexNamesFor(database, 'sessioni_allenamento'),
      contains('idx_sessioni_allenamento_id_profilo'),
    );
  });

  test('indice su sessioni_allenamento.stato esiste', () async {
    expect(
      await indexNamesFor(database, 'sessioni_allenamento'),
      contains('idx_sessioni_allenamento_stato'),
    );
  });

  test('indice su sessioni_esercizi.id_sessione esiste', () async {
    expect(
      await indexNamesFor(database, 'sessioni_esercizi'),
      contains('idx_sessioni_esercizi_id_sessione'),
    );
  });

  test('indice su sessioni_esercizi.id_allenamento_esercizio esiste', () async {
    expect(
      await indexNamesFor(database, 'sessioni_esercizi'),
      contains('idx_sessioni_esercizi_id_allenamento_esercizio'),
    );
  });
}
