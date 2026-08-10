import 'exercise_catalog_enums.dart';

class ExerciseImage {
  const ExerciseImage({
    required this.id,
    required this.exerciseId,
    required this.sourceType,
    this.assetPath,
    this.localFilePath,
    required this.imageType,
    this.caption,
    required this.displayOrder,
    required this.active,
  });

  final int id;
  final int exerciseId;
  final ExerciseImageSourceType sourceType;
  final String? assetPath;
  final String? localFilePath;
  final ExerciseImageType imageType;
  final String? caption;
  final int displayOrder;
  final bool active;

  /// Percorso effettivo dell'immagine (asset o file locale), se presente.
  String? get path => switch (sourceType) {
    ExerciseImageSourceType.asset => assetPath,
    ExerciseImageSourceType.fileLocale => localFilePath,
  };
}
