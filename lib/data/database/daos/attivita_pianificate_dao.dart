import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/attivita_pianificate_table.dart';

part 'attivita_pianificate_dao.g.dart';

@DriftAccessor(tables: [AttivitaPianificateTable])
class AttivitaPianificateDao extends DatabaseAccessor<AppDatabase>
    with _$AttivitaPianificateDaoMixin {
  AttivitaPianificateDao(super.db);

  /// Ordinate per data pianificata crescente, con tie-break su `id`
  /// crescente a parità di data (sezione 34): determinismo anche con più
  /// attività nello stesso giorno.
  Future<List<AttivitaPianificateTableData>> getForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    return (select(attivitaPianificateTable)
          ..where(
            (t) =>
                t.idProfilo.equals(profileId) &
                t.dataPianificata.isBiggerOrEqualValue(weekStart) &
                t.dataPianificata.isSmallerOrEqualValue(weekEnd),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.dataPianificata),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Stream<List<AttivitaPianificateTableData>> watchForWeek({
    required int profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    return (select(attivitaPianificateTable)
          ..where(
            (t) =>
                t.idProfilo.equals(profileId) &
                t.dataPianificata.isBiggerOrEqualValue(weekStart) &
                t.dataPianificata.isSmallerOrEqualValue(weekEnd),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.dataPianificata),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch();
  }

  /// Tutte le attività pianificate del profilo, senza vincolo di
  /// settimana (Backup.2): stesso ordinamento deterministico di
  /// [getForWeek], solo senza il filtro sull'intervallo di date.
  Future<List<AttivitaPianificateTableData>> getAllByProfile(int profileId) {
    return (select(attivitaPianificateTable)
          ..where((t) => t.idProfilo.equals(profileId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.dataPianificata),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<AttivitaPianificateTableData?> getById(int id) => (select(
    attivitaPianificateTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> create(AttivitaPianificateTableCompanion activity) =>
      into(attivitaPianificateTable).insert(activity);

  /// Rinominato rispetto al verbo "update" per non collidere con il metodo
  /// generico `DatabaseAccessor.update` (stesso motivo di
  /// `AllenamentiDao.updateWorkout`).
  Future<bool> updateActivity(AttivitaPianificateTableCompanion activity) =>
      update(attivitaPianificateTable).replace(activity);

  Future<int> deleteById(int id) =>
      (delete(attivitaPianificateTable)..where((t) => t.id.equals(id))).go();
}
