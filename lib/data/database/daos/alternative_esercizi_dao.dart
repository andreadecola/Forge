import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/alternative_esercizi_table.dart';
import '../tables/esercizi_table.dart';

part 'alternative_esercizi_dao.g.dart';

/// Coppia (riga alternativa, esercizio alternativo) risolta in un'unica query.
typedef AlternativeWithTarget = ({
  AlternativeEserciziTableData alternative,
  EserciziTableData target,
});

@DriftAccessor(tables: [AlternativeEserciziTable, EserciziTable])
class AlternativeEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$AlternativeEserciziDaoMixin {
  AlternativeEserciziDao(super.db);

  Future<List<AlternativeWithTarget>> getAlternatives(int exerciseId) {
    final query =
        select(alternativeEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(
                alternativeEserciziTable.idEsercizioAlternativo,
              ),
            ),
          ])
          ..where(alternativeEserciziTable.idEsercizio.equals(exerciseId))
          ..orderBy([OrderingTerm.asc(alternativeEserciziTable.priorita)]);
    return query.map(_mapRow).get();
  }

  Future<List<AlternativeWithTarget>> getAlternativesByReason(
    int exerciseId,
    String reason,
  ) {
    final query =
        select(alternativeEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(
                alternativeEserciziTable.idEsercizioAlternativo,
              ),
            ),
          ])
          ..where(
            alternativeEserciziTable.idEsercizio.equals(exerciseId) &
                alternativeEserciziTable.codiceMotivo.equals(reason),
          )
          ..orderBy([OrderingTerm.asc(alternativeEserciziTable.priorita)]);
    return query.map(_mapRow).get();
  }

  AlternativeWithTarget _mapRow(TypedResult row) => (
    alternative: row.readTable(alternativeEserciziTable),
    target: row.readTable(eserciziTable),
  );
}
