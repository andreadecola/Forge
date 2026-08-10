import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/exercise_catalog_enums.dart';
import '../../../../domain/entities/exercise_image.dart';
import '../exercise_labels.dart';
import 'exercise_image_placeholder.dart';
import 'exercise_image_viewer_page.dart';

/// Carosello immagini di un esercizio, robusto rispetto ad asset mancanti:
/// - lista vuota -> placeholder unico;
/// - asset ASSET assente -> placeholder al posto dell'errore Flutter;
/// - sorgente FILE_LOCALE -> placeholder controllato (non ancora supportata).
///
/// Con più immagini mostra indicatore "1 / N" e didascalia (tipo immagine).
class ExerciseImageGallery extends StatefulWidget {
  const ExerciseImageGallery({
    super.key,
    required this.images,
    this.categoryCode,
  });

  final List<ExerciseImage> images;

  /// Categoria dell'esercizio, usata per scegliere la stick-figure del
  /// placeholder quando manca un'immagine reale.
  final String? categoryCode;

  @override
  State<ExerciseImageGallery> createState() => _ExerciseImageGalleryState();
}

class _ExerciseImageGalleryState extends State<ExerciseImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: ExerciseImagePlaceholder(categoryCode: widget.categoryCode),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _GalleryImage(
                image: images[index],
                categoryCode: widget.categoryCode,
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ExerciseLabels.imageType(images[_currentPage].imageType),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${_currentPage + 1} / ${images.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ForgeColors.textSecondary,
                ),
              ),
            ],
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              ExerciseLabels.imageType(images.first.imageType),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _GalleryImage extends StatefulWidget {
  const _GalleryImage({required this.image, this.categoryCode});

  final ExerciseImage image;
  final String? categoryCode;

  @override
  State<_GalleryImage> createState() => _GalleryImageState();
}

class _GalleryImageState extends State<_GalleryImage> {
  bool _failed = false;

  bool get _isDisplayableAsset =>
      !_failed &&
      widget.image.sourceType == ExerciseImageSourceType.asset &&
      widget.image.path != null;

  @override
  Widget build(BuildContext context) {
    if (!_isDisplayableAsset) {
      return ExerciseImagePlaceholder(
        message: widget.image.sourceType == ExerciseImageSourceType.fileLocale
            ? 'Formato immagine non ancora supportato.'
            : null,
        categoryCode: widget.categoryCode,
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExerciseImageViewerPage(image: widget.image),
        ),
      ),
      child: Image.asset(
        widget.image.path!,
        fit: BoxFit.cover,
        width: double.infinity,
        semanticLabel: ExerciseLabels.imageType(widget.image.imageType),
        errorBuilder: (context, error, stackTrace) {
          if (!_failed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _failed = true);
            });
          }
          return ExerciseImagePlaceholder(categoryCode: widget.categoryCode);
        },
      ),
    );
  }
}
