import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categorie_esercizi_table.dart';
import '../tables/esercizi_table.dart';

part 'esercizi_dao.g.dart';

@DriftAccessor(tables: [EserciziTable, CategorieEserciziTable])
class EserciziDao extends DatabaseAccessor<AppDatabase>
    with _$EserciziDaoMixin {
  EserciziDao(super.db);

  Future<List<EserciziTableData>> getAll() => (select(
    eserciziTable,
  )..orderBy([(t) => OrderingTerm.asc(t.codice)])).get();

  Stream<List<EserciziTableData>> watchAll() => (select(
    eserciziTable,
  )..orderBy([(t) => OrderingTerm.asc(t.codice)])).watch();

  Future<List<EserciziTableData>> getActiveExercises() =>
      (select(eserciziTable)
            ..where((t) => t.attivo.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.codice)]))
          .get();

  Future<EserciziTableData?> getById(int id) =>
      (select(eserciziTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<EserciziTableData?> getByCode(String code) => (select(
    eserciziTable,
  )..where((t) => t.codice.equals(code))).getSingleOrNull();

  Future<List<EserciziTableData>> getByCategory(int categoryId) =>
      (select(eserciziTable)
            ..where((t) => t.idCategoria.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.asc(t.codice)]))
          .get();

  Future<List<EserciziTableData>> getByCategoryCode(String categoryCode) {
    final query = select(eserciziTable).join([
      innerJoin(
        categorieEserciziTable,
        categorieEserciziTable.id.equalsExp(eserciziTable.idCategoria),
      ),
    ])..where(categorieEserciziTable.codice.equals(categoryCode));
    query.orderBy([OrderingTerm.asc(eserciziTable.codice)]);
    return query.map((row) => row.readTable(eserciziTable)).get();
  }

  /// Esercizi compatibili con [userLevel]. Regola livello (punto unico lato
  /// SQL, speculare a `ExerciseLevelPolicy` lato Dart):
  ///   livelloMinimo <= userLevel
  ///   AND (livelloMassimo IS NULL OR userLevel <= livelloMassimo)
  Future<List<EserciziTableData>> getByLevel(int userLevel) =>
      (select(eserciziTable)
            ..where(
              (t) =>
                  t.livelloMinimo.isSmallerOrEqualValue(userLevel) &
                  (t.livelloMassimo.isNull() |
                      t.livelloMassimo.isBiggerOrEqualValue(userLevel)),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.codice)]))
          .get();

  Future<List<EserciziTableData>> search(String text) {
    final pattern = '%${text.trim()}%';
    return (select(eserciziTable)
          ..where(
            (t) =>
                t.nome.like(pattern) |
                t.codice.like(pattern) |
                t.descrizione.like(pattern),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.codice)]))
        .get();
  }
}
