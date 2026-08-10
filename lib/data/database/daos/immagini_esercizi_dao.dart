import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/immagini_esercizi_table.dart';

part 'immagini_esercizi_dao.g.dart';

@DriftAccessor(tables: [ImmaginiEserciziTable])
class ImmaginiEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$ImmaginiEserciziDaoMixin {
  ImmaginiEserciziDao(super.db);

  SimpleSelectStatement<$ImmaginiEserciziTableTable, ImmaginiEserciziTableData>
  _forExercise(int exerciseId) {
    return select(immaginiEserciziTable)
      ..where((t) => t.idEsercizio.equals(exerciseId))
      ..orderBy([(t) => OrderingTerm.asc(t.ordineVisualizzazione)]);
  }

  Future<List<ImmaginiEserciziTableData>> getForExercise(int exerciseId) =>
      _forExercise(exerciseId).get();

  Stream<List<ImmaginiEserciziTableData>> watchForExercise(int exerciseId) =>
      _forExercise(exerciseId).watch();
}
