import '../entities/planned_activity.dart';
import '../entities/planned_activity_enums.dart';
import '../entities/weekly_plan_summary.dart';
import '../use_cases/planned_activity_session_lookup.dart';

/// Un'attività pianificata con lo stato reale della sua sessione collegata
/// già risolto (Milestone 8.7): l'I/O (interrogare
/// `WorkoutSessionRepository`/`WalkingSessionRepository`) resta fuori da
/// questo file — vedi `WeeklyPlanSummaryBuilder`
/// (`lib/features/weekly_plan/application/`) per l'orchestrazione.
typedef PlannedActivityWithSessionState = ({
  PlannedActivity activity,
  LinkedSessionState sessionState,
});

/// Calcola [WeeklyPlanSummary] da un elenco di attività già risolte
/// (Milestone 8.7, sezione 26/27): puro e deterministico — nessun I/O,
/// nessun side effect, stesso risultato indipendentemente dall'ordine di
/// [entries] (sezione 29).
///
/// **Non deduce nulla di nuovo**: legge solo fatti già persistiti/derivati
/// (`PlannedActivity.status`, stato reale della sessione collegata) — non
/// crea né muta mai `PlannedActivity`/`WorkoutSession`/`WalkingSession`
/// (sezione 3).
class WeeklyPlanSummaryService {
  const WeeklyPlanSummaryService();

  WeeklyPlanSummary summarize({
    required List<PlannedActivityWithSessionState> entries,
    required DateTime today,
  }) {
    var completed = 0;
    var active = 0;
    var skipped = 0;
    var postponed = 0;
    var plannedRemaining = 0;
    var workoutCount = 0;
    var walkCount = 0;
    var recoveryCount = 0;
    var matureTotal = 0;
    var matureCompleted = 0;

    for (final entry in entries) {
      final activity = entry.activity;
      switch (activity.type) {
        case PlannedActivityType.workout:
          workoutCount++;
        case PlannedActivityType.walk:
          walkCount++;
        case PlannedActivityType.recovery:
          recoveryCount++;
      }

      // "Matura" (sezione 39-44): la data pianificata (non necessariamente
      // la data originale — M8.6 non conserva uno storico degli
      // spostamenti, sezione 6) è già trascorsa o è oggi. Una POSTPONED
      // conserva la sua `scheduledDate` originale (M8.6): se quella data è
      // già passata, l'attività è comunque "matura" — rinviata, non
      // completata (sezione 44).
      final isMature = !activity.scheduledDate.isAfter(today);
      if (isMature) matureTotal++;

      if (entry.sessionState == LinkedSessionState.completed) {
        completed++;
        if (isMature) matureCompleted++;
        continue;
      }
      if (entry.sessionState == LinkedSessionState.active) {
        active++;
        continue;
      }
      switch (activity.status) {
        case PlannedActivityStatus.skipped:
          skipped++;
        case PlannedActivityStatus.postponed:
          postponed++;
        case PlannedActivityStatus.planned:
          plannedRemaining++;
      }
    }

    return WeeklyPlanSummary(
      total: entries.length,
      completed: completed,
      active: active,
      skipped: skipped,
      postponed: postponed,
      plannedRemaining: plannedRemaining,
      workoutCount: workoutCount,
      walkCount: walkCount,
      recoveryCount: recoveryCount,
      matureTotal: matureTotal,
      matureCompleted: matureCompleted,
    );
  }
}
