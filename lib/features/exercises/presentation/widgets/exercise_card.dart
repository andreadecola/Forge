import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/exercise_availability_status.dart';
import '../../application/exercise_catalog_providers.dart';
import 'availability_badge.dart';
import 'exercise_image_placeholder.dart';

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
          opacity: locked ? 0.8 : 1,
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
                      const SizedBox(height: 2),
                      Text(
                        equipmentLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ForgeColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({
    required this.exerciseId,
    required this.categoryCode,
    required this.locked,
  });

  final int exerciseId;
  final String categoryCode;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(exerciseImagesProvider(exerciseId));

    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: imagesAsync.when(
                data: (images) {
                  final path = images.isEmpty ? null : images.first.path;
                  if (path == null) {
                    return ExerciseImagePlaceholder(categoryCode: categoryCode);
                  }
                  return Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        ExerciseImagePlaceholder(categoryCode: categoryCode),
                  );
                },
                loading: () =>
                    Container(color: ForgeColors.anthraciteSurfaceHigh),
                error: (error, stackTrace) =>
                    ExerciseImagePlaceholder(categoryCode: categoryCode),
              ),
            ),
          ),
          if (locked)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: ForgeColors.anthracite,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 11,
                  color: ForgeColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
