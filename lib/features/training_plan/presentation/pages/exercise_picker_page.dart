import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/exercise_availability_status.dart';
import '../../../exercises/application/exercise_catalog_providers.dart';
import '../../../exercises/presentation/widgets/availability_badge.dart';
import '../../../exercises/presentation/widgets/exercise_filters_sheet.dart';
import '../../../exercises/presentation/widgets/exercise_search_field.dart';
import '../../application/workout_editor_controller.dart';
import '../widgets/workout_exercise_config_sheet.dart';

/// Selettore esercizi per l'aggiunta a una scheda (Milestone 4.3, sezione
/// 13; rivisto in Milestone 4.3.1). Riusa il catalogo esistente (stessi
/// provider di filtro/ricerca di `ExerciseCatalogPage`): nessuna seconda
/// implementazione del catalogo.
///
/// Per le schede manuali (origine USER) [ExerciseAvailabilityStatus] resta
/// solo un'informazione, non un blocco: ogni esercizio è aggiungibile con
/// il pulsante "+", ma per LOCKED_LEVEL/LOCKED_EQUIPMENT viene chiesta
/// prima una conferma esplicita. Questa eccezione riguarda solo la
/// composizione manuale — `ExerciseAvailabilityService` e le sue regole
/// (incluse quelle che userà il futuro Forge Engine) non cambiano.
class ExercisePickerPage extends ConsumerWidget {
  const ExercisePickerPage({super.key, required this.workoutId});

  final int workoutId;

  Future<void> _onAddPressed(
    BuildContext context,
    WidgetRef ref,
    ExerciseCatalogItem item,
  ) async {
    switch (item.status) {
      case ExerciseAvailabilityStatus.lockedLevel:
        final confirmed = await _confirmAddAnyway(
          context,
          message:
              'Questo esercizio è previsto per un livello superiore.\n'
              'Vuoi aggiungerlo comunque?',
        );
        if (!confirmed) return;
      case ExerciseAvailabilityStatus.lockedEquipment:
        final confirmed = await _confirmAddAnyway(
          context,
          message:
              'Questo esercizio richiede attrezzatura che non risulta tra '
              'quelle che possiedi. Vuoi aggiungerlo comunque?',
        );
        if (!confirmed) return;
      case ExerciseAvailabilityStatus.available:
      case ExerciseAvailabilityStatus.recommended:
      case ExerciseAvailabilityStatus.temporarilyAvoided:
      case ExerciseAvailabilityStatus.mastered:
        break;
    }
    if (!context.mounted) return;
    await _openConfigSheet(context, ref, item);
  }

  Future<bool> _confirmAddAnyway(
    BuildContext context, {
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aggiungi comunque'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _openConfigSheet(
    BuildContext context,
    WidgetRef ref,
    ExerciseCatalogItem item,
  ) async {
    final defaults = ref
        .read(workoutExerciseFactoryProvider)
        .fromExercise(exercise: item.exercise, workoutId: workoutId, order: 0);

    final result = await showWorkoutExerciseConfigSheet(
      context: context,
      exerciseName: item.exercise.name,
      initialSets: defaults.sets,
      initialRepetitions: defaults.repetitions,
      initialDurationSeconds: defaults.durationSeconds,
      initialRestSeconds: defaults.restSeconds,
      submitLabel: 'Aggiungi alla scheda',
    );
    if (result == null) return;

    // Nessun controllo su esercizi già presenti: il DB permette
    // intenzionalmente lo stesso esercizio più volte nella stessa scheda
    // (ordine diverso), quindi ogni conferma crea sempre una nuova riga.
    await ref
        .read(workoutEditorControllerProvider(workoutId).notifier)
        .addExerciseFromCatalog(
          exercise: item.exercise,
          sets: result.sets,
          repetitions: result.repetitions,
          durationSeconds: result.durationSeconds,
          restSeconds: result.restSeconds,
          notes: result.notes,
        );

    // Nessuno SnackBar: torniamo subito all'editor, dove l'esercizio appena
    // aggiunto è già visibile in lista (uno SnackBar qui rischierebbe di
    // restare a coprire la riga di pulsanti in fondo alla pagina di
    // destinazione, che condivide lo stesso ScaffoldMessenger).
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(filteredExercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi esercizio')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ExerciseSearchField(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => showExerciseFiltersSheet(context),
                  icon: const Icon(Icons.tune),
                  label: const Text('Filtri'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nessun esercizio corrisponde ai filtri selezionati.',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _PickerTile(
                      item: item,
                      onAdd: () => _onAddPressed(context, ref, item),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const Center(
                child: Text('Non è stato possibile caricare il catalogo.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga del picker: nome, categoria/livello, stato di disponibilità (solo
/// informativo) e pulsante "+" sempre attivo — la disponibilità non
/// blocca più l'aggiunta manuale (Milestone 4.3.1).
class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.item, required this.onAdd});

  final ExerciseCatalogItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.exercise.name,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${item.category.name} · Livello ${item.exercise.minimumLevel}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AvailabilityBadge(status: item.status),
                const Spacer(),
                IconButton(
                  onPressed: onAdd,
                  tooltip: 'Aggiungi alla scheda',
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: ForgeColors.copper,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
