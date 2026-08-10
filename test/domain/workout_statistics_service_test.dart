import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/workout_session_history_item.dart';
import 'package:forge/domain/entities/workout_session_persistence_status.dart';
import 'package:forge/domain/entities/workout_statistics_period.dart';
import 'package:forge/features/training_plan/application/workout_statistics_service.dart';

/// Test puri per [WorkoutStatisticsService] (Milestone 4.5.2, sezioni
/// 45-55): nessun database, `now` sempre passato esplicitamente —
/// deterministico, nessuna attesa reale.
void main() {
  const service = WorkoutStatisticsService();
  var nextId = 1;

  WorkoutSessionHistoryItem session({
    DateTime? startedAt,
    DateTime? finishedAt,
    WorkoutSessionPersistenceStatus status =
        WorkoutSessionPersistenceStatus.completed,
    int completedExercises = 1,
    int skippedExercises = 0,
    int totalSetsCompleted = 0,
    int totalPlannedSets = 0,
  }) {
    return WorkoutSessionHistoryItem(
      sessionId: nextId++,
      workoutId: 1,
      profileId: 1,
      workoutName: 'Scheda',
      status: status,
      startedAt: startedAt ?? DateTime(2026, 1, 1),
      finishedAt: finishedAt,
      totalExercises: completedExercises + skippedExercises,
      completedExercises: completedExercises,
      skippedExercises: skippedExercises,
      totalSetsCompleted: totalSetsCompleted,
      totalPlannedSets: totalPlannedSets,
    );
  }

  final now = DateTime(2026, 8, 10, 12);

  group('sezione 45 — nessuna sessione', () {
    test('tutte le metriche sono coerenti, nessuna divisione per zero', () {
      final stats = service.compute(
        sessions: const [],
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.totalSessions, 0);
      expect(stats.completedSessions, 0);
      expect(stats.abortedSessions, 0);
      expect(stats.completionRate, 0.0);
      expect(stats.totalSetsCompleted, 0);
      expect(stats.totalPlannedSets, 0);
      expect(stats.setCompletionRate, isNull);
      expect(stats.totalDuration, Duration.zero);
      expect(stats.averageDuration, isNull);
      expect(stats.activeDays, 0);
      expect(stats.averageSessionsPerWeek, 0.0);
      expect(stats.activity, isEmpty);
    });
  });

  group('sezione 46 — tasso di completamento', () {
    test('8 completed + 2 aborted su 10 -> 0.8', () {
      final sessions = [
        for (var i = 0; i < 8; i++)
          session(status: WorkoutSessionPersistenceStatus.completed),
        for (var i = 0; i < 2; i++)
          session(status: WorkoutSessionPersistenceStatus.aborted),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.totalSessions, 10);
      expect(stats.completedSessions, 8);
      expect(stats.abortedSessions, 2);
      expect(stats.completionRate, 0.8);
    });
  });

  group('sezione 47 — serie pianificate/completate', () {
    test('A: 10 pianificate/8 completate; B: 6/6 -> totale 16/14', () {
      final sessions = [
        session(totalPlannedSets: 10, totalSetsCompleted: 8),
        session(totalPlannedSets: 6, totalSetsCompleted: 6),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.totalPlannedSets, 16);
      expect(stats.totalSetsCompleted, 14);
      expect(stats.setCompletionRate, 14 / 16);
    });
  });

  group('sezione 48/54 — giorni attivi', () {
    test('3 sessioni, 2 nello stesso giorno -> activeDays = 2', () {
      final sessions = [
        session(startedAt: DateTime(2026, 8, 1, 9)),
        session(startedAt: DateTime(2026, 8, 1, 18)),
        session(startedAt: DateTime(2026, 8, 2, 9)),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.activeDays, 2);
    });
  });

  group('sezione 49/50 — durata', () {
    test('30 min + 60 min -> totale 90 min, media 45 min', () {
      final sessions = [
        session(
          startedAt: DateTime(2026, 8, 1, 9, 0),
          finishedAt: DateTime(2026, 8, 1, 9, 30),
        ),
        session(
          startedAt: DateTime(2026, 8, 2, 9, 0),
          finishedAt: DateTime(2026, 8, 2, 10, 0),
        ),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.totalDuration, const Duration(minutes: 90));
      expect(stats.averageDuration, const Duration(minutes: 45));
    });

    test(
      'una sessione senza finishedAt non entra nella media (sezione 50)',
      () {
        final sessions = [
          session(
            startedAt: DateTime(2026, 8, 1, 9, 0),
            finishedAt: DateTime(2026, 8, 1, 9, 30),
          ),
          session(
            startedAt: DateTime(2026, 8, 2, 9, 0),
            finishedAt: DateTime(2026, 8, 2, 10, 0),
          ),
          session(
            startedAt: DateTime(2026, 8, 3, 9, 0),
            finishedAt: null,
            status: WorkoutSessionPersistenceStatus.aborted,
          ),
        ];

        final stats = service.compute(
          sessions: sessions,
          period: WorkoutStatisticsPeriod.allTime,
          now: now,
        );

        expect(
          stats.totalSessions,
          3,
          reason: 'conta comunque per i conteggi sessione',
        );
        expect(stats.totalDuration, const Duration(minutes: 90));
        expect(stats.averageDuration, const Duration(minutes: 45));
      },
    );
  });

  group('sezione 51 — periodo 7 giorni', () {
    test('sessione 8 giorni fa esclusa, 6 giorni fa inclusa', () {
      final sessions = [
        session(startedAt: now.subtract(const Duration(days: 8))),
        session(startedAt: now.subtract(const Duration(days: 6))),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.last7Days,
        now: now,
      );

      expect(stats.totalSessions, 1);
    });
  });

  group('sezione 52 — periodo 30/90 giorni: boundary', () {
    test('30 giorni: 30 giorni fa dentro, 31 fuori', () {
      final sessions = [
        session(startedAt: now.subtract(const Duration(days: 31))),
        session(startedAt: now.subtract(const Duration(days: 29))),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.last30Days,
        now: now,
      );

      expect(stats.totalSessions, 1);
    });

    test('90 giorni: 90 giorni fa dentro, 91 fuori', () {
      final sessions = [
        session(startedAt: now.subtract(const Duration(days: 91))),
        session(startedAt: now.subtract(const Duration(days: 89))),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.last90Days,
        now: now,
      );

      expect(stats.totalSessions, 1);
    });
  });

  group('sezione 53 — Tutto', () {
    test('nessun filtro temporale: anche una sessione di anni fa conta', () {
      final sessions = [
        session(startedAt: DateTime(2020, 1, 1)),
        session(startedAt: now),
      ];

      final stats = service.compute(
        sessions: sessions,
        period: WorkoutStatisticsPeriod.allTime,
        now: now,
      );

      expect(stats.totalSessions, 2);
    });
  });

  group('sezione 36 — una sola sessione', () {
    test('tutte le formule restano valide con una sola sessione', () {
      final stats = service.compute(
        sessions: [
          session(
            startedAt: DateTime(2026, 8, 1, 9),
            finishedAt: DateTime(2026, 8, 1, 9, 40),
            totalPlannedSets: 10,
            totalSetsCompleted: 8,
          ),
        ],
        period: WorkoutStatisticsPeriod.allTime,
        now: DateTime(2026, 8, 1, 12),
      );

      expect(stats.totalSessions, 1);
      expect(stats.completionRate, 1.0);
      expect(stats.activeDays, 1);
      expect(stats.averageDuration, const Duration(minutes: 40));
      expect(stats.averageSessionsPerWeek, 7.0);
    });
  });

  group('sezione 55 — aggregazione activity points', () {
    test('7 giorni -> un punto per giorno, dal confine del periodo a oggi', () {
      final stats = service.compute(
        sessions: [session(startedAt: now.subtract(const Duration(days: 2)))],
        period: WorkoutStatisticsPeriod.last7Days,
        now: now,
      );

      expect(stats.activity, hasLength(7));
      expect(
        stats.activity.where((p) => p.sessionCount > 0).length,
        1,
        reason: 'un solo giorno con sessioni, gli altri sono zeri reali',
      );
    });

    test('30 giorni -> un punto per settimana', () {
      final stats = service.compute(
        sessions: [session(startedAt: now.subtract(const Duration(days: 5)))],
        period: WorkoutStatisticsPeriod.last30Days,
        now: now,
      );

      // Il periodo copre ~30 giorni di calendario -> 5 punti settimanali.
      expect(stats.activity.length, inInclusiveRange(4, 6));
      expect(stats.activity.fold<int>(0, (a, p) => a + p.sessionCount), 1);
    });

    test('Tutto -> un punto per mese, dalla prima sessione a oggi', () {
      final stats = service.compute(
        sessions: [
          session(startedAt: DateTime(2026, 5, 15)),
          session(startedAt: DateTime(2026, 8, 5)),
        ],
        period: WorkoutStatisticsPeriod.allTime,
        now: DateTime(2026, 8, 10),
      );

      // Maggio, giugno, luglio, agosto -> 4 mesi.
      expect(stats.activity, hasLength(4));
      expect(stats.activity.first.periodStart, DateTime(2026, 5, 1));
      expect(stats.activity.last.periodStart, DateTime(2026, 8, 1));
    });

    test('nessuna sessione -> nessun punto (niente barre finte)', () {
      final stats = service.compute(
        sessions: const [],
        period: WorkoutStatisticsPeriod.last7Days,
        now: now,
      );
      expect(stats.activity, isEmpty);
    });
  });
}
