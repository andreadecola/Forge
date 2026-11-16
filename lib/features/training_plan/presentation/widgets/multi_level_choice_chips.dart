import 'package:flutter/material.dart';

/// Selettore condiviso dei livelli Forge/manuali.
///
/// Il set non può diventare vuoto: il callback viene invocato solo quando la
/// nuova selezione contiene almeno un livello.
class MultiLevelChoiceChips extends StatelessWidget {
  const MultiLevelChoiceChips({
    super.key,
    required this.selectedLevels,
    required this.onChanged,
    this.labelBuilder,
  });

  final Set<int> selectedLevels;
  final ValueChanged<Set<int>> onChanged;
  final String Function(int level)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var level = 1; level <= 5; level++)
          ChoiceChip(
            label: Text(labelBuilder?.call(level) ?? '$level'),
            selected: selectedLevels.contains(level),
            onSelected: (_) {
              final next = {...selectedLevels};
              if (next.contains(level)) {
                if (next.length == 1) return;
                next.remove(level);
              } else {
                next.add(level);
              }
              onChanged(Set.unmodifiable(next));
            },
          ),
      ],
    );
  }
}
