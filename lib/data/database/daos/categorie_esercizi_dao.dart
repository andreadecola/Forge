import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categorie_esercizi_table.dart';

part 'categorie_esercizi_dao.g.dart';

@DriftAccessor(tables: [CategorieEserciziTable])
class CategorieEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$CategorieEserciziDaoMixin {
  CategorieEserciziDao(super.db);

  SimpleSelectStatement<
    $CategorieEserciziTableTable,
    CategorieEserciziTableData
  >
  _ordered() {
    return select(categorieEserciziTable)
      ..orderBy([(t) => OrderingTerm.asc(t.ordineVisualizzazione)]);
  }

  Future<List<CategorieEserciziTableData>> getAll() => _ordered().get();

  Stream<List<CategorieEserciziTableData>> watchAll() => _ordered().watch();

  Future<CategorieEserciziTableData?> getById(int id) => (select(
    categorieEserciziTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<CategorieEserciziTableData?> getByCode(String code) => (select(
    categorieEserciziTable,
  )..where((t) => t.codice.equals(code))).getSingleOrNull();
}
