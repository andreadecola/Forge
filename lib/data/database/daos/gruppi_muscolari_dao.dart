import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/esercizi_gruppi_muscolari_table.dart';
import '../tables/gruppi_muscolari_table.dart';

part 'gruppi_muscolari_dao.g.dart';

@DriftAccessor(tables: [GruppiMuscolariTable, EserciziGruppiMuscolariTable])
class GruppiMuscolariDao extends DatabaseAccessor<AppDatabase>
    with _$GruppiMuscolariDaoMixin {
  GruppiMuscolariDao(super.db);

  Future<List<GruppiMuscolariTableData>> getAll() =>
      select(gruppiMuscolariTable).get();

  Future<GruppiMuscolariTableData?> getById(int id) => (select(
    gruppiMuscolariTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<GruppiMuscolariTableData?> getByCode(String code) => (select(
    gruppiMuscolariTable,
  )..where((t) => t.codice.equals(code))).getSingleOrNull();

  Future<List<GruppiMuscolariTableData>> getPrimaryMusclesForExercise(
    int exerciseId,
  ) => _musclesForExercise(exerciseId, 'PRIMARIO');

  Future<List<GruppiMuscolariTableData>> getSecondaryMusclesForExercise(
    int exerciseId,
  ) => _musclesForExercise(exerciseId, 'SECONDARIO');

  Future<List<GruppiMuscolariTableData>> _musclesForExercise(
    int exerciseId,
    String role,
  ) {
    final query =
        select(gruppiMuscolariTable).join([
          innerJoin(
            eserciziGruppiMuscolariTable,
            eserciziGruppiMuscolariTable.idGruppoMuscolare.equalsExp(
              gruppiMuscolariTable.id,
            ),
          ),
        ])..where(
          eserciziGruppiMuscolariTable.idEsercizio.equals(exerciseId) &
              eserciziGruppiMuscolariTable.tipoCoinvolgimento.equals(role),
        );
    return query.map((row) => row.readTable(gruppiMuscolariTable)).get();
  }
}
