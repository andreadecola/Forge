import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/set_performance.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

class ExercisePerformanceRecord {
  const ExercisePerformanceRecord({
    required this.sessionId,
    required this.startedAt,
    required this.sets,
    required this.completedSets,
  });
  final int sessionId;
  final DateTime startedAt;
  final List<SetPerformance> sets;
  final int completedSets;
}

/// Diario sullo snapshot della sessione: cancellare una scheda non lo elimina.
class PerformanceRepository {
  const PerformanceRepository(this.db);
  final AppDatabase db;

  Stream<List<SetPerformance>> watchSets(int sessionId, int order) =>
      (db.select(db.sessioniEserciziTable)..where(
            (t) => t.idSessione.equals(sessionId) & t.ordine.equals(order),
          ))
          .watchSingleOrNull()
          .map(
            (row) => row == null
                ? const []
                : SetPerformance.decodeList(
                    jsonDecode(row.prestazioni),
                    totalSets: row.serieTotali,
                  ),
          );

  Future<void> saveSet({
    required int sessionId,
    required int order,
    required SetPerformance performance,
  }) => db.transaction(() async {
    performance.validate();
    final row =
        await (db.select(db.sessioniEserciziTable)..where(
              (t) => t.idSessione.equals(sessionId) & t.ordine.equals(order),
            ))
            .getSingle();
    if (performance.setNumber > row.serieTotali) {
      throw const FormatException('La serie supera il totale previsto.');
    }
    if (row.durataSecondi != null && performance.repetitions != null ||
        row.durataSecondi == null && performance.durationSeconds != null) {
      throw const FormatException(
        'Usa secondi per gli esercizi a tempo e ripetizioni per gli altri.',
      );
    }
    final values =
        SetPerformance.decodeList(
            jsonDecode(row.prestazioni),
            totalSets: row.serieTotali,
          )
          ..removeWhere((p) => p.setNumber == performance.setNumber)
          ..add(performance)
          ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
    await (db.update(
      db.sessioniEserciziTable,
    )..where((t) => t.id.equals(row.id))).write(
      SessioniEserciziTableCompanion(
        prestazioni: Value(jsonEncode(values.map((p) => p.toJson()).toList())),
        dataModifica: Value(DateTime.now()),
      ),
    );
  });

  Stream<List<ExercisePerformanceRecord>> watchHistory(
    int profileId,
    int exerciseId,
  ) {
    final e = db.sessioniEserciziTable;
    final s = db.sessioniAllenamentoTable;
    final query =
        db.select(e).join([innerJoin(s, s.id.equalsExp(e.idSessione))])
          ..where(
            e.idEsercizio.equals(exerciseId) &
                s.idProfilo.equals(profileId) &
                s.stato.isIn(['COMPLETED', 'ABORTED']),
          )
          ..orderBy([
            OrderingTerm.desc(s.dataInizio),
            OrderingTerm.desc(s.id),
            OrderingTerm.asc(e.ordine),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          ExercisePerformanceRecord(
            sessionId: row.readTable(s).id,
            startedAt: row.readTable(s).dataInizio,
            completedSets: row.readTable(e).serieCompletate,
            sets: SetPerformance.decodeList(
              jsonDecode(row.readTable(e).prestazioni),
              totalSets: row.readTable(e).serieTotali,
            ),
          ),
      ],
    );
  }
}

final performanceRepositoryProvider = Provider(
  (ref) => PerformanceRepository(ref.watch(databaseProvider)),
);
final performedSetsProvider =
    StreamProvider.family<List<SetPerformance>, ({int sessionId, int order})>(
      (ref, args) => ref
          .watch(performanceRepositoryProvider)
          .watchSets(args.sessionId, args.order),
    );
final performanceHistoryProvider =
    StreamProvider.family<
      List<ExercisePerformanceRecord>,
      ({int profileId, int exerciseId})
    >(
      (ref, args) => ref
          .watch(performanceRepositoryProvider)
          .watchHistory(args.profileId, args.exerciseId),
    );
