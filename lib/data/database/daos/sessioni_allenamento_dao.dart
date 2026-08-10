import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sessioni_allenamento_table.dart';

part 'sessioni_allenamento_dao.g.dart';

/// Solo accesso ai dati: nessuna logica di business (derivazione fase,
/// decisione su cosa persistere quando) qui dentro — quella vive nel
/// repository/controller (sezione 18).
@DriftAccessor(tables: [SessioniAllenamentoTable])
class SessioniAllenamentoDao extends DatabaseAccessor<AppDatabase>
    with _$SessioniAllenamentoDaoMixin {
  SessioniAllenamentoDao(super.db);

  /// Sessione ancora in corso (IN_PROGRESS o PAUSED) del profilo, se
  /// esiste. Il repository garantisce che ce ne sia al più una (sezione
  /// 20): qui si legge semplicemente la prima trovata.
  Future<SessioniAllenamentoTableData?> getActiveByProfile(int profileId) =>
      (select(sessioniAllenamentoTable)
            ..where(
              (t) =>
                  t.idProfilo.equals(profileId) &
                  t.stato.isIn(const ['IN_PROGRESS', 'PAUSED']),
            )
            ..limit(1))
          .getSingleOrNull();

  Future<SessioniAllenamentoTableData?> getById(int id) => (select(
    sessioniAllenamentoTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Sessioni concluse (COMPLETED/ABORTED) del profilo, più recenti prima
  /// (Milestone 4.5.1): storico. Le sessioni IN_PROGRESS/PAUSED non sono
  /// incluse (sezione 8), sono già gestite come sessione attiva.
  ///
  /// [since], se presente, limita alle sessioni con `dataInizio >= since`
  /// (Milestone 4.5.2: query limitata al periodo per le statistiche).
  Future<List<SessioniAllenamentoTableData>> getHistoryByProfile(
    int profileId, {
    DateTime? since,
  }) =>
      (select(sessioniAllenamentoTable)
            ..where((t) => _historyPredicate(t, profileId, since))
            ..orderBy([(t) => OrderingTerm.desc(t.dataInizio)]))
          .get();

  Stream<List<SessioniAllenamentoTableData>> watchHistoryByProfile(
    int profileId, {
    DateTime? since,
  }) =>
      (select(sessioniAllenamentoTable)
            ..where((t) => _historyPredicate(t, profileId, since))
            ..orderBy([(t) => OrderingTerm.desc(t.dataInizio)]))
          .watch();

  Expression<bool> _historyPredicate(
    $SessioniAllenamentoTableTable t,
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

  Future<int> create(SessioniAllenamentoTableCompanion session) =>
      into(sessioniAllenamentoTable).insert(session);

  /// Scrive solo i campi presenti in [changes] (`Value.absent()` per gli
  /// altri lascia il valore già persistito invariato) — permette al
  /// repository di aggiornare solo ciò che è davvero cambiato in ogni
  /// evento, senza dover fornire una riga completa come richiederebbe
  /// [DatabaseAccessor.update]`.replace()`.
  Future<int> updateState(int id, SessioniAllenamentoTableCompanion changes) =>
      (update(
        sessioniAllenamentoTable,
      )..where((t) => t.id.equals(id))).write(changes);
}
