import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/exercise_catalog_enums.dart';
import '../../../../domain/entities/exercise_image.dart';
import '../../application/exercise_catalog_providers.dart';
import 'exercise_image_placeholder.dart';

/// Miniatura START di un esercizio del catalogo.
///
/// Usa lo stesso provider delle card del catalogo e delle righe delle schede;
/// se il percorso non esiste o l'asset non viene caricato, mostra il
/// placeholder senza propagare l'errore alla schermata.
class ExerciseImageThumbnail extends ConsumerWidget {
  const ExerciseImageThumbnail({
    super.key,
    required this.exerciseId,
    this.size = 52,
    this.categoryCode,
    this.borderRadius = 8,
  });

  final int exerciseId;
  final double size;
  final String? categoryCode;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(exerciseImagesProvider(exerciseId));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imagesAsync.when(
          data: (images) {
            final image = _startImage(images);
            final path = image?.path;
            if (path == null) {
              return ExerciseImagePlaceholder(categoryCode: categoryCode);
            }
            return Image.asset(
              path,
              fit: BoxFit.cover,
              semanticLabel: 'Posizione iniziale',
              errorBuilder: (context, error, stackTrace) =>
                  ExerciseImagePlaceholder(categoryCode: categoryCode),
            );
          },
          loading: () => Container(color: ForgeColors.anthraciteSurfaceHigh),
          error: (error, stackTrace) =>
              ExerciseImagePlaceholder(categoryCode: categoryCode),
        ),
      ),
    );
  }

  ExerciseImage? _startImage(List<ExerciseImage> images) {
    for (final image in images) {
      if (image.active &&
          image.imageType == ExerciseImageType.posizioneIniziale &&
          image.path != null) {
        return image;
      }
    }
    return null;
  }
}
