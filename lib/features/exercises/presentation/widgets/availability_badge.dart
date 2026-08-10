import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/exercise_availability_status.dart';
import '../exercise_labels.dart';

/// Badge colorato con l'etichetta italiana dello stato di disponibilità.
/// Non mostra mai il nome tecnico dell'enum.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.status});

  final ExerciseAvailabilityStatus status;

  Color get _color {
    switch (status) {
      case ExerciseAvailabilityStatus.available:
        return ForgeColors.success;
      case ExerciseAvailabilityStatus.lockedLevel:
        return ForgeColors.steelGrayLight;
      case ExerciseAvailabilityStatus.lockedEquipment:
        return ForgeColors.copper;
      case ExerciseAvailabilityStatus.recommended:
        return ForgeColors.copperLight;
      case ExerciseAvailabilityStatus.temporarilyAvoided:
      case ExerciseAvailabilityStatus.mastered:
        return ForgeColors.steelGrayLight;
    }
  }

  IconData get _icon {
    switch (status) {
      case ExerciseAvailabilityStatus.available:
        return Icons.check_circle_outline;
      case ExerciseAvailabilityStatus.lockedLevel:
        return Icons.trending_up;
      case ExerciseAvailabilityStatus.lockedEquipment:
        return Icons.lock_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            ExerciseLabels.availabilityStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
