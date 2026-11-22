import 'package:flutter/material.dart';
import '../../../../domain/entities/workout_walking_block.dart';

class WorkoutWalkingBlockFields extends StatelessWidget {
  const WorkoutWalkingBlockFields({
    super.key,
    required this.value,
    required this.onChanged,
    this.defaultMinutes = 30,
    this.allowDisable = true,
    this.showPlacement = true,
  });
  final WorkoutWalkingBlock? value;
  final ValueChanged<WorkoutWalkingBlock?> onChanged;
  final int defaultMinutes;
  final bool allowDisable, showPlacement;

  @override
  Widget build(BuildContext context) {
    final block = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (allowDisable)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Includi camminata nella scheda'),
            value: block != null,
            onChanged: (enabled) => onChanged(
              enabled == true
                  ? WorkoutWalkingBlock(
                      minutes: defaultMinutes,
                      placement: WalkingPlacement.afterExercises,
                    )
                  : null,
            ),
          ),
        if (block != null) ...[
          DropdownButtonFormField<int>(
            key: ValueKey('walking-duration-${block.minutes}'),
            initialValue: block.minutes,
            decoration: const InputDecoration(labelText: 'Durata camminata'),
            items: [
              for (final minutes in ({
                10,
                15,
                20,
                30,
                40,
                50,
                60,
                defaultMinutes,
                block.minutes,
              }.toList()..sort()))
                DropdownMenuItem(value: minutes, child: Text('$minutes min')),
            ],
            onChanged: (minutes) {
              if (minutes != null) {
                onChanged(
                  WorkoutWalkingBlock(
                    minutes: minutes,
                    placement: block.placement,
                  ),
                );
              }
            },
          ),
          if (showPlacement) ...[
            const SizedBox(height: 8),
            const Text('Quando svolgere la camminata'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final placement in WalkingPlacement.values)
                  ChoiceChip(
                    key: ValueKey('walking-placement-${placement.name}'),
                    label: Text(
                      placement == WalkingPlacement.beforeExercises
                          ? 'Prima degli esercizi'
                          : 'Dopo gli esercizi',
                    ),
                    selected: block.placement == placement,
                    onSelected: (_) => onChanged(
                      WorkoutWalkingBlock(
                        minutes: block.minutes,
                        placement: placement,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
