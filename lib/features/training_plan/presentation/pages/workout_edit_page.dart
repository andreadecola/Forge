import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../domain/entities/workout_details.dart';
import '../../application/workout_editor_controller.dart';
import '../workout_labels.dart';
import '../widgets/workout_exercise_config_sheet.dart';
import '../widgets/workout_exercise_tile.dart';
import '../widgets/workout_metadata_form.dart';
import '../widgets/workout_status_badge.dart';

/// Composizione/modifica di una scheda: metadati, esercizi (aggiunta,
/// modifica parametri, rimozione, riordino) e transizioni di stato
/// (bozza/pronta/archiviata). Nessuna logica di business qui: tutte le
/// mutazioni passano per [WorkoutEditorController].
class WorkoutEditPage extends ConsumerWidget {
  const WorkoutEditPage({super.key, required this.workoutId});

  final int workoutId;

  Future<void> _editMetadata(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: WorkoutMetadataForm(
            initialName: details.workout.name,
            initialDescription: details.workout.description,
            initialType: details.workout.type,
            initialLevel: details.workout.level,
            initialEstimatedDurationMinutes:
                details.workout.estimatedDurationMinutes,
            submitLabel: 'Salva',
            onSubmit: (result) async {
              Navigator.of(context).pop();
              await ref
                  .read(workoutEditorControllerProvider(workoutId).notifier)
                  .updateMetadata(
                    name: result.name,
                    description: result.description,
                    type: result.type,
                    level: result.level,
                    estimatedDurationMinutes: result.estimatedDurationMinutes,
                  );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addExercise(BuildContext context) async {
    await context.push(AppRoutes.workoutExercisePickerPath(workoutId));
  }

  Future<void> _editExercise(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
    int index,
  ) async {
    final entry = details.exercises[index];
    final workoutExercise = entry.workoutExercise;
    final result = await showWorkoutExerciseConfigSheet(
      context: context,
      exerciseName: entry.exercise.name,
      initialSets: workoutExercise.sets,
      initialRepetitions: workoutExercise.repetitions,
      initialDurationSeconds: workoutExercise.durationSeconds,
      initialRestSeconds: workoutExercise.restSeconds,
      initialNotes: workoutExercise.notes,
      submitLabel: 'Salva',
    );
    if (result == null) return;
    await ref
        .read(workoutEditorControllerProvider(workoutId).notifier)
        .updateExercise(
          workoutExercise.copyWith(
            sets: () => result.sets,
            repetitions: () => result.repetitions,
            durationSeconds: () => result.durationSeconds,
            restSeconds: () => result.restSeconds,
            notes: () => result.notes,
          ),
        );
  }

  Future<void> _removeExercise(
    BuildContext context,
    WidgetRef ref,
    int workoutExerciseId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi esercizio'),
        content: const Text('Rimuovere questo esercizio dalla scheda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(workoutEditorControllerProvider(workoutId).notifier)
          .removeExercise(workoutExerciseId);
    }
  }

  Future<void> _reorder(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
    int oldIndex,
    int newIndex,
  ) async {
    final ids = details.exercises.map((e) => e.workoutExercise.id!).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);

    try {
      await ref
          .read(workoutEditorControllerProvider(workoutId).notifier)
          .reorderExercises(ids);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Non è stato possibile riordinare gli esercizi.'),
        ),
      );
    }
  }

  // Durata breve e hideCurrentSnackBar() prima di mostrarne uno nuovo: una
  // sequenza rapida di azioni (es. Salva bozza poi Segna come pronta) non
  // deve accumulare SnackBar sovrapposti né lasciarne uno "vecchio" a
  // coprire a lungo la riga di pulsanti in fondo alla pagina.
  void _showFeedback(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _saveAsDraft(BuildContext context, WidgetRef ref) async {
    await ref
        .read(workoutEditorControllerProvider(workoutId).notifier)
        .saveAsDraft();
    if (!context.mounted) return;
    _showFeedback(context, 'Bozza salvata');
  }

  Future<void> _markReady(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(workoutEditorControllerProvider(workoutId).notifier)
        .markReady();
    if (!context.mounted) return;
    if (result.isValid) {
      _showFeedback(context, 'Allenamento segnato come pronto');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('La scheda non è ancora pronta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final error in result.errors) Text('• $error')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivia scheda'),
        content: const Text(
          'Vuoi archiviare questa scheda? Non comparirà più nell\'elenco, '
          'ma resterà salvata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivia'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(workoutEditorControllerProvider(workoutId).notifier)
          .archive();
      if (!context.mounted) return;
      // Il messenger è condiviso con l'intera app (vive sopra il
      // Navigator): resta visibile anche dopo il pop, quindi appare "sulla
      // lista" come richiesto.
      _showFeedback(context, 'Allenamento archiviato');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutEditorControllerProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: Text(detailsAsync.valueOrNull?.workout.name ?? 'Scheda'),
        actions: [
          if (detailsAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifica dettagli',
              onPressed: () =>
                  _editMetadata(context, ref, detailsAsync.valueOrNull!),
            ),
        ],
      ),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Scheda non trovata.'));
          }
          return _EditorBody(
            details: details,
            onAddExercise: () => _addExercise(context),
            onEditExercise: (index) =>
                _editExercise(context, ref, details, index),
            onRemoveExercise: (id) => _removeExercise(context, ref, id),
            onReorder: (oldIndex, newIndex) =>
                _reorder(context, ref, details, oldIndex, newIndex),
            onSaveAsDraft: () => _saveAsDraft(context, ref),
            onMarkReady: () => _markReady(context, ref),
            onArchive: () => _archive(context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Si è verificato un errore.')),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.details,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onRemoveExercise,
    required this.onReorder,
    required this.onSaveAsDraft,
    required this.onMarkReady,
    required this.onArchive,
  });

  final WorkoutDetails details;
  final VoidCallback onAddExercise;
  final void Function(int index) onEditExercise;
  final void Function(int workoutExerciseId) onRemoveExercise;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onSaveAsDraft;
  final VoidCallback onMarkReady;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final workout = details.workout;
    final subtitleParts = <String>[
      WorkoutLabels.type(workout.type),
      'Livello ${workout.level}',
      if (workout.estimatedDurationMinutes != null)
        '${workout.estimatedDurationMinutes} min',
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  subtitleParts.join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              WorkoutStatusBadge(status: workout.status),
            ],
          ),
        ),
        if (workout.description != null && workout.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(workout.description!),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onAddExercise,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi esercizio'),
            ),
          ),
        ),
        Expanded(
          child: details.exercises.isEmpty
              ? _EmptyExercises(onAddExercise: onAddExercise)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: details.exercises.length,
                  onReorderItem: onReorder,
                  itemBuilder: (context, index) {
                    final entry = details.exercises[index];
                    return WorkoutExerciseTile(
                      key: ValueKey(entry.workoutExercise.id),
                      index: index + 1,
                      entry: entry,
                      onEdit: () => onEditExercise(index),
                      onRemove: () =>
                          onRemoveExercise(entry.workoutExercise.id!),
                      onShowDetail: () => context.push(
                        AppRoutes.exerciseDetailPath(entry.exercise.id),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSaveAsDraft,
                    child: const Text('Salva bozza'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onMarkReady,
                    child: const Text('Segna come pronta'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Archivia',
                  onPressed: onArchive,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises({required this.onAddExercise});

  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.playlist_add, size: 40),
            const SizedBox(height: 16),
            const Text(
              'Nessun esercizio aggiunto.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAddExercise,
              child: const Text('Aggiungi il primo esercizio'),
            ),
          ],
        ),
      ),
    );
  }
}
