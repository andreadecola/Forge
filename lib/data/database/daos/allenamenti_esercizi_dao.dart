import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/allenamenti_esercizi_table.dart';
import '../tables/esercizi_table.dart';

part 'allenamenti_esercizi_dao.g.dart';

/// Riga di scheda con l'esercizio del catalogo già risolto in un'unica
/// query (stesso pattern di `ProgressionWithTarget` in
/// `progressioni_esercizi_dao.dart`).
typedef WorkoutExerciseWithExercise = ({
  AllenamentiEserciziTableData workoutExercise,
  EserciziTableData exercise,
});

@DriftAccessor(tables: [AllenamentiEserciziTable, EserciziTable])
class AllenamentiEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$AllenamentiEserciziDaoMixin {
  AllenamentiEserciziDao(super.db);

  /// Righe attive della scheda, sempre ordinate per `ordine` ascendente.
  Future<List<AllenamentiEserciziTableData>> getByWorkoutId(int workoutId) =>
      (select(allenamentiEserciziTable)
            ..where(
              (t) => t.idAllenamento.equals(workoutId) & t.attivo.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.ordine)]))
          .get();

  Stream<List<AllenamentiEserciziTableData>> watchByWorkoutId(int workoutId) =>
      (select(allenamentiEserciziTable)
            ..where(
              (t) => t.idAllenamento.equals(workoutId) & t.attivo.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.ordine)]))
          .watch();

  Future<AllenamentiEserciziTableData?> getById(int id) => (select(
    allenamentiEserciziTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Righe della scheda con l'esercizio del catalogo già risolto, ordinate
  /// per `ordine` ascendente: usata per costruire `WorkoutDetails` senza
  /// query N+1.
  Future<List<WorkoutExerciseWithExercise>> getByWorkoutIdWithExercise(
    int workoutId,
  ) {
    final query =
        select(allenamentiEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(allenamentiEserciziTable.idEsercizio),
            ),
          ])
          ..where(
            allenamentiEserciziTable.idAllenamento.equals(workoutId) &
                allenamentiEserciziTable.attivo.equals(true),
          )
          ..orderBy([OrderingTerm.asc(allenamentiEserciziTable.ordine)]);
    return query.map(_mapRow).get();
  }

  Future<int> insert(AllenamentiEserciziTableCompanion entry) =>
      into(allenamentiEserciziTable).insert(entry);

  /// Rinominato rispetto al verbo "update" per non collidere con il metodo
  /// generico [DatabaseAccessor.update] (vedi `AllenamentiDao.updateWorkout`).
  Future<bool> updateWorkoutExercise(AllenamentiEserciziTableCompanion entry) =>
      update(allenamentiEserciziTable).replace(entry);

  /// Aggiorna solo `ordine` (+ `dataModifica`), senza toccare il resto della
  /// riga: usato da reorder/normalizzazione, dove i valori serie/
  /// ripetizioni/durata/recupero/note non devono cambiare.
  Future<int> updateOrder({
    required int id,
    required int ordine,
    required DateTime dataModifica,
  }) => (update(allenamentiEserciziTable)..where((t) => t.id.equals(id))).write(
    AllenamentiEserciziTableCompanion(
      ordine: Value(ordine),
      dataModifica: Value(dataModifica),
    ),
  );

  Future<int> deleteById(int id) =>
      (delete(allenamentiEserciziTable)..where((t) => t.id.equals(id))).go();

  /// Usato dal cancellazione hard della scheda: il DB elimina già queste
  /// righe in CASCADE, ma il repository lo usa comunque per i test diretti
  /// sul DAO (nessuna dipendenza dal comportamento FK per verificarlo).
  Future<int> deleteByWorkoutId(int workoutId) => (delete(
    allenamentiEserciziTable,
  )..where((t) => t.idAllenamento.equals(workoutId))).go();

  /// Prossimo valore di `ordine` libero per la scheda (max attuale + 1, o 1
  /// se la scheda non ha ancora esercizi).
  Future<int> getNextOrder(int workoutId) async {
    final maxOrdine = allenamentiEserciziTable.ordine.max();
    final query = selectOnly(allenamentiEserciziTable)
      ..addColumns([maxOrdine])
      ..where(allenamentiEserciziTable.idAllenamento.equals(workoutId));
    final row = await query.getSingle();
    return (row.read(maxOrdine) ?? 0) + 1;
  }

  WorkoutExerciseWithExercise _mapRow(TypedResult row) => (
    workoutExercise: row.readTable(allenamentiEserciziTable),
    exercise: row.readTable(eserciziTable),
  );
}
