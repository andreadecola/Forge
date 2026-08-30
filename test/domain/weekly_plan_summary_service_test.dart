import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/planned_activity.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/services/weekly_plan_summary_service.dart';
import 'package:forge/domain/use_cases/planned_activity_session_lookup.dart';

/// Test di [WeeklyPlanSummaryService] (Milestone 8.7): puro e
/// deterministico — nessun DB, nessun I/O. Le sessioni collegate sono già
/// risolte a monte (vedi `WeeklyPlanSummaryBuilder` per l'orchestrazione
/// reale con repository).
void main() {
  const service = WeeklyPlanSummaryService();
  final today = DateTime(2026, 9, 9); // mercoledì

  PlannedActivity activity({
    DateTime? scheduledDate,
    PlannedActivityType type = PlannedActivityType.recovery,
    PlannedActivityStatus status = PlannedActivityStatus.planned,
  }) {
    return PlannedActivity(
      profileId: 1,
      scheduledDate: scheduledDate ?? today,
      type: type,
      status: status,
      origin: PlannedActivityOrigin.user,
    );
  }

  PlannedActivityWithSessionState entry(
    PlannedActivity activity, {
    LinkedSessionState sessionState = LinkedSessionState.none,
  }) => (activity: activity, sessionState: sessionState);

  test('nessuna attività -> summary vuoto, nessuna percentuale', () {
    final summary = service.summarize(entries: const [], today: today);
    expect(summary.total, 0);
    expect(summary.matureTotal, 0);
    expect(summary.matureCompletionRate, isNull);
  });

  test('settimana passata, tutte completate -> matureCompletionRate 1.0', () {
    final entries = List.generate(
      3,
      (_) => entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          type: PlannedActivityType.workout,
        ),
        sessionState: LinkedSessionState.completed,
      ),
    );
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.total, 3);
    expect(summary.completed, 3);
    expect(summary.matureTotal, 3);
    expect(summary.matureCompleted, 3);
    expect(summary.matureCompletionRate, 1.0);
  });

  test('settimana passata, nessuna completata -> matureCompletionRate 0.0', () {
    final entries = List.generate(
      2,
      (_) => entry(activity(scheduledDate: DateTime(2026, 9, 7))),
    );
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.matureCompletionRate, 0.0);
  });

  test('mix: completate + skipped + postponed + planned, tutte mature', () {
    final entries = [
      entry(
        activity(scheduledDate: DateTime(2026, 9, 7)),
        sessionState: LinkedSessionState.completed,
      ),
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          status: PlannedActivityStatus.skipped,
        ),
      ),
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          status: PlannedActivityStatus.postponed,
        ),
      ),
      entry(activity(scheduledDate: DateTime(2026, 9, 7))),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.total, 4);
    expect(summary.completed, 1);
    expect(summary.skipped, 1);
    expect(summary.postponed, 1);
    expect(summary.plannedRemaining, 1);
    expect(summary.matureTotal, 4);
    expect(summary.matureCompleted, 1);
    expect(summary.matureCompletionRate, 0.25);
  });

  test('sessione attiva -> non completata, non saltata/rinviata/planned', () {
    final entries = [
      entry(
        activity(scheduledDate: DateTime(2026, 9, 7)),
        sessionState: LinkedSessionState.active,
      ),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.active, 1);
    expect(summary.completed, 0);
    expect(summary.skipped, 0);
    expect(summary.postponed, 0);
    expect(summary.plannedRemaining, 0);
    // Matura ma non completata: non incrementa matureCompleted.
    expect(summary.matureTotal, 1);
    expect(summary.matureCompleted, 0);
  });

  test('sessione abortita (derivata none) -> PLANNED conta come da fare, mai '
      'completata', () {
    final entries = [entry(activity(scheduledDate: DateTime(2026, 9, 7)))];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.completed, 0);
    expect(summary.plannedRemaining, 1);
  });

  test('settimana futura: nessuna attività è matura, nessuna percentuale', () {
    final entries = [
      entry(activity(scheduledDate: DateTime(2026, 9, 14))),
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 15),
          type: PlannedActivityType.workout,
        ),
      ),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.matureTotal, 0);
    expect(summary.matureCompletionRate, isNull);
    expect(summary.total, 2);
  });

  test('settimana corrente parziale: le attività future non abbassano la '
      'percentuale matura', () {
    final entries = [
      // Lunedì (già passato rispetto a mercoledì 9/9): completata.
      entry(
        activity(scheduledDate: DateTime(2026, 9, 7)),
        sessionState: LinkedSessionState.completed,
      ),
      // Giovedì (futuro): ancora pianificata, MAI trattata come mancata.
      entry(activity(scheduledDate: DateTime(2026, 9, 10))),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.total, 2);
    expect(summary.matureTotal, 1);
    expect(summary.matureCompleted, 1);
    expect(summary.matureCompletionRate, 1.0);
  });

  test('RECOVERY pianificata non viene mai auto-completata', () {
    final entries = [
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          type: PlannedActivityType.recovery,
        ),
      ),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.recoveryCount, 1);
    expect(summary.completed, 0);
    expect(summary.plannedRemaining, 1);
  });

  test('POSTPONED con data originale passata conta comunque come matura', () {
    final entries = [
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          status: PlannedActivityStatus.postponed,
        ),
      ),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.matureTotal, 1);
    expect(summary.postponed, 1);
    expect(summary.matureCompleted, 0);
  });

  test('breakdown per tipo riflette il tipo attuale', () {
    final entries = [
      entry(activity(type: PlannedActivityType.workout)),
      entry(activity(type: PlannedActivityType.workout)),
      entry(activity(type: PlannedActivityType.walk)),
      entry(activity(type: PlannedActivityType.recovery)),
    ];
    final summary = service.summarize(entries: entries, today: today);
    expect(summary.workoutCount, 2);
    expect(summary.walkCount, 1);
    expect(summary.recoveryCount, 1);
  });

  test('order-independence: risultato identico con input mescolato', () {
    final entries = [
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          type: PlannedActivityType.workout,
        ),
        sessionState: LinkedSessionState.completed,
      ),
      entry(
        activity(
          scheduledDate: DateTime(2026, 9, 7),
          status: PlannedActivityStatus.skipped,
        ),
      ),
      entry(activity(scheduledDate: DateTime(2026, 9, 10))),
      entry(
        activity(scheduledDate: DateTime(2026, 9, 7)),
        sessionState: LinkedSessionState.active,
      ),
    ];
    final reversed = entries.reversed.toList();

    final summaryA = service.summarize(entries: entries, today: today);
    final summaryB = service.summarize(entries: reversed, today: today);

    expect(summaryB.total, summaryA.total);
    expect(summaryB.completed, summaryA.completed);
    expect(summaryB.active, summaryA.active);
    expect(summaryB.skipped, summaryA.skipped);
    expect(summaryB.postponed, summaryA.postponed);
    expect(summaryB.plannedRemaining, summaryA.plannedRemaining);
    expect(summaryB.matureTotal, summaryA.matureTotal);
    expect(summaryB.matureCompleted, summaryA.matureCompleted);
  });
}
