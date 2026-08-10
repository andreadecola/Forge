import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/exercise_availability_status.dart';
import '../../application/exercise_catalog_providers.dart';
import '../exercise_labels.dart';

Future<void> showExerciseFiltersSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _ExerciseFiltersSheet(),
  );
}

const _availabilityOptions = [
  null,
  ExerciseAvailabilityStatus.available,
  ExerciseAvailabilityStatus.lockedLevel,
  ExerciseAvailabilityStatus.lockedEquipment,
];

class _ExerciseFiltersSheet extends ConsumerWidget {
  const _ExerciseFiltersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exerciseFiltersProvider);
    final controller = ref.read(exerciseFiltersProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);
    final equipmentAsync = ref.watch(equipmentCatalogProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtri', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: controller.reset,
                    child: const Text('Reimposta filtri'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Categoria', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tutte'),
                      selected: filters.categoryCode == null,
                      onSelected: (_) => controller.setCategoryCode(null),
                    ),
                    ...categories.map(
                      (category) => ChoiceChip(
                        label: Text(category.name),
                        selected: filters.categoryCode == category.code,
                        onSelected: (_) =>
                            controller.setCategoryCode(category.code),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Errore: $error'),
              ),
              const SizedBox(height: 20),
              Text('Livello', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var level = 1; level <= 5; level++)
                    ChoiceChip(
                      label: Text('Livello $level'),
                      selected: filters.userLevel == level,
                      onSelected: (_) => controller.setUserLevel(level),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Attrezzatura',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              equipmentAsync.when(
                data: (equipmentList) {
                  final selectedCode = filters.equipmentCodes?.isEmpty ?? true
                      ? null
                      : filters.equipmentCodes!.first;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tutte'),
                        selected: selectedCode == null,
                        onSelected: (_) => controller.setEquipmentCode(null),
                      ),
                      ...equipmentList.map(
                        (equipment) => ChoiceChip(
                          label: Text(equipment.name),
                          selected: selectedCode == equipment.code,
                          onSelected: (_) =>
                              controller.setEquipmentCode(equipment.code),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Errore: $error'),
              ),
              const SizedBox(height: 20),
              Text(
                'Disponibilità',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in _availabilityOptions)
                    ChoiceChip(
                      label: Text(
                        status == null
                            ? 'Tutti'
                            : ExerciseLabels.availabilityStatus(status),
                      ),
                      selected: filters.availabilityStatus == status,
                      onSelected: (_) =>
                          controller.setAvailabilityStatus(status),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Applica'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
