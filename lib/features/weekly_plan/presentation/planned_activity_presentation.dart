import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/walking_session_providers.dart';
import '../../../data/repositories/workout_providers.dart';
import '../../../data/repositories/workout_session_providers.dart';
import '../../../domain/entities/planned_activity.dart';
import '../../../domain/entities/planned_activity_enums.dart';
import '../../../domain/use_cases/planned_activity_session_lookup.dart'
    show
        LinkedSessionState,
        linkedStateFromWalkingStatus,
        linkedStateFromWorkoutStatus;
import 'planned_activity_labels.dart';

/// Stato "effettivo" di una `PlannedActivity` derivato dalla sessione reale
/// collegata (Milestone 8.5): mai persistito su [PlannedActivity.status]
/// (che resta sempre `planned`) — un'unica fonte di verità, la sessione
/// stessa, letta al momento di mostrarla. `none` copre sia "nessuna
/// sessione mai collegata" sia "collegata a una sessione ABORTED" (sezione
/// 12/36): in entrambi i casi l'attività torna disponibile per un nuovo
/// avvio.
enum PlannedActivitySessionState { none, active, completed }

/// Stato combinato mostrato in UI (Milestone 8.6, sezione 54): unisce lo
/// stato **persistito** ([PlannedActivity.status]) con lo stato
/// **derivato** dalla sessione reale ([PlannedActivitySessionState]) in
/// un'unica fonte per Today/WeeklyPlan — nessuno switch duplicato tra le
/// due pagine (sezione 55).
///
/// Priorità (sezione 53): la sessione reale COMPLETED è sempre la realtà
/// dominante, anche sopra un eventuale stato persistito incoerente. Un
/// `SKIPPED`/`POSTPONED` con sessione ancora `active` non dovrebbe mai
/// accadere (le azioni Salta/Rinvia lo impediscono all'origine), ma se
/// accadesse la realtà (sessione attiva) vince comunque sullo stato
/// persistito.
enum PlannedActivityDisplayState { none, active, completed, skipped, postponed }

/// Presentazione condivisa di una `PlannedActivity` (icona/etichetta/
/// sottotitolo), riusata sia da `WeeklyPlanPage` (Milestone 8.2) sia dalla
/// sezione "Oggi" della Dashboard (Milestone 8.3, sezione 27/28): stessa
/// rappresentazione del dato, contenitore e azioni restano decisi da chi
/// la usa — nessun secondo widget quasi identico.
abstract final class PlannedActivityPresentation {
  static IconData icon(PlannedActivityType type) => switch (type) {
    PlannedActivityType.workout => Icons.fitness_center,
    PlannedActivityType.walk => Icons.directions_walk,
    PlannedActivityType.recovery => Icons.self_improvement,
  };

  static String title(PlannedActivityType type) =>
      PlannedActivityLabels.type(type);

  /// Va chiamato dentro un `build()` (usa `ref.watch`): deriva dalla
  /// sessione reale collegata, se presente — mai da un campo persistito
  /// separato (sezione 45/46).
  ///
  /// Riusa `linkedStateFromWorkoutStatus`/`linkedStateFromWalkingStatus`
  /// (Milestone 8.6/8.8, `planned_activity_session_lookup.dart`) — la
  /// stessa mappatura status-sessione -> stato usata dal dominio per
  /// decidere se Salta/Rinvia sono consentiti, mai una seconda copia
  /// dello switch scritta qui (rischio di divergenza tra "stato usato per
  /// bloccare le azioni" e "stato mostrato in UI").
  static PlannedActivitySessionState sessionState(
    WidgetRef ref,
    PlannedActivity activity,
  ) {
    switch (activity.type) {
      case PlannedActivityType.workout:
        final sessionId = activity.workoutSessionId;
        if (sessionId == null) return PlannedActivitySessionState.none;
        final session = ref
            .watch(persistedWorkoutSessionProvider(sessionId))
            .valueOrNull;
        return _toPresentationState(
          linkedStateFromWorkoutStatus(session?.status),
        );
      case PlannedActivityType.walk:
        final sessionId = activity.walkingSessionId;
        if (sessionId == null) return PlannedActivitySessionState.none;
        final session = ref
            .watch(walkingSessionProvider(sessionId))
            .valueOrNull;
        return _toPresentationState(
          linkedStateFromWalkingStatus(session?.status),
        );
      case PlannedActivityType.recovery:
        return PlannedActivitySessionState.none;
    }
  }

  static PlannedActivitySessionState _toPresentationState(
    LinkedSessionState state,
  ) => switch (state) {
    LinkedSessionState.none => PlannedActivitySessionState.none,
    LinkedSessionState.active => PlannedActivitySessionState.active,
    LinkedSessionState.completed => PlannedActivitySessionState.completed,
  };

  /// Combina [sessionState] con [PlannedActivity.status] (Milestone 8.6,
  /// sezione 54): unica funzione usata sia da [subtitle] sia dai widget
  /// Today/WeeklyPlan per decidere quali azioni mostrare. Va chiamata
  /// dentro un `build()` (usa `ref.watch` tramite [sessionState]).
  static PlannedActivityDisplayState displayState(
    WidgetRef ref,
    PlannedActivity activity,
  ) {
    final session = sessionState(ref, activity);
    // La sessione reale (completata o attiva) è sempre la realtà dominante
    // (sezione 53), anche sopra un eventuale stato persistito incoerente.
    if (session == PlannedActivitySessionState.completed) {
      return PlannedActivityDisplayState.completed;
    }
    if (session == PlannedActivitySessionState.active) {
      return PlannedActivityDisplayState.active;
    }
    return switch (activity.status) {
      PlannedActivityStatus.skipped => PlannedActivityDisplayState.skipped,
      PlannedActivityStatus.postponed => PlannedActivityDisplayState.postponed,
      PlannedActivityStatus.planned => PlannedActivityDisplayState.none,
    };
  }

  /// Risolve il nome reale della scheda per un WORKOUT, la durata per una
  /// WALK, un testo neutro per RECOVERY. `workoutId == null` per un
  /// WORKOUT (dopo `ON DELETE SET NULL`, Milestone 8.1) è uno stato
  /// persistito legittimo, non un errore da far crashare. Aggiunge un
  /// suffisso neutro secondo [displayState] (sezione 33/57/51/52) — mai una
  /// motivazione o un giudizio.
  static Widget subtitle(WidgetRef ref, PlannedActivity activity) {
    final state = displayState(ref, activity);
    final suffix = switch (state) {
      PlannedActivityDisplayState.active => ' · In corso',
      PlannedActivityDisplayState.completed => ' · Completata',
      PlannedActivityDisplayState.skipped => ' · Saltata',
      PlannedActivityDisplayState.postponed => ' · Rinviata',
      PlannedActivityDisplayState.none => '',
    };
    switch (activity.type) {
      case PlannedActivityType.workout:
        if (activity.workoutId == null) {
          return const Text('Allenamento non più disponibile');
        }
        final workoutAsync = ref.watch(
          workoutByIdProvider(activity.workoutId!),
        );
        return workoutAsync.when(
          data: (workout) => Text(
            '${workout?.name ?? 'Allenamento non più disponibile'}$suffix',
          ),
          loading: () => const Text('Caricamento...'),
          error: (error, _) => const Text('Allenamento non disponibile'),
        );
      case PlannedActivityType.walk:
        final base = activity.plannedDurationMinutes == null
            ? 'Camminata pianificata'
            : '${activity.plannedDurationMinutes} min';
        return Text('$base$suffix');
      case PlannedActivityType.recovery:
        return Text('Giorno di recupero$suffix');
    }
  }
}
