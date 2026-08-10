import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/allenamenti_table.dart';

part 'allenamenti_dao.g.dart';

@DriftAccessor(tables: [AllenamentiTable])
class AllenamentiDao extends DatabaseAccessor<AppDatabase>
    with _$AllenamentiDaoMixin {
  AllenamentiDao(super.db);

  /// Schede attive del profilo, più recenti prima. Le schede archiviate
  /// (`attivo = false`) non compaiono nell'elenco normale.
  Future<List<AllenamentiTableData>> getAllByProfile(int profileId) =>
      (select(allenamentiTable)
            ..where(
              (t) => t.idProfilo.equals(profileId) & t.attivo.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.dataModifica)]))
          .get();

  Stream<List<AllenamentiTableData>> watchAllByProfile(int profileId) =>
      (select(allenamentiTable)
            ..where(
              (t) => t.idProfilo.equals(profileId) & t.attivo.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.dataModifica)]))
          .watch();

  Future<AllenamentiTableData?> getById(int id) => (select(
    allenamentiTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> create(AllenamentiTableCompanion workout) =>
      into(allenamentiTable).insert(workout);

  /// Rinominato rispetto al verbo "update" per non collidere con il metodo
  /// generico [DatabaseAccessor.update] (stesso nome, firma incompatibile:
  /// Drift genera un errore di compilazione se si tenta di sovrascriverlo).
  Future<bool> updateWorkout(AllenamentiTableCompanion workout) =>
      update(allenamentiTable).replace(workout);

  /// Aggiorna solo stato/attivo (usato da archive), senza toccare il resto
  /// della riga.
  Future<int> setStatus(
    int id, {
    required String stato,
    required bool attivo,
    required DateTime dataModifica,
  }) => (update(allenamentiTable)..where((t) => t.id.equals(id))).write(
    AllenamentiTableCompanion(
      stato: Value(stato),
      attivo: Value(attivo),
      dataModifica: Value(dataModifica),
    ),
  );

  /// Hard delete: elimina la scheda. Le righe `allenamenti_esercizi`
  /// collegate vengono eliminate in CASCADE dal vincolo FK (schema 3,
  /// `foreign_keys = ON`); il catalogo esercizi non viene mai toccato.
  Future<int> deleteById(int id) =>
      (delete(allenamentiTable)..where((t) => t.id.equals(id))).go();
}
