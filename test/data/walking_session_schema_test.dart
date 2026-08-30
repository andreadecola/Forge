import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';

import 'workout_test_helpers.dart';

void main() {
  late AppDatabase database;
  late int profileId;
  late DateTime startedAt;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    profileId = await insertProfilo(database);
    startedAt = DateTime(2026, 1, 1, 10);
  });

  tearDown(() => database.close());

  CamminateTableCompanion walkingSession({
    required int idProfilo,
    required DateTime dataInizio,
    String stato = 'IN_PROGRESS',
    DateTime? dataFine,
    int? distanzaMetri,
    int? passi,
    bool pausaInCorso = false,
    DateTime? dataInizioPausa,
    int durataPausaSecondi = 0,
  }) {
    return CamminateTableCompanion.insert(
      idProfilo: idProfilo,
      dataInizio: dataInizio,
      dataFine: Value(dataFine),
      distanzaMetri: Value(distanzaMetri),
      passi: Value(passi),
      pausaInCorso: Value(pausaInCorso),
      dataInizioPausa: Value(dataInizioPausa),
      durataPausaSecondi: Value(durataPausaSecondi),
      stato: stato,
      dataCreazione: dataInizio,
      dataModifica: dataInizio,
    );
  }

  test('schema 11 e tabella camminate esistono', () async {
    expect(database.schemaVersion, 11);
    expect(await database.select(database.camminateTable).get(), isEmpty);
  });

  test('insert valido, FK valida e valori nullable', () async {
    final id = await database
        .into(database.camminateTable)
        .insert(
          walkingSession(
            idProfilo: profileId,
            dataInizio: startedAt,
            distanzaMetri: null,
            passi: null,
          ),
        );
    final row = await (database.select(
      database.camminateTable,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.idProfilo, profileId);
    expect(row.dataFine, isNull);
    expect(row.distanzaMetri, isNull);
    expect(row.passi, isNull);
    expect(row.pausaInCorso, isFalse);
    expect(row.dataInizioPausa, isNull);
    expect(row.durataPausaSecondi, 0);
  });

  test('FK profilo inesistente rifiutata', () async {
    expect(
      () => database
          .into(database.camminateTable)
          .insert(walkingSession(idProfilo: 999, dataInizio: startedAt)),
      throwsA(anything),
    );
  });

  test('CHECK rifiuta passi/distanza negativi e accetta zero', () async {
    expect(
      () => database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt,
              passi: -1,
            ),
          ),
      throwsA(anything),
    );
    expect(
      () => database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt,
              distanzaMetri: -1,
            ),
          ),
      throwsA(anything),
    );
    final id = await database
        .into(database.camminateTable)
        .insert(
          walkingSession(
            idProfilo: profileId,
            dataInizio: startedAt,
            distanzaMetri: 0,
            passi: 0,
          ),
        );
    expect(id, isPositive);
  });

  test('CHECK rifiuta durata pausa negativa', () async {
    expect(
      () => database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt,
              durataPausaSecondi: -1,
            ),
          ),
      throwsA(anything),
    );
  });

  test(
    'storico per profilo è ordinato per inizio DESC con tie-break id',
    () async {
      await database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt,
              stato: 'COMPLETED',
              dataFine: startedAt.add(const Duration(minutes: 1)),
            ),
          );
      final second = await database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt,
              stato: 'COMPLETED',
              dataFine: startedAt.add(const Duration(minutes: 1)),
            ),
          );
      final otherProfile = await insertProfilo(database);
      await database
          .into(database.camminateTable)
          .insert(
            walkingSession(idProfilo: otherProfile, dataInizio: startedAt),
          );

      final rows = await database.camminateDao.getByProfile(profileId);
      expect(rows, hasLength(2));
      expect(rows.first.id, second);
    },
  );

  test('una sola camminata attiva per profilo e dataFine nullable', () async {
    await database
        .into(database.camminateTable)
        .insert(walkingSession(idProfilo: profileId, dataInizio: startedAt));
    expect(
      () => database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt.add(const Duration(minutes: 1)),
            ),
          ),
      throwsA(anything),
    );
    expect(
      await database.camminateDao.getActiveByProfile(profileId),
      isNotNull,
    );
  });

  test(
    'complete e abort preservano lo storico senza cancellazione implicita',
    () async {
      final completed = await database
          .into(database.camminateTable)
          .insert(walkingSession(idProfilo: profileId, dataInizio: startedAt));
      await database.camminateDao.complete(
        completed,
        CamminateTableCompanion(
          stato: const Value('COMPLETED'),
          dataFine: Value(startedAt.add(const Duration(minutes: 20))),
          dataModifica: Value(startedAt.add(const Duration(minutes: 20))),
        ),
      );
      final aborted = await database
          .into(database.camminateTable)
          .insert(
            walkingSession(
              idProfilo: profileId,
              dataInizio: startedAt.add(const Duration(hours: 1)),
            ),
          );
      await database.camminateDao.abort(
        aborted,
        CamminateTableCompanion(
          stato: const Value('ABORTED'),
          dataFine: Value(startedAt.add(const Duration(hours: 1, minutes: 5))),
          dataModifica: Value(
            startedAt.add(const Duration(hours: 1, minutes: 5)),
          ),
        ),
      );

      final rows = await database.camminateDao.getByProfile(profileId);
      expect(rows, hasLength(2));
      expect(
        rows.map((row) => row.stato),
        containsAll(['COMPLETED', 'ABORTED']),
      );
      expect(await database.camminateDao.getActiveByProfile(profileId), isNull);
    },
  );
}
