import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/workout_exercise.dart';
import '../../../exercises/application/exercise_catalog_providers.dart';
import '../../../exercises/presentation/widgets/exercise_image_gallery.dart';
import '../../application/workout_session_clock.dart';
import '../../application/workout_session_controller.dart';
import '../../application/workout_session_phase.dart';
import '../../application/workout_session_state.dart';
import '../widgets/exercise_status_chip.dart';

/// Esecuzione guidata di una scheda (Milestone 4.4.1; serie e timer
/// aggiunti in Milestone 4.4.2): mostra un esercizio per volta, con
/// avanzamento serie per serie (ripetizioni o countdown a tempo),
/// recupero tra le serie e pausa. Nessuna persistenza, nessuno storico,
/// nessun Forge Engine — tutto rimandato a milestone successive (vedi
/// 07_Training_Engine.md).
///
/// Il riepilogo finale è mostrato come vista interna a questa stessa
/// pagina (non una rotta separata): evita di dover far viaggiare
/// nome/conteggi tramite la rotta quando lo stato della sessione li ha
/// già tutti.
class WorkoutSessionPage extends ConsumerWidget {
  const WorkoutSessionPage({super.key, required this.workoutId});

  final int workoutId;

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vuoi uscire dall\'allenamento?'),
        content: const Text(
          'I progressi della sessione corrente non verranno salvati.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continua allenamento'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (exit ?? false) {
      ref.read(workoutSessionControllerProvider.notifier).abort();
      if (!context.mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionControllerProvider);

    if (session == null || session.workoutId != workoutId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Allenamento')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nessuna sessione attiva per questa scheda.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Torna al dettaglio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope<Object?>(
      canPop: session.isCompleted,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // La sessione era già completata: uscire equivale a "Fine". Il
          // pop può arrivare qui anche durante un aggiornamento del
          // Navigator innescato da un'altra parte dell'albero (es. una
          // navigazione imperativa altrove): rinviare la modifica dello
          // stato al prossimo microtask evita di mutare un provider
          // mentre l'albero dei widget è ancora in fase di build.
          Future.microtask(
            () => ref.read(workoutSessionControllerProvider.notifier).finish(),
          );
          return;
        }
        _confirmExit(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(session.workoutName)),
        body: session.isCompleted
            ? _SessionCompleteView(session: session)
            : session.isPaused
            ? const _PausedView()
            : _SessionBody(session: session),
      ),
    );
  }
}

class _PausedView extends ConsumerWidget {
  const _PausedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              'Allenamento in pausa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => ref
                    .read(workoutSessionControllerProvider.notifier)
                    .resume(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Riprendi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session});

  final WorkoutSessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(workoutSessionControllerProvider.notifier);
    final clock = ref.read(sessionClockProvider);
    final entry = session.currentExercise;
    final id = session.currentWorkoutExerciseId;
    final status = session.completedWorkoutExerciseIds.contains(id)
        ? SessionExerciseStatus.completed
        : session.skippedWorkoutExerciseIds.contains(id)
        ? SessionExerciseStatus.skipped
        : null;
    final phase = session.phase;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esercizio ${session.currentExerciseIndex + 1} di '
                '${session.totalExercises}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: session.currentExerciseIndex / session.totalExercises,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.exercise.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (status != null) ExerciseStatusChip(status: status),
                  ],
                ),
                if (status == null && session.currentCompletedSets > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${session.currentCompletedSets} di '
                      '${session.currentTotalSets} serie completate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ForgeColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _ExerciseImage(exerciseId: entry.exercise.id),
                ),
                const SizedBox(height: 20),
                Text(
                  'Serie ${session.currentCompletedSets + 1} di '
                  '${session.currentTotalSets}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _SetDots(
                  total: session.currentTotalSets,
                  completed: session.currentCompletedSets,
                ),
                const SizedBox(height: 20),
                if (phase == WorkoutSessionPhase.resting)
                  _RestingContent(session: session, clock: clock)
                else
                  _SetContent(
                    session: session,
                    clock: clock,
                    isRunning: phase == WorkoutSessionPhase.timedSetRunning,
                  ),
                ..._secondaryInfoLines(
                  entry.workoutExercise,
                ).map((line) => _InfoLine(text: line)),
              ],
            ),
          ),
        ),
        // Le azioni restano fuori dall'area scrollabile e sempre visibili:
        // durante l'allenamento l'utente non deve mai dover scorrere per
        // trovare "Completa serie"/"Avvia serie"/"Salta recupero" (sezione
        // 27: pulsanti grandi e leggibili, poche distrazioni).
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                if (phase == WorkoutSessionPhase.resting) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.skipRest,
                      child: const Text('Salta recupero'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else if (phase == WorkoutSessionPhase.readySet) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: session.currentExerciseIsTimed
                          ? controller.startTimedSet
                          : controller.completeCurrentSet,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        session.currentExerciseIsTimed
                            ? 'Avvia serie'
                            : 'Completa serie',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: session.currentExerciseIndex == 0
                            ? null
                            : controller.previousExercise,
                        child: const Text('Indietro'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.skipCurrentExercise,
                        child: const Text('Salta'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.pause,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pausa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Contenuto visivo della serie corrente: countdown grande per un
/// esercizio a tempo (in anteprima statica se non ancora avviato, live se
/// in corso), numero di ripetizioni per uno a ripetizioni. Solo
/// visualizzazione: il CTA principale vive nella barra fissa in fondo
/// alla pagina (vedi [_SessionBody]), non qui dentro l'area scrollabile.
class _SetContent extends StatelessWidget {
  const _SetContent({
    required this.session,
    required this.clock,
    required this.isRunning,
  });

  final WorkoutSessionState session;
  final SessionClock clock;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final we = session.currentExercise.workoutExercise;

    if (session.currentExerciseIsTimed) {
      final remaining = isRunning
          ? session.exerciseTimer!.remainingSeconds(clock)
          : we.durationSeconds!;
      return Center(
        child: Text(
          formatSessionCountdown(remaining),
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (we.repetitions == null) return const SizedBox.shrink();
    return Text(
      '${we.repetitions} ripetizioni',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _RestingContent extends StatelessWidget {
  const _RestingContent({required this.session, required this.clock});

  final WorkoutSessionState session;
  final SessionClock clock;

  @override
  Widget build(BuildContext context) {
    final remaining = session.restTimer!.remainingSeconds(clock);
    final nextSet = session.currentCompletedSets + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'RECUPERO',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ForgeColors.copper,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            formatSessionCountdown(remaining),
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recupero prima della serie $nextSet',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ForgeColors.textSecondary),
        ),
      ],
    );
  }
}

class _SetDots extends StatelessWidget {
  const _SetDots({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              i < completed ? Icons.circle : Icons.circle_outlined,
              size: 12,
              color: i < completed
                  ? ForgeColors.success
                  : ForgeColors.steelGrayLight,
            ),
          ),
      ],
    );
  }
}

/// Formato timer richiesto: sempre `MM:SS`, mai "N sec" durante un
/// countdown.
String formatSessionCountdown(int totalSeconds) {
  final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safeSeconds ~/ 60;
  final seconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

/// Righe informative secondarie: recupero previsto (solo come anteprima,
/// prima di iniziare la serie — durante il recupero c'è già il countdown
/// dedicato) e note. Nessun valore assente viene mostrato.
List<String> _secondaryInfoLines(WorkoutExercise exercise) {
  final lines = <String>[];

  final rest = exercise.restSeconds;
  if (rest != null && rest > 0) {
    lines.add('Recupero previsto: ${formatSessionCountdown(rest)}');
  }

  final notes = exercise.notes;
  if (notes != null && notes.trim().isNotEmpty) {
    lines.add(notes.trim());
  }

  return lines;
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _ExerciseImage extends ConsumerWidget {
  const _ExerciseImage({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(exerciseImagesProvider(exerciseId));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagesAsync.when(
        data: (images) => ExerciseImageGallery(images: images),
        loading: () => Container(color: ForgeColors.anthraciteSurfaceHigh),
        error: (error, stackTrace) => const ExerciseImageGallery(images: []),
      ),
    );
  }
}

class _SessionCompleteView extends ConsumerWidget {
  const _SessionCompleteView({required this.session});

  final WorkoutSessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: ForgeColors.copper,
            ),
            const SizedBox(height: 16),
            Text(
              'Allenamento completato',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              session.workoutName,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _SummaryRow(
              label: 'Esercizi completati',
              value: '${session.completedWorkoutExerciseIds.length}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Esercizi saltati',
              value: '${session.skippedWorkoutExerciseIds.length}',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(workoutSessionControllerProvider.notifier).finish();
                  context.pop();
                },
                child: const Text('Fine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
