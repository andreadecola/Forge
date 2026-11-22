import 'package:flutter/material.dart';

import '../../../../domain/entities/exercise_availability_status.dart';
import '../../application/exercise_catalog_providers.dart';
import 'availability_badge.dart';
import 'exercise_image_thumbnail.dart';

/// Card di un esercizio nella lista del catalogo. Mostra solo la cover
/// image (mai la gallery completa) e non carica il dettaglio completo.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.item, required this.onTap});

  final ExerciseCatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = item.status != ExerciseAvailabilityStatus.available;
    final equipmentLabel = item.requiredEquipmentNames.isEmpty
        ? 'Nessuna attrezzatura'
        : item.requiredEquipmentNames.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Opacity(
          opacity: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(
                  exerciseId: item.exercise.id,
                  categoryCode: item.category.code,
                  locked: locked,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category.name} · Livello ${item.exercise.minimumLevel}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        equipmentLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AvailabilityBadge(status: item.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.exerciseId,
    required this.categoryCode,
    required this.locked,
  });

  final int exerciseId;
  final String categoryCode;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          ExerciseImageThumbnail(
            exerciseId: exerciseId,
            size: 64,
            categoryCode: categoryCode,
            borderRadius: 10,
          ),
          if (locked)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock,
                  size: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
