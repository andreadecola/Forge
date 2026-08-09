import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';

/// Test di struttura per la Milestone 3.1: verifica che le nuove tabelle del
/// catalogo esercizi esistano con i vincoli attesi. Nessun dato applicativo
/// viene importato in questa milestone: qui si inseriscono solo righe
/// minime necessarie a esercitare i vincoli DB.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

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

  Future<int> insertGruppoMuscolare(AppDatabase db, {String codice = 'CORE'}) {
    final now = DateTime.now();
    return db
        .into(db.gruppiMuscolariTable)
        .insert(
          GruppiMuscolariTableCompanion.insert(
            codice: codice,
            nome: 'Core',
            dataCreazione: now,
            dataModifica: now,
          ),
        );
  }

  Future<int> insertAttrezzatura(AppDatabase db, {String codice = 'CHAIR'}) {
    final now = DateTime.now();
    return db
        .into(db.attrezzatureTable)
        .insert(
          AttrezzatureTableCompanion.insert(
            codice: codice,
            nome: 'Sedia',
            versioneCatalogo: 1,
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

  test('lo schema 2 crea tutte le tabelle del catalogo esercizi', () async {
    expect(
      await database.select(database.categorieEserciziTable).get(),
      isEmpty,
    );
    expect(await database.select(database.gruppiMuscolariTable).get(), isEmpty);
    expect(await database.select(database.eserciziTable).get(), isEmpty);
    expect(
      await database.select(database.eserciziGruppiMuscolariTable).get(),
      isEmpty,
    );
    expect(await database.select(database.attrezzatureTable).get(), isEmpty);
    expect(
      await database.select(database.attrezzatureEserciziTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.immaginiEserciziTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.progressioniEserciziTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.alternativeEserciziTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.versioniCatalogoTable).get(),
      isEmpty,
    );
  });

  test('codice categoria è UNIQUE', () async {
    await insertCategoria(database, codice: 'MOBILITA');

    expect(
      () => insertCategoria(database, codice: 'MOBILITA'),
      throwsA(anything),
    );
  });

  test('codice esercizio è UNIQUE', () async {
    final idCategoria = await insertCategoria(database);
    await insertEsercizio(
      database,
      codice: 'LEG-001',
      idCategoria: idCategoria,
    );

    expect(
      () => insertEsercizio(
        database,
        codice: 'LEG-001',
        idCategoria: idCategoria,
      ),
      throwsA(anything),
    );
  });

  test('codice attrezzatura è UNIQUE', () async {
    await insertAttrezzatura(database, codice: 'CHAIR');

    expect(
      () => insertAttrezzatura(database, codice: 'CHAIR'),
      throwsA(anything),
    );
  });

  test(
    'esercizi_gruppi_muscolari ha vincolo UNIQUE su esercizio+gruppo',
    () async {
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'LEG-001',
        idCategoria: idCategoria,
      );
      final idGruppo = await insertGruppoMuscolare(database);

      await database
          .into(database.eserciziGruppiMuscolariTable)
          .insert(
            EserciziGruppiMuscolariTableCompanion.insert(
              idEsercizio: idEsercizio,
              idGruppoMuscolare: idGruppo,
              tipoCoinvolgimento: 'PRIMARIO',
            ),
          );

      expect(
        () => database
            .into(database.eserciziGruppiMuscolariTable)
            .insert(
              EserciziGruppiMuscolariTableCompanion.insert(
                idEsercizio: idEsercizio,
                idGruppoMuscolare: idGruppo,
                tipoCoinvolgimento: 'SECONDARIO',
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test(
    'attrezzature_esercizi ha vincolo UNIQUE su esercizio+attrezzatura',
    () async {
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'PUSH-001',
        idCategoria: idCategoria,
      );
      final idAttrezzatura = await insertAttrezzatura(database);

      await database
          .into(database.attrezzatureEserciziTable)
          .insert(
            AttrezzatureEserciziTableCompanion.insert(
              idEsercizio: idEsercizio,
              idAttrezzatura: idAttrezzatura,
            ),
          );

      expect(
        () => database
            .into(database.attrezzatureEserciziTable)
            .insert(
              AttrezzatureEserciziTableCompanion.insert(
                idEsercizio: idEsercizio,
                idAttrezzatura: idAttrezzatura,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test(
    'progressioni_esercizi non ammette un esercizio come progressione di se stesso',
    () async {
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'LEG-002',
        idCategoria: idCategoria,
      );
      final now = DateTime.now();

      expect(
        () => database
            .into(database.progressioniEserciziTable)
            .insert(
              ProgressioniEserciziTableCompanion.insert(
                idEsercizio: idEsercizio,
                idEsercizioSuccessivo: idEsercizio,
                tipoProgressione: 'TECNICA',
                livelloMinimo: 1,
                dataCreazione: now,
                dataModifica: now,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test(
    'alternative_esercizi non ammette un esercizio come alternativa di se stesso',
    () async {
      final idCategoria = await insertCategoria(database);
      final idEsercizio = await insertEsercizio(
        database,
        codice: 'LEG-003',
        idCategoria: idCategoria,
      );
      final now = DateTime.now();

      expect(
        () => database
            .into(database.alternativeEserciziTable)
            .insert(
              AlternativeEserciziTableCompanion.insert(
                idEsercizio: idEsercizio,
                idEsercizioAlternativo: idEsercizio,
                codiceMotivo: 'DIFFICOLTA',
                dataCreazione: now,
                dataModifica: now,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('tipo_catalogo + versione in versioni_catalogo è UNIQUE', () async {
    final now = DateTime.now();
    await database
        .into(database.versioniCatalogoTable)
        .insert(
          VersioniCatalogoTableCompanion.insert(
            tipoCatalogo: 'ESERCIZI',
            versione: 1,
            dataImportazione: now,
          ),
        );

    expect(
      () => database
          .into(database.versioniCatalogoTable)
          .insert(
            VersioniCatalogoTableCompanion.insert(
              tipoCatalogo: 'ESERCIZI',
              versione: 1,
              dataImportazione: now,
            ),
          ),
      throwsA(anything),
    );
  });
}
