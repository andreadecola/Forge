import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/attrezzature_esercizi_table.dart';
import '../tables/attrezzature_table.dart';

part 'attrezzature_dao.g.dart';

@DriftAccessor(tables: [AttrezzatureTable, AttrezzatureEserciziTable])
class AttrezzatureDao extends DatabaseAccessor<AppDatabase>
    with _$AttrezzatureDaoMixin {
  AttrezzatureDao(super.db);

  Future<List<AttrezzatureTableData>> getAll() =>
      select(attrezzatureTable).get();

  Stream<List<AttrezzatureTableData>> watchAll() =>
      select(attrezzatureTable).watch();

  Future<AttrezzatureTableData?> getById(int id) => (select(
    attrezzatureTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<AttrezzatureTableData?> getByCode(String code) => (select(
    attrezzatureTable,
  )..where((t) => t.codice.equals(code))).getSingleOrNull();

  /// Tutte le attrezzature associate all'esercizio (obbligatorie e non),
  /// con il flag di obbligatorietà preso dalla relazione.
  Future<List<({AttrezzatureTableData equipment, bool required})>>
  getEquipmentForExercise(int exerciseId) async {
    final query = select(attrezzatureTable).join([
      innerJoin(
        attrezzatureEserciziTable,
        attrezzatureEserciziTable.idAttrezzatura.equalsExp(
          attrezzatureTable.id,
        ),
      ),
    ])..where(attrezzatureEserciziTable.idEsercizio.equals(exerciseId));
    final rows = await query.get();
    return rows
        .map(
          (row) => (
            equipment: row.readTable(attrezzatureTable),
            required: row.readTable(attrezzatureEserciziTable).obbligatoria,
          ),
        )
        .toList();
  }

  /// Tutti i link esercizio↔attrezzatura del catalogo, con codice master e
  /// flag di obbligatorietà. Una sola query per costruire lato repository la
  /// mappa esercizio → attrezzature richieste (evita N+1).
  Future<List<({int exerciseId, String masterCode, bool required})>>
  getAllExerciseEquipmentLinks() {
    final query = select(attrezzatureEserciziTable).join([
      innerJoin(
        attrezzatureTable,
        attrezzatureTable.id.equalsExp(
          attrezzatureEserciziTable.idAttrezzatura,
        ),
      ),
    ]);
    return query
        .map(
          (row) => (
            exerciseId: row.readTable(attrezzatureEserciziTable).idEsercizio,
            masterCode: row.readTable(attrezzatureTable).codice,
            required: row.readTable(attrezzatureEserciziTable).obbligatoria,
          ),
        )
        .get();
  }

  Future<List<AttrezzatureTableData>> getRequiredEquipmentForExercise(
    int exerciseId,
  ) {
    final query =
        select(attrezzatureTable).join([
          innerJoin(
            attrezzatureEserciziTable,
            attrezzatureEserciziTable.idAttrezzatura.equalsExp(
              attrezzatureTable.id,
            ),
          ),
        ])..where(
          attrezzatureEserciziTable.idEsercizio.equals(exerciseId) &
              attrezzatureEserciziTable.obbligatoria.equals(true),
        );
    return query.map((row) => row.readTable(attrezzatureTable)).get();
  }
}
