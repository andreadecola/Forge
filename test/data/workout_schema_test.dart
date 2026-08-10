import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';

/// Test di struttura per la Milestone 4.1: verifica che le nuove tabelle
/// `allenamenti`/`allenamenti_esercizi` esistano con i vincoli attesi.
/// Nessun DAO/repository applicativo in questa milestone: qui si inseriscono
/// solo righe minime necessarie a esercitare i vincoli DB direttamente via
/// Drift.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<int> insertProfilo(AppDatabase db) {
    final now = DateTime.now();
    return db
        .into(db.userProfilesTable)
        .insert(
          UserProfilesTableCompanion.insert(
            name: 'Alex',
            birthDate: DateTime(1990, 1, 1),
            heightCm: 175,
            initialWeightKg: 80,
            preferredWalkMinutes: 30,
            equipmentBudgetLimit: 50,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<int> insertCategoria(AppDatabase db, {String codice = 'MOBILITA'}) {
    final now = DateTime.now();
    return db
        .into(db.categorieEserciziTable)
        .insert(
          CategorieEserciziTableCompanion.insert(
            codice: codice,
            nome: 'Mobilità',
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<int> insertEsercizio(
    AppDatabase db, {
    required String codice,
    required int idCategoria,
  }) {
    final now = DateTime.now();
    return db
        .into(db.eserciziTable)
        .insert(
          EserciziTableCompanion.insert(
            codice: codice,
            nome: 'Esercizio $codice',
            descrizione: 'Descrizione',
            istruzioni: 'Istruzioni',
            idCategoria: idCategoria,
            livelloMinimo: 1,
            livelloImpatto: 'LOW',
            versioneCatalogo: 1,
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

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
            stato: 'DRAFT',
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
    required int ordine,
    int? serie,
    int? ripetizioni,
    int? durataSecondi,
    int? recuperoSecondi,
  }) {
    final now = DateTime.now();
    return db
        .into(db.allenamentiEserciziTable)
        .insert(
          AllenamentiEserciziTableCompanion.insert(
            idAllenamento: idAllenamento,
            idEsercizio: idEsercizio,
            ordine: ordine,
            serie: Value(serie),
            ripetizioni: Value(ripetizioni),
            durataSecondi: Value(durataSecondi),
            recuperoSecondi: Value(recuperoSecondi),
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

  test('schemaVersion è 3', () {
    expect(database.schemaVersion, 3);
  });

  test(
    'le tabelle allenamenti e allenamenti_esercizi esistono e sono vuote',
    (() async {
      expect(await database.select(database.allenamentiTable).get(), isEmpty);
      expect(
        await database.select(database.allenamentiEserciziTable).get(),
        isEmpty,
      );
    }),
  );

  test(
    'un allenamento richiede un profilo esistente (FK id_profilo)',
    () async {
      final idProfilo = await insertProfilo(database);
      final id = await insertAllenamento(database, idProfilo: idProfilo);

      final rows = await database.select(database.allenamentiTable).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
      expect(rows.single.idProfilo, idProfilo);
    },
  );

  test(
    'inserire un allenamento con id_profilo inesistente viene rifiutato',
    () async {
      expect(
        () => insertAllenamento(database, idProfilo: 999),
        throwsA(anything),
      );
    },
  );

  test(
    'una riga scheda richiede un allenamento e un esercizio esistenti',
    () async {
      final idProfilo = await insertProfilo(database);
      final idAllenamento = await insertAllenamento(
        database,
        idProfilo: idProfilo,
      );
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'LEG-001',
        idCategoria: idCategoria,
      );

      final id = await insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
        serie: 2,
        ripetizioni: 10,
      );

      final rows = await database
          .select(database.allenamentiEserciziTable)
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
    },
  );

  test(
    'inserire una riga scheda con id_allenamento inesistente viene rifiutato',
    () async {
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'LEG-002',
        idCategoria: idCategoria,
      );

      expect(
        () => insertAllenamentoEsercizio(
          database,
          idAllenamento: 999,
          idEsercizio: idEsercizio,
          ordine: 1,
        ),
        throwsA(anything),
      );
    },
  );

  test(
    'inserire una riga scheda con id_esercizio inesistente viene rifiutato',
    () async {
      final idProfilo = await insertProfilo(database);
      final idAllenamento = await insertAllenamento(
        database,
        idProfilo: idProfilo,
      );

      expect(
        () => insertAllenamentoEsercizio(
          database,
          idAllenamento: idAllenamento,
          idEsercizio: 999,
          ordine: 1,
        ),
        throwsA(anything),
      );
    },
  );

  test(
    'ordine duplicato nello stesso allenamento è rifiutato (UNIQUE)',
    () async {
      final idProfilo = await insertProfilo(database);
      final idAllenamento = await insertAllenamento(
        database,
        idProfilo: idProfilo,
      );
      final idCategoria = await insertCategoria(database);
      final idEsercizio1 = await insertEsercizio(
        database,
        codice: 'LEG-003',
        idCategoria: idCategoria,
      );
      final idEsercizio2 = await insertEsercizio(
        database,
        codice: 'LEG-004',
        idCategoria: idCategoria,
      );

      await insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio1,
        ordine: 1,
      );

      expect(
        () => insertAllenamentoEsercizio(
          database,
          idAllenamento: idAllenamento,
          idEsercizio: idEsercizio2,
          ordine: 1,
        ),
        throwsA(anything),
      );
    },
  );

  test(
    'lo stesso esercizio può comparire più volte nello stesso allenamento '
    'se l\'ordine è diverso (nessun UNIQUE su id_allenamento+id_esercizio)',
    () async {
      final idProfilo = await insertProfilo(database);
      final idAllenamento = await insertAllenamento(
        database,
        idProfilo: idProfilo,
      );
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'CORE-001',
        idCategoria: idCategoria,
      );

      await insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
      );
      await insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 2,
      );

      final rows = await database
          .select(database.allenamentiEserciziTable)
          .get();
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.idEsercizio == idEsercizio), isTrue);
    },
  );

  test(
    'nome allenamento NOT NULL (rifiutato se assente a livello SQL)',
    () async {
      final idProfilo = await insertProfilo(database);

      expect(
        () => database.customStatement(
          'INSERT INTO allenamenti '
          '(id_profilo, tipo_allenamento, stato, origine, data_creazione, data_modifica) '
          'VALUES ($idProfilo, "FULL_BODY", "DRAFT", "USER", 0, 0)',
        ),
        throwsA(anything),
      );
    },
  );

  test('livello deve essere > 0 (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final now = DateTime.now();

    expect(
      () => database
          .into(database.allenamentiTable)
          .insert(
            AllenamentiTableCompanion.insert(
              idProfilo: idProfilo,
              nome: 'Scheda',
              tipoAllenamento: 'FULL_BODY',
              stato: 'DRAFT',
              origine: 'USER',
              livello: const Value(0),
              dataCreazione: now,
              dataModifica: now,
            ),
          ),
      throwsA(anything),
    );
  });

  test(
    'durata_stimata_minuti non valida (<= 0) è rifiutata se presente (CHECK)',
    () async {
      final idProfilo = await insertProfilo(database);
      final now = DateTime.now();

      expect(
        () => database
            .into(database.allenamentiTable)
            .insert(
              AllenamentiTableCompanion.insert(
                idProfilo: idProfilo,
                nome: 'Scheda',
                tipoAllenamento: 'FULL_BODY',
                stato: 'DRAFT',
                origine: 'USER',
                durataStimataMinuti: const Value(0),
                dataCreazione: now,
                dataModifica: now,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('ordine <= 0 è rifiutato (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'BAL-001',
      idCategoria: idCategoria,
    );

    expect(
      () => insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 0,
      ),
      throwsA(anything),
    );
  });

  test('serie <= 0 è rifiutata se presente (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'BAL-002',
      idCategoria: idCategoria,
    );

    expect(
      () => insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
        serie: 0,
      ),
      throwsA(anything),
    );
  });

  test('ripetizioni <= 0 sono rifiutate se presenti (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'BAL-003',
      idCategoria: idCategoria,
    );

    expect(
      () => insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
        ripetizioni: -1,
      ),
      throwsA(anything),
    );
  });

  test('durata_secondi <= 0 è rifiutata se presente (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'BAL-004',
      idCategoria: idCategoria,
    );

    expect(
      () => insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
        durataSecondi: 0,
      ),
      throwsA(anything),
    );
  });

  test('recupero_secondi < 0 è rifiutato se presente (CHECK)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'BAL-005',
      idCategoria: idCategoria,
    );

    expect(
      () => insertAllenamentoEsercizio(
        database,
        idAllenamento: idAllenamento,
        idEsercizio: idEsercizio,
        ordine: 1,
        recuperoSecondi: -1,
      ),
      throwsA(anything),
    );

    // recupero_secondi = 0 è invece valido (recupero nullo, non negativo).
    await insertAllenamentoEsercizio(
      database,
      idAllenamento: idAllenamento,
      idEsercizio: idEsercizio,
      ordine: 1,
      recuperoSecondi: 0,
    );
  });

  test('eliminare un allenamento elimina in CASCADE le sue righe scheda ma '
      'non l\'esercizio master', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'CARD-001',
      idCategoria: idCategoria,
    );
    await insertAllenamentoEsercizio(
      database,
      idAllenamento: idAllenamento,
      idEsercizio: idEsercizio,
      ordine: 1,
    );

    await (database.delete(
      database.allenamentiTable,
    )..where((t) => t.id.equals(idAllenamento))).go();

    expect(
      await database.select(database.allenamentiEserciziTable).get(),
      isEmpty,
    );
    final esercizi = await database.select(database.eserciziTable).get();
    expect(esercizi, hasLength(1));
    expect(esercizi.single.id, idEsercizio);
  });

  test('eliminare un esercizio ancora referenziato da una scheda è rifiutato '
      '(nessun cascade su id_esercizio)', () async {
    final idProfilo = await insertProfilo(database);
    final idAllenamento = await insertAllenamento(
      database,
      idProfilo: idProfilo,
    );
    final idCategoria = await insertCategoria(database);
    final idEsercizio = await insertEsercizio(
      database,
      codice: 'CARD-002',
      idCategoria: idCategoria,
    );
    await insertAllenamentoEsercizio(
      database,
      idAllenamento: idAllenamento,
      idEsercizio: idEsercizio,
      ordine: 1,
    );

    expect(
      () => (database.delete(
        database.eserciziTable,
      )..where((t) => t.id.equals(idEsercizio))).go(),
      throwsA(anything),
    );
  });

  test('indice su allenamenti.id_profilo esiste', () async {
    expect(
      await indexNamesFor(database, 'allenamenti'),
      contains('idx_allenamenti_id_profilo'),
    );
  });

  test('indice su allenamenti.attivo esiste', () async {
    expect(
      await indexNamesFor(database, 'allenamenti'),
      contains('idx_allenamenti_attivo'),
    );
  });

  test('indice su allenamenti_esercizi.id_allenamento esiste', () async {
    expect(
      await indexNamesFor(database, 'allenamenti_esercizi'),
      contains('idx_allenamenti_esercizi_id_allenamento'),
    );
  });

  test('indice su allenamenti_esercizi.id_esercizio esiste', () async {
    expect(
      await indexNamesFor(database, 'allenamenti_esercizi'),
      contains('idx_allenamenti_esercizi_id_esercizio'),
    );
  });
}
