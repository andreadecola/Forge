import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';

/// Stato di un esercizio nella sessione corrente (Milestone 4.4.1).
enum SessionExerciseStatus { completed, skipped }

/// Indicatore testuale + icona dello stato di un esercizio nella sessione
/// ("✓ Completato" / "Saltato"): mai comunicato solo tramite colore.
class ExerciseStatusChip extends StatelessWidget {
  const ExerciseStatusChip({super.key, required this.status});

  final SessionExerciseStatus status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == SessionExerciseStatus.completed;
    final color = isCompleted
        ? ForgeColors.success
        : ForgeColors.steelGrayLight;
    final label = isCompleted ? 'Completato' : 'Saltato';
    final icon = isCompleted ? Icons.check_circle : Icons.skip_next;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
