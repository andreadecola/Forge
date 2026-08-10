import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/esercizi_table.dart';
import '../tables/progressioni_esercizi_table.dart';

part 'progressioni_esercizi_dao.g.dart';

/// Coppia (riga progressione, esercizio target) risolta in un'unica query.
typedef ProgressionWithTarget = ({
  ProgressioniEserciziTableData progression,
  EserciziTableData target,
});

@DriftAccessor(tables: [ProgressioniEserciziTable, EserciziTable])
class ProgressioniEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressioniEserciziDaoMixin {
  ProgressioniEserciziDao(super.db);

  /// Progressioni in avanti: esercizi successivi a [exerciseId].
  /// L'esercizio target è quello puntato da `id_esercizio_successivo`.
  Future<List<ProgressionWithTarget>> getProgressions(int exerciseId) {
    final query =
        select(progressioniEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(
                progressioniEserciziTable.idEsercizioSuccessivo,
              ),
            ),
          ])
          ..where(progressioniEserciziTable.idEsercizio.equals(exerciseId))
          ..orderBy([OrderingTerm.asc(progressioniEserciziTable.priorita)]);
    return query.map(_mapRow).get();
  }

  /// Progressione principale (priorità più bassa), se esiste.
  Future<ProgressionWithTarget?> getPrimaryProgression(int exerciseId) async {
    final all = await getProgressions(exerciseId);
    return all.isEmpty ? null : all.first;
  }

  /// Regressioni: query inversa. Sono le righe in cui [exerciseId] compare
  /// come `id_esercizio_successivo`; l'esercizio target (variante precedente)
  /// è quello puntato da `id_esercizio`.
  Future<List<ProgressionWithTarget>> getRegressions(int exerciseId) {
    final query =
        select(progressioniEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(progressioniEserciziTable.idEsercizio),
            ),
          ])
          ..where(
            progressioniEserciziTable.idEsercizioSuccessivo.equals(exerciseId),
          )
          ..orderBy([OrderingTerm.asc(progressioniEserciziTable.priorita)]);
    return query.map(_mapRow).get();
  }

  /// Regressione principale (priorità più bassa), se esiste.
  Future<ProgressionWithTarget?> getRegression(int exerciseId) async {
    final all = await getRegressions(exerciseId);
    return all.isEmpty ? null : all.first;
  }

  ProgressionWithTarget _mapRow(TypedResult row) => (
    progression: row.readTable(progressioniEserciziTable),
    target: row.readTable(eserciziTable),
  );
}
