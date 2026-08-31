import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/walking_session_providers.dart';
import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/planned_activity.dart';
import '../../../domain/entities/weekly_plan_summary.dart';
import '../../../domain/services/weekly_planning_date_service.dart';
import '../../../domain/use_cases/add_planned_activity.dart';
import '../../../domain/use_cases/delete_planned_activity.dart';
import '../../../domain/use_cases/link_walking_session.dart';
import '../../../domain/use_cases/link_workout_session.dart';
import '../../../domain/use_cases/planned_activity_session_lookup.dart';
import '../../../domain/use_cases/postpone_planned_activity.dart';
import '../../../domain/use_cases/restore_planned_activity.dart';
import '../../../domain/use_cases/skip_planned_activity.dart';
import '../../../domain/use_cases/update_planned_activity.dart';
import '../../notifications/application/notification_providers.dart';
import 'weekly_plan_generation_service.dart';
import 'weekly_plan_summary_builder.dart';

/// Attività pianificate della settimana che contiene [weekReference]
/// (Milestone 8.1, sezione 39): il provider calcola weekStart/weekEnd da
/// `WeeklyPlanningDateService`, il repository si limita a filtrare per
/// intervallo — nessun secondo provider "grezzo" da parametrizzare a mano
/// con weekStart/weekEnd espliciti.
final plannedActivitiesForWeekProvider =
    StreamProvider.family<
      List<PlannedActivity>,
      ({int profileId, DateTime weekReference})
    >((ref, args) {
      final weekStart = WeeklyPlanningDateService.weekStart(args.weekReference);
      final weekEnd = WeeklyPlanningDateService.weekEnd(args.weekReference);
      return ref
          .watch(plannedActivityRepositoryProvider)
          .watchForWeek(
            profileId: args.profileId,
            weekStart: weekStart,
            weekEnd: weekEnd,
          );
    });

/// Riepilogo derivato della settimana (Milestone 8.7): si ricalcola sia
/// quando [plannedActivitiesForWeekProvider] emette (aggiunta/modifica/
/// eliminazione/sposta/salta/rinvia/ripristina — scritture sulla tabella
/// `attivita_pianificate`) sia quando una sessione collegata cambia stato
/// (completa/abbandona — patch Milestone 8.7): il resolver qui sotto
/// osserva [persistedWorkoutSessionProvider]/[walkingSessionProvider] con
/// `ref.watch`, che sono `StreamProvider` (non più `FutureProvider`) da
/// questa patch — riemettono automaticamente a ogni cambio di riga sulle
/// tabelle sessione, senza alcun polling.
final weeklyPlanSummaryProvider =
    FutureProvider.family<
      WeeklyPlanSummary,
      ({int profileId, DateTime weekReference})
    >((ref, args) async {
      final activities = await ref.watch(
        plannedActivitiesForWeekProvider(args).future,
      );
      final today = WeeklyPlanningDateService.atMidnight(
        ref.watch(clockProvider).now(),
      );
      final builder = WeeklyPlanSummaryBuilder(
        (activity) => _resolveReactiveSessionState(ref, activity),
      );
      return builder.build(activities: activities, today: today);
    });

/// Resolver reattivo (Milestone 8.7 patch): a differenza di
/// `resolveLinkedSessionState` (lettura one-shot sui repository, usata da
/// Skip/Postpone/Delete), qui `ref.watch` sugli stessi provider di stato
/// sessione già usati da `PlannedActivityPresentation` per i badge "In
/// corso"/"Completata" — una sessione che completa/abbandona fa riemettere
/// quel provider, che a sua volta fa ricalcolare questo `FutureProvider`
/// genitore. Una lettura per attività con sessione collegata (non un
/// join/batch unico): il numero di sessioni collegate in una settimana è
/// tipicamente basso, e i sessionId sono eterogenei (Workout vs Walking) —
/// un batch unico non è banale e non è richiesto dal dataset piccolo.
Future<LinkedSessionState> _resolveReactiveSessionState(
  Ref ref,
  PlannedActivity activity,
) async {
  if (activity.workoutSessionId != null) {
    final session = await ref.watch(
      persistedWorkoutSessionProvider(activity.workoutSessionId!).future,
    );
    return linkedStateFromWorkoutStatus(session?.status);
  }
  if (activity.walkingSessionId != null) {
    final session = await ref.watch(
      walkingSessionProvider(activity.walkingSessionId!).future,
    );
    return linkedStateFromWalkingStatus(session?.status);
  }
  return LinkedSessionState.none;
}

/// Singola attività per id, `null` se non esiste (es. già eliminata).
final plannedActivityByIdProvider =
    FutureProvider.family<PlannedActivity?, int>((ref, id) {
      return ref.watch(plannedActivityRepositoryProvider).getById(id);
    });

/// Attività pianificate della data odierna, per la sezione "Oggi" della
/// Dashboard (Milestone 8.3, sezione 8/9/34). Riusa `watchForWeek` con
/// `weekStart == weekEnd == oggi` invece di introdurre un `watchForDate`
/// nel repository/DAO: nessuna nuova query, nessuna business logic
/// duplicata, e la Dashboard carica solo il giorno corrente — non l'intera
/// settimana filtrata poi lato client, che sarebbe meno efficiente per
/// questo caso d'uso specifico.
final todayPlannedActivitiesProvider =
    StreamProvider.family<List<PlannedActivity>, int>((ref, profileId) {
      final today = WeeklyPlanningDateService.atMidnight(
        ref.watch(clockProvider).now(),
      );
      return ref
          .watch(plannedActivityRepositoryProvider)
          .watchForWeek(profileId: profileId, weekStart: today, weekEnd: today);
    });

class PlannedActivityController {
  PlannedActivityController(this._ref);

  final Ref _ref;

  Future<int> addPlannedActivity(PlannedActivity activity) async {
    final id = await AddPlannedActivity(
      _ref.read(plannedActivityRepositoryProvider),
    )(activity);
    await _syncActivity(id);
    return id;
  }

  Future<void> updatePlannedActivity(PlannedActivity activity) async {
    await UpdatePlannedActivity(_ref.read(plannedActivityRepositoryProvider))(
      activity,
    );
    if (activity.id != null) await _syncActivity(activity.id!);
  }

  /// Sezione 28 (Milestone 8.5): rifiuta l'eliminazione se la sessione
  /// collegata è ancora attiva — vedi `DeletePlannedActivity`.
  Future<void> deletePlannedActivity(int id) async {
    await DeletePlannedActivity(
      _ref.read(plannedActivityRepositoryProvider),
      _ref.read(workoutSessionRepositoryProvider),
      _ref.read(walkingSessionRepositoryProvider),
    )(id);
    await _ref
        .read(plannedActivityReminderSyncServiceProvider)
        .cancelByActivityId(id);
  }

  /// Collega la `WorkoutSession` appena avviata a [activity] (Milestone
  /// 8.5): il chiamante passa l'id ottenuto direttamente da
  /// `WorkoutSessionController` dopo `startSession`, mai una query "ultima
  /// sessione".
  Future<void> linkWorkoutSession({
    required PlannedActivity activity,
    required int workoutSessionId,
  }) async {
    await LinkWorkoutSession(
      _ref.read(plannedActivityRepositoryProvider),
      _ref.read(workoutSessionRepositoryProvider),
    )(activity: activity, workoutSessionId: workoutSessionId);
    await _syncActivity(activity.id!);
  }

  /// Stesso principio per `WalkingSessionController.start`.
  Future<void> linkWalkingSession({
    required PlannedActivity activity,
    required int walkingSessionId,
  }) async {
    await LinkWalkingSession(
      _ref.read(plannedActivityRepositoryProvider),
      _ref.read(walkingSessionRepositoryProvider),
    )(activity: activity, walkingSessionId: walkingSessionId);
    await _syncActivity(activity.id!);
  }

  /// Azione esplicita "Salta" (Milestone 8.6): vedi `SkipPlannedActivity`.
  Future<void> skipPlannedActivity(int id) async {
    await SkipPlannedActivity(
      _ref.read(plannedActivityRepositoryProvider),
      _ref.read(workoutSessionRepositoryProvider),
      _ref.read(walkingSessionRepositoryProvider),
    )(id);
    await _syncActivity(id);
  }

  /// Azione esplicita "Rinvia" (Milestone 8.6): vedi
  /// `PostponePlannedActivity`.
  Future<void> postponePlannedActivity(int id) async {
    await PostponePlannedActivity(
      _ref.read(plannedActivityRepositoryProvider),
      _ref.read(workoutSessionRepositoryProvider),
      _ref.read(walkingSessionRepositoryProvider),
    )(id);
    await _syncActivity(id);
  }

  /// Azione esplicita "Ripristina nel piano" (Milestone 8.6): vedi
  /// `RestorePlannedActivity`.
  Future<void> restorePlannedActivity(int id) async {
    await RestorePlannedActivity(_ref.read(plannedActivityRepositoryProvider))(
      id,
    );
    await _syncActivity(id);
  }

  Future<void> _syncActivity(int id) async {
    try {
      await _ref
          .read(plannedActivityReminderSyncServiceProvider)
          .syncActivity(id);
    } on Object {
      // Notifications are a non-core projection. The M8 write has already
      // committed and must remain successful if the side effect fails.
    }
  }

  /// Azione esplicita "Sposta" (Milestone 8.6, sezione 16/31): riusa
  /// [updatePlannedActivity] con la sola `scheduledDate` cambiata — vedi il
  /// commento di `UpdatePlannedActivity` per il reset a `PLANNED` quando
  /// l'attività era `SKIPPED`/`POSTPONED`.
  Future<void> movePlannedActivity({
    required PlannedActivity activity,
    required DateTime newScheduledDate,
  }) {
    return updatePlannedActivity(
      activity.copyWith(scheduledDate: newScheduledDate),
    );
  }
}

final plannedActivityControllerProvider = Provider<PlannedActivityController>((
  ref,
) {
  return PlannedActivityController(ref);
});

/// Generazione automatica settimanale (Milestone 8.4): riusa il Forge
/// Engine (Milestone 5) e il repository di pianificazione esistenti, nessun
/// nuovo motore. Vedi `WeeklyPlanGenerationService` per le responsabilità.
final weeklyPlanGenerationServiceProvider =
    Provider<WeeklyPlanGenerationService>((ref) {
      return WeeklyPlanGenerationService(
        ref.watch(plannedActivityRepositoryProvider),
        ref.watch(generateAdaptedForgeWorkoutProvider),
        ref.watch(equipmentRepositoryProvider),
        ref.watch(clockProvider),
      );
    });
