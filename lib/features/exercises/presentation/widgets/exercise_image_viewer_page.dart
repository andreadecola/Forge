import 'package:flutter/material.dart';

import '../../../../domain/entities/exercise_catalog_enums.dart';
import '../../../../domain/entities/exercise_image.dart';
import '../exercise_labels.dart';
import 'exercise_image_placeholder.dart';

/// Vista a schermo intero con pinch-zoom/pan per un'immagine dell'esercizio.
/// Va apert[a] solo per immagini realmente caricate: se comunque l'asset
/// risultasse mancante, mostra il placeholder anziché un errore.
class ExerciseImageViewerPage extends StatelessWidget {
  const ExerciseImageViewerPage({super.key, required this.image});

  final ExerciseImage image;

  @override
  Widget build(BuildContext context) {
    final path = image.path;
    final isAsset = image.sourceType == ExerciseImageSourceType.asset;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(ExerciseLabels.imageType(image.imageType)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: isAsset && path != null
              ? Image.asset(
                  path,
                  semanticLabel: ExerciseLabels.imageType(image.imageType),
                  errorBuilder: (context, error, stackTrace) =>
                      const ExerciseImagePlaceholder(),
                )
              : const ExerciseImagePlaceholder(
                  message: 'Formato immagine non ancora supportato.',
                ),
        ),
      ),
    );
  }
}
