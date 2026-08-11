import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/camminate_table.dart';

part 'camminate_dao.g.dart';

@DriftAccessor(tables: [CamminateTable])
class CamminateDao extends DatabaseAccessor<AppDatabase>
    with _$CamminateDaoMixin {
  CamminateDao(super.db);

  Future<int> create(CamminateTableCompanion walkingSession) =>
      into(camminateTable).insert(walkingSession);

  Future<CamminateTableData?> getById(int id) =>
      (select(camminateTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CamminateTableData>> getByProfile(int profileId) =>
      (select(camminateTable)
            ..where((t) => t.idProfilo.equals(profileId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.dataInizio),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<List<CamminateTableData>> getHistoryByProfile(
    int profileId, {
    DateTime? since,
  }) =>
      (select(camminateTable)
            ..where((t) => _historyPredicate(t, profileId, since))
            ..orderBy([
              (t) => OrderingTerm.desc(t.dataInizio),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Stream<List<CamminateTableData>> watchByProfile(int profileId) =>
      (select(camminateTable)
            ..where((t) => t.idProfilo.equals(profileId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.dataInizio),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Stream<List<CamminateTableData>> watchHistoryByProfile(
    int profileId, {
    DateTime? since,
  }) =>
      (select(camminateTable)
            ..where((t) => _historyPredicate(t, profileId, since))
            ..orderBy([
              (t) => OrderingTerm.desc(t.dataInizio),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Expression<bool> _historyPredicate(
    $CamminateTableTable t,
    int profileId,
    DateTime? since,
  ) {
    var predicate =
        t.idProfilo.equals(profileId) &
        t.stato.isIn(const ['COMPLETED', 'ABORTED']);
    if (since != null) {
      predicate = predicate & t.dataInizio.isBiggerOrEqualValue(since);
    }
    return predicate;
  }

  Future<CamminateTableData?> getActiveByProfile(int profileId) =>
      (select(camminateTable)
            ..where(
              (t) =>
                  t.idProfilo.equals(profileId) & t.stato.equals('IN_PROGRESS'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> updateWalkingSession(int id, CamminateTableCompanion changes) =>
      (update(camminateTable)..where((t) => t.id.equals(id))).write(changes);

  Future<int> pause(int id, CamminateTableCompanion changes) =>
      (update(camminateTable)..where(
            (t) =>
                t.id.equals(id) &
                t.stato.equals('IN_PROGRESS') &
                t.pausaInCorso.equals(false),
          ))
          .write(changes);

  Future<int> resume(int id, CamminateTableCompanion changes) =>
      (update(camminateTable)..where(
            (t) =>
                t.id.equals(id) &
                t.stato.equals('IN_PROGRESS') &
                t.pausaInCorso.equals(true),
          ))
          .write(changes);

  Future<int> complete(int id, CamminateTableCompanion changes) =>
      (update(camminateTable)
            ..where((t) => t.id.equals(id) & t.stato.equals('IN_PROGRESS')))
          .write(changes);

  Future<int> abort(int id, CamminateTableCompanion changes) =>
      (update(camminateTable)
            ..where((t) => t.id.equals(id) & t.stato.equals('IN_PROGRESS')))
          .write(changes);
}
