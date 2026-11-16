import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/exercise_availability_status.dart';
import '../../../../domain/services/exercise_availability_service.dart';
import '../../../../domain/services/exercise_level_policy.dart';
import '../../../exercises/application/exercise_catalog_providers.dart';
import '../../../exercises/presentation/widgets/availability_badge.dart';
import '../../../exercises/presentation/widgets/exercise_filters_sheet.dart';
import '../../../exercises/presentation/widgets/exercise_image_thumbnail.dart';
import '../../../exercises/presentation/widgets/exercise_search_field.dart';
import '../../application/workout_editor_controller.dart';
import '../widgets/workout_exercise_config_sheet.dart';

/// Selettore esercizi per l'aggiunta a una scheda (Milestone 4.3, sezione
/// 13; rivisto in Milestone 4.3.1). Riusa il catalogo esistente (stessi
/// provider di filtro/ricerca di `ExerciseCatalogPage`): nessuna seconda
/// implementazione del catalogo.
///
/// Per le schede manuali (origine USER) [ExerciseAvailabilityStatus] resta
/// solo un'informazione, non un blocco: ogni esercizio non ancora presente è aggiungibile con
/// il pulsante "+", ma per LOCKED_LEVEL/LOCKED_EQUIPMENT viene chiesta
/// prima una conferma esplicita. Questa eccezione riguarda solo la
/// composizione manuale — `ExerciseAvailabilityService` e le sue regole
/// (incluse quelle che userà il futuro Forge Engine) non cambiano.
class ExercisePickerPage extends ConsumerStatefulWidget {
  const ExercisePickerPage({super.key, required this.workoutId});

  final int workoutId;

  @override
  ConsumerState<ExercisePickerPage> createState() => _ExercisePickerPageState();
}

class _ExercisePickerPageState extends ConsumerState<ExercisePickerPage> {
  int get workoutId => widget.workoutId;
  bool _adding = false;

  Future<void> _onAddPressed(
    BuildContext context,
    WidgetRef ref,
    ExerciseCatalogItem item,
  ) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await _addExercise(context, ref, item);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile aggiungere l’esercizio. Riprova.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _addExercise(
    BuildContext context,
    WidgetRef ref,
    ExerciseCatalogItem item,
  ) async {
    final currentDetails = ref
        .read(workoutEditorControllerProvider(workoutId))
        .valueOrNull;
    if (currentDetails?.exercises.any(
          (entry) => entry.exercise.id == item.exercise.id,
        ) ??
        false) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esercizio già presente nella scheda.')),
        );
      }
      return;
    }

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

    final added = await ref
        .read(workoutEditorControllerProvider(workoutId).notifier)
        .addExerciseFromCatalog(
          exercise: item.exercise,
          sets: result.sets,
          repetitions: result.repetitions,
          durationSeconds: result.durationSeconds,
          restSeconds: result.restSeconds,
          notes: result.notes,
        );

    if (!added && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esercizio già presente nella scheda.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredExercisesProvider);
    final workoutAsync = ref.watch(workoutEditorControllerProvider(workoutId));
    final workout = workoutAsync.valueOrNull;
    final presentIds =
        workout?.exercises
            .map((entry) => entry.workoutExercise.exerciseId)
            .toSet() ??
        <int>{};
    final ownedEquipment = ref
        .watch(ownedMasterEquipmentCodesProvider)
        .valueOrNull;
    final selectedLevels = workout?.workout.effectiveSelectedLevels;

    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi esercizio')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                workout?.exercises.length == 1
                    ? '1 esercizio nella scheda'
                    : '${workout?.exercises.length ?? 0} esercizi nella scheda',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _adding ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Scheda completata'),
                ),
              ),
            ],
          ),
        ),
      ),
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
                if (workoutAsync.hasError) {
                  return const Center(
                    child: Text('Impossibile caricare la scheda.'),
                  );
                }
                if (workout == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final availableItems = items
                    .where((item) => !presentIds.contains(item.exercise.id))
                    .toList();
                if (availableItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nessun altro esercizio da aggiungere con questi filtri.',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final item = _itemForWorkoutLevels(
                      availableItems[index],
                      selectedLevels: selectedLevels,
                      ownedEquipmentCodes: ownedEquipment,
                    );
                    return _PickerTile(
                      item: item,
                      onAdd: _adding
                          ? null
                          : () => _onAddPressed(context, ref, item),
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

  ExerciseCatalogItem _itemForWorkoutLevels(
    ExerciseCatalogItem item, {
    required Set<int>? selectedLevels,
    required Set<String>? ownedEquipmentCodes,
  }) {
    if (selectedLevels == null || ownedEquipmentCodes == null) return item;
    final compatible = ExerciseLevelPolicy.isExerciseCompatibleWithAnyLevel(
      item.exercise,
      selectedLevels,
    );
    final status = !compatible
        ? ExerciseAvailabilityStatus.lockedLevel
        : ExerciseAvailabilityService.missingEquipment(
            requiredEquipmentCodes: item.requiredEquipmentCodes,
            ownedEquipmentCodes: ownedEquipmentCodes,
          ).isNotEmpty
        ? ExerciseAvailabilityStatus.lockedEquipment
        : ExerciseAvailabilityStatus.available;
    return item.copyWith(status: status);
  }
}

/// Riga del picker: nome, fotografia, categoria/livello, disponibilità e
/// pulsante di aggiunta. Gli esercizi già presenti sono esclusi a monte.
class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.item, required this.onAdd});

  final ExerciseCatalogItem item;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseImageThumbnail(
              exerciseId: item.exercise.id,
              size: 60,
              categoryCode: item.category.code,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AvailabilityBadge(status: item.status),
                ],
              ),
            ),
            IconButton(
              onPressed: onAdd,
              tooltip: 'Aggiungi alla scheda',
              icon: Icon(
                Icons.add_circle_outline,
                color: onAdd == null ? null : ForgeColors.copper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
