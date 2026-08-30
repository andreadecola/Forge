import '../../../domain/entities/planned_activity.dart';
import '../../../domain/entities/weekly_plan_summary.dart';
import '../../../domain/repositories/walking_session_repository.dart';
import '../../../domain/repositories/workout_session_repository.dart';
import '../../../domain/services/weekly_plan_summary_service.dart';
import '../../../domain/use_cases/planned_activity_session_lookup.dart';

/// Risolve lo stato reale della sessione collegata a [activity]. Iniettato
/// (Milestone 8.7 patch) invece di dipendere direttamente dai repository:
/// permette a [WeeklyPlanSummaryBuilder] di restare invariato sia quando
/// la risoluzione è una lettura one-shot (repository diretti, usato dai
/// test) sia quando è reattiva (`ref.watch` su un provider Riverpod che
/// osserva la tabella sessione — usato da `weeklyPlanSummaryProvider`,
/// così il riepilogo si aggiorna da solo quando una sessione collegata
/// completa/abbandona, mentre la pagina resta montata).
typedef LinkedSessionStateResolver =
    Future<LinkedSessionState> Function(PlannedActivity activity);

/// Orchestra il calcolo del riepilogo settimanale (Milestone 8.7): unico
/// punto che risolve lo stato reale della sessione collegata per ogni
/// attività (tramite [LinkedSessionStateResolver]), poi delega il calcolo
/// puro a [WeeklyPlanSummaryService]. Nessuna sessione spontanea entra
/// qui: si parte sempre dalle `PlannedActivity` già pianificate, mai da
/// una query diretta sulle tabelle sessione (sezione 23/24).
///
/// Una risoluzione per attività con sessione collegata (non per ogni
/// attività della settimana): accettabile per il dataset di una singola
/// settimana (sezione 30/31) — nessun join/batch unico, dato che i
/// sessionId collegati sono eterogenei (Workout vs Walking) e il numero
/// di attività con un link è tipicamente basso (al più 7 giorni).
class WeeklyPlanSummaryBuilder {
  const WeeklyPlanSummaryBuilder(this._resolveSessionState);

  /// Costruisce un builder che risolve lo stato con una lettura one-shot
  /// sui repository (Milestone 8.6, `resolveLinkedSessionState`) — usato
  /// dove non è disponibile un `Ref` Riverpod (es. i test di dominio/dati
  /// con repository reali ma senza provider).
  factory WeeklyPlanSummaryBuilder.withRepositories(
    WorkoutSessionRepository workoutSessionRepository,
    WalkingSessionRepository walkingSessionRepository,
  ) {
    return WeeklyPlanSummaryBuilder(
      (activity) => resolveLinkedSessionState(
        activity,
        workoutSessionRepository,
        walkingSessionRepository,
      ),
    );
  }

  final LinkedSessionStateResolver _resolveSessionState;

  Future<WeeklyPlanSummary> build({
    required List<PlannedActivity> activities,
    required DateTime today,
  }) async {
    final entries = <PlannedActivityWithSessionState>[];
    for (final activity in activities) {
      final sessionState = await _resolveSessionState(activity);
      entries.add((activity: activity, sessionState: sessionState));
    }
    return const WeeklyPlanSummaryService().summarize(
      entries: entries,
      today: today,
    );
  }
}
