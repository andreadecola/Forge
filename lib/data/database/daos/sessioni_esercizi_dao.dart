import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/esercizi_table.dart';
import '../tables/sessioni_esercizi_table.dart';

part 'sessioni_esercizi_dao.g.dart';

/// Riga snapshot con l'esercizio del catalogo già risolto (stesso pattern
/// di `WorkoutExerciseWithExercise` in `allenamenti_esercizi_dao.dart`):
/// usata dal dettaglio storico (Milestone 4.5.1), dove serve davvero il
/// nome dal catalogo — a differenza della lista storico, che mostra solo
/// conteggi aggregati.
typedef SessionExerciseWithExercise = ({
  SessioniEserciziTableData sessionExercise,
  EserciziTableData exercise,
});

@DriftAccessor(tables: [SessioniEserciziTable, EserciziTable])
class SessioniEserciziDao extends DatabaseAccessor<AppDatabase>
    with _$SessioniEserciziDaoMixin {
  SessioniEserciziDao(super.db);

  Future<List<SessioniEserciziTableData>> getBySessionId(int sessionId) =>
      (select(sessioniEserciziTable)
            ..where((t) => t.idSessione.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.ordine)]))
          .get();

  /// Righe di più sessioni in un colpo solo (Milestone 4.5.1): usata dallo
  /// storico per aggregare i conteggi completati/saltati di ogni sessione
  /// della lista senza una query per card (sezione 36 — "NO N+1").
  Future<List<SessioniEserciziTableData>> getBySessionIds(
    List<int> sessionIds,
  ) {
    if (sessionIds.isEmpty) return Future.value(const []);
    return (select(
      sessioniEserciziTable,
    )..where((t) => t.idSessione.isIn(sessionIds))).get();
  }

  /// Righe della sessione con l'esercizio del catalogo già risolto,
  /// ordinate per `ordine` ascendente: usate dal dettaglio storico
  /// (Milestone 4.5.1), senza query N+1.
  Future<List<SessionExerciseWithExercise>> getBySessionIdWithExercise(
    int sessionId,
  ) {
    final query =
        select(sessioniEserciziTable).join([
            innerJoin(
              eserciziTable,
              eserciziTable.id.equalsExp(sessioniEserciziTable.idEsercizio),
            ),
          ])
          ..where(sessioniEserciziTable.idSessione.equals(sessionId))
          ..orderBy([OrderingTerm.asc(sessioniEserciziTable.ordine)]);
    return query.map(_mapRow).get();
  }

  /// Usata per risolvere, dato l'id della riga scheda originale, quale
  /// riga snapshot della sessione aggiornare (sezione 9: identità tramite
  /// `WorkoutExercise.id`, mai `exerciseId`, perché lo stesso esercizio può
  /// comparire più volte nella stessa scheda).
  Future<SessioniEserciziTableData?> getBySessionAndWorkoutExercise(
    int sessionId,
    int workoutExerciseId,
  ) =>
      (select(sessioniEserciziTable)..where(
            (t) =>
                t.idSessione.equals(sessionId) &
                t.idAllenamentoEsercizio.equals(workoutExerciseId),
          ))
          .getSingleOrNull();

  Future<int> insert(SessioniEserciziTableCompanion entry) =>
      into(sessioniEserciziTable).insert(entry);

  /// Stesso motivo di `SessioniAllenamentoDao.updateState`: scrittura
  /// parziale, non un `replace()` a riga intera.
  Future<int> updateProgress(int id, SessioniEserciziTableCompanion changes) =>
      (update(
        sessioniEserciziTable,
      )..where((t) => t.id.equals(id))).write(changes);

  SessionExerciseWithExercise _mapRow(TypedResult row) => (
    sessionExercise: row.readTable(sessioniEserciziTable),
    exercise: row.readTable(eserciziTable),
  );
}
