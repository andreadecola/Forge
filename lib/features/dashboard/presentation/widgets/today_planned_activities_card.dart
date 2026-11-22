import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../data/repositories/forge_providers.dart' show clockProvider;
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/planned_activity.dart';
import '../../../../domain/entities/planned_activity_enums.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../../../../domain/services/weekly_planning_date_service.dart';
import '../../../training_plan/application/workout_session_controller.dart';
import '../../../training_plan/application/workout_session_restore_providers.dart';
import '../../../training_plan/presentation/widgets/active_workout_dialog.dart';
import '../../../walking/application/walking_session_controller.dart';
import '../../../weekly_plan/application/planned_activity_providers.dart';
import '../../../weekly_plan/presentation/planned_activity_presentation.dart';

/// Sezione "Oggi" della Dashboard (Milestone 8.3): risponde a "cosa devo
/// fare oggi?" mostrando le `PlannedActivity` della data corrente. Usa il
/// piano solo per MOSTRARE cosa era previsto — le azioni "Avvia"/"Riprendi"
/// riusano per intero i flussi reali di avvio M4/M6 (nessuna nuova session
/// factory) e collegano esplicitamente la sessione appena creata al piano
/// (Milestone 8.5, sezione 16-19) — nessun matching implicito, nessuna
/// query "ultima sessione".
class TodayPlannedActivitiesCard extends ConsumerWidget {
  const TodayPlannedActivitiesCard({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(
      todayPlannedActivitiesProvider(profileId),
    );
    final today = WeeklyPlanningDateService.atMidnight(
      ref.watch(clockProvider).now(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Oggi — ${formatItalianDate(today)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  tooltip: 'Apri piano settimanale',
                  onPressed: () => context.push(AppRoutes.weeklyPlan),
                ),
              ],
            ),
            const SizedBox(height: 4),
            activitiesAsync.when(
              data: (activities) => activities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Oggi non hai attività in programma. Puoi organizzare i prossimi giorni o scegliere una scheda qui sotto.',
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(AppRoutes.weeklyPlan),
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('Organizza la settimana'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        for (final activity in activities)
                          PlannedActivityActionTile(
                            profileId: profileId,
                            activity: activity,
                            prominent: true,
                          ),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Impossibile caricare il piano di oggi.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlannedActivityActionTile extends ConsumerStatefulWidget {
  const PlannedActivityActionTile({
    super.key,
    required this.profileId,
    required this.activity,
    this.prominent = false,
  });

  final int profileId;
  final PlannedActivity activity;
  final bool prominent;

  @override
  ConsumerState<PlannedActivityActionTile> createState() =>
      _TodayActivityTileState();
}

class _TodayActivityTileState extends ConsumerState<PlannedActivityActionTile> {
  bool _busy = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Stesso dialog di `WorkoutDetailPage._showActiveSessionDialog`
  /// (Milestone 4.4.1): il controller resta l'unica fonte della guardia,
  /// qui si replica solo la reazione UI, come ogni altra pagina di Forge fa
  /// per i propri dialog di conferma.
  Future<void> _showActiveWorkoutSessionDialog() async {
    await showActiveWorkoutSessionDialog(context, ref);
  }

  Future<void> _startWorkout() async {
    if (_busy) return;
    setState(() => _busy = true);
    // `_busy` copre solo il lavoro async di risoluzione/avvio: il dialog
    // "sessione già attiva" (sotto) attende l'utente per un tempo
    // indeterminato, e non deve tenere lo spinner "Avvia" bloccato per
    // tutta la sua durata (rilevato con un test: altrimenti l'animazione
    // indeterminata del pulsante non si ferma mai finché il dialog resta
    // aperto, e `pumpAndSettle` non termina mai).
    var started = false;
    String? errorMessage;
    int? sessionId;
    try {
      final workoutId = widget.activity.workoutId!;
      final details = await ref.read(workoutDetailsProvider(workoutId).future);
      if (details == null) {
        errorMessage = 'Questo allenamento non è più disponibile.';
      } else if (details.workout.status != WorkoutDefinitionStatus.ready) {
        errorMessage = 'Solo una scheda pronta può essere avviata.';
      } else if (details.exercises.isEmpty) {
        errorMessage = 'Aggiungi almeno un esercizio prima di iniziare.';
      } else {
        started = await ref
            .read(workoutSessionControllerProvider.notifier)
            .startSession(details);
        if (started) {
          sessionId = ref.read(workoutSessionControllerProvider)!.sessionId;
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }
    if (!started) {
      await _showActiveWorkoutSessionDialog();
      return;
    }
    // Collega esplicitamente la sessione appena creata al piano (Milestone
    // 8.5, sezione 16-19): se il collegamento fallisce, la sessione
    // resterebbe "orfana" (comunque visibile come sessione spontanea, mai
    // persa) — per evitare l'incoerenza la abbandoniamo subito, stesso
    // principio del limite noto già accettato per le scritture
    // fire-and-forget di M4.4.3 (finestra di rischio minima e recuperabile).
    try {
      await ref
          .read(plannedActivityControllerProvider)
          .linkWorkoutSession(
            activity: widget.activity,
            workoutSessionId: sessionId!,
          );
    } catch (_) {
      ref.read(workoutSessionControllerProvider.notifier).abort();
      if (!mounted) return;
      _showMessage(
        'Non è stato possibile collegare la sessione al piano. Riprova.',
      );
      return;
    }
    if (!mounted) return;
    context.push(AppRoutes.workoutSessionPath(widget.activity.workoutId!));
  }

  Future<void> _resumeWorkout(int sessionId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final restored = await ref
          .read(workoutSessionRestoreServiceProvider)
          .restore(sessionId);
      if (restored == null) {
        _showMessage(
          'Impossibile ripristinare: la scheda originale non esiste più.',
        );
        return;
      }
      ref
          .read(workoutSessionControllerProvider.notifier)
          .adoptRestoredSession(restored);
      if (!mounted) return;
      context.push(AppRoutes.workoutSessionPath(restored.workoutId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startWalk() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(walkingSessionControllerProvider.notifier);
      await controller.start(widget.profileId);
      if (!mounted) return;
      final state = ref.read(walkingSessionControllerProvider);
      if (state == null) {
        _showMessage('Non è stato possibile avviare la camminata.');
        return;
      }
      try {
        await ref
            .read(plannedActivityControllerProvider)
            .linkWalkingSession(
              activity: widget.activity,
              walkingSessionId: state.sessionId,
            );
      } catch (_) {
        await controller.abort();
        if (!mounted) return;
        _showMessage(
          'Non è stato possibile collegare la sessione al piano. Riprova.',
        );
        return;
      }
      if (!mounted) return;
      context.push(AppRoutes.walkingSession);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resumeWalk() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(walkingSessionControllerProvider.notifier)
          .restoreActive(widget.profileId);
      if (!mounted) return;
      if (ref.read(walkingSessionControllerProvider) == null) {
        _showMessage('Non è stato possibile riprendere la camminata.');
        return;
      }
      context.push(AppRoutes.walkingSession);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget? _buildActionButton(PlannedActivityDisplayState displayState) {
    final activity = widget.activity;
    String label;
    VoidCallback? onPressed;
    switch (activity.type) {
      case PlannedActivityType.workout:
        // Nessuna azione se il Workout referenziato non esiste più
        // (sezione 13/29): l'unica azione sensata è correggere il piano.
        if (activity.workoutId == null) return null;
        switch (displayState) {
          case PlannedActivityDisplayState.completed:
          // Saltata/rinviata (Milestone 8.6, sezione 26): niente Avvia,
          // l'utente deve prima ripristinarla o spostarla dal Piano
          // Settimanale.
          case PlannedActivityDisplayState.skipped:
          case PlannedActivityDisplayState.postponed:
            return null;
          case PlannedActivityDisplayState.active:
            label = 'Riprendi';
            onPressed = _busy
                ? null
                : () => _resumeWorkout(activity.workoutSessionId!);
          case PlannedActivityDisplayState.none:
            label = 'Avvia';
            onPressed = _busy ? null : _startWorkout;
        }
      case PlannedActivityType.walk:
        switch (displayState) {
          case PlannedActivityDisplayState.completed:
          case PlannedActivityDisplayState.skipped:
          case PlannedActivityDisplayState.postponed:
            return null;
          case PlannedActivityDisplayState.active:
            label = 'Riprendi';
            onPressed = _busy ? null : _resumeWalk;
          case PlannedActivityDisplayState.none:
            label = 'Avvia';
            onPressed = _busy ? null : _startWalk;
        }
      case PlannedActivityType.recovery:
        // Sezione 15/21/37: nessuna sessione, nessun pulsante.
        return null;
    }
    if (widget.prominent) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(
            label == 'Riprendi' ? Icons.play_circle_outline : Icons.play_arrow,
          ),
          label: Text(
            _busy
                ? 'Avvio in corso…'
                : label == 'Riprendi'
                ? 'Riprendi attività'
                : activity.type == PlannedActivityType.walk
                ? 'Inizia camminata'
                : 'Inizia allenamento',
          ),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: _busy
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final displayState = PlannedActivityPresentation.displayState(
      ref,
      activity,
    );
    final actionButton = _buildActionButton(displayState);
    if (widget.prominent) {
      final details =
          activity.type == PlannedActivityType.workout &&
              activity.workoutId != null
          ? ref.watch(workoutDetailsProvider(activity.workoutId!)).valueOrNull
          : null;
      final exerciseMinutes = details?.workout.estimatedDurationMinutes;
      final walkingMinutes = details?.workout.walkingBlock?.minutes ?? 0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              PlannedActivityPresentation.title(activity.type),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            PlannedActivityPresentation.subtitle(ref, activity),
            if (details != null)
              Text(
                '${details.exercises.length} esercizi${exerciseMinutes == null ? '' : ' · ${exerciseMinutes + walkingMinutes} min previsti'}',
              ),
            const SizedBox(height: 12),
            ?actionButton,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PlannedActivityPresentation.icon(activity.type)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PlannedActivityPresentation.title(activity.type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                PlannedActivityPresentation.subtitle(ref, activity),
              ],
            ),
          ),
          if (actionButton != null) ...[const SizedBox(width: 8), actionButton],
        ],
      ),
    );
  }
}
