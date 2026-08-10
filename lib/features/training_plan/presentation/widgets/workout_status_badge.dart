import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../workout_labels.dart';

/// Badge colorato con l'etichetta italiana dello stato della scheda. Nessun
/// nome tecnico dell'enum deve raggiungere la UI (stesso principio di
/// `AvailabilityBadge`).
class WorkoutStatusBadge extends StatelessWidget {
  const WorkoutStatusBadge({super.key, required this.status});

  final WorkoutDefinitionStatus status;

  Color get _color {
    switch (status) {
      case WorkoutDefinitionStatus.draft:
        return ForgeColors.steelGrayLight;
      case WorkoutDefinitionStatus.ready:
        return ForgeColors.success;
      case WorkoutDefinitionStatus.archived:
        return ForgeColors.danger;
    }
  }

  IconData get _icon {
    switch (status) {
      case WorkoutDefinitionStatus.draft:
        return Icons.edit_note;
      case WorkoutDefinitionStatus.ready:
        return Icons.check_circle_outline;
      case WorkoutDefinitionStatus.archived:
        return Icons.archive_outlined;
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
            WorkoutLabels.status(status),
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
