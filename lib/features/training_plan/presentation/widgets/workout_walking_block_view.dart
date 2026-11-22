import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/workout_session_controller.dart';
import '../../application/workout_session_state.dart';
import '../../../walking/application/walking_session_controller.dart';
import '../../../walking/presentation/pages/walking_session_page.dart';

/// Stessa UI e stesso timer del modulo Camminate, dentro la sessione scheda.
class WorkoutWalkingBlockView extends ConsumerStatefulWidget {
  const WorkoutWalkingBlockView({super.key, required this.session});
  final WorkoutSessionState session;
  @override
  ConsumerState<WorkoutWalkingBlockView> createState() =>
      _WorkoutWalkingBlockViewState();
}

class _WorkoutWalkingBlockViewState
    extends ConsumerState<WorkoutWalkingBlockView> {
  bool _busy = false;
  String? _error;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is StateError
              ? error.message
              : 'Impossibile aggiornare la camminata. Riprova.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _abort() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Interrompere l’allenamento?'),
        content: const Text(
          'La scheda e la camminata in corso verranno conservate nello storico come interrotte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continua'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Interrompi'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(workoutSessionControllerProvider.notifier).abort();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final block = session.walkingBlock!;
    final runtime = ref.watch(walkingSessionControllerProvider);
    final controller = ref.read(workoutSessionControllerProvider.notifier);
    final active =
        runtime != null &&
        runtime.sessionId == session.walkingSessionId &&
        !runtime.isTerminal;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Camminata · ${block.minutes} min · ${block.positionLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (_error != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
        Expanded(
          child: active
              ? ActiveWalkingView(
                  runtime: runtime,
                  targetMinutes: block.minutes,
                  onPause: controller.pause,
                  onResume: controller.resume,
                  onComplete: _busy
                      ? () {}
                      : () => _run(controller.completeWalkingBlock),
                  onAbort: _abort,
                  onEditMetrics: () =>
                      showWalkingMetricsEditor(context, ref, runtime),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_walk, size: 56),
                        const SizedBox(height: 16),
                        const Text(
                          'La camminata fa parte di questa scheda e segue gli stessi giorni pianificati.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _run(controller.startWalkingBlock),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            session.walkingSessionId == null
                                ? 'Avvia camminata'
                                : 'Riprendi camminata',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
