/// Modelli di parsing tipizzati per `assets/data/exercises_v1.json`.
///
/// Isolano il resto della data-layer dai `Map<String, dynamic>` grezzi e
/// centralizzano la lettura dei campi. La validazione referenziale vive nel
/// seeder ([ExerciseCatalogSeeder]), non qui: questi modelli si limitano a
/// leggere la forma del JSON.
library;

class CatalogParseException implements Exception {
  CatalogParseException(this.message);

  final String message;

  @override
  String toString() => 'CatalogParseException: $message';
}

T _required<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw CatalogParseException(
      'Campo "$key" mancante o di tipo errato (atteso $T).',
    );
  }
  return value;
}

class ExerciseCatalogSeedModel {
  ExerciseCatalogSeedModel({
    required this.catalogType,
    required this.catalogVersion,
    required this.categories,
    required this.muscleGroups,
    required this.equipment,
    required this.exercises,
  });

  final String catalogType;
  final int catalogVersion;
  final List<CategorySeedModel> categories;
  final List<MuscleGroupSeedModel> muscleGroups;
  final List<EquipmentSeedModel> equipment;
  final List<ExerciseSeedModel> exercises;

  factory ExerciseCatalogSeedModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCatalogSeedModel(
      catalogType: _required<String>(json, 'catalogType'),
      catalogVersion: _required<int>(json, 'catalogVersion'),
      categories: (_required<List<dynamic>>(json, 'categories'))
          .map((e) => CategorySeedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      muscleGroups: (_required<List<dynamic>>(json, 'muscleGroups'))
          .map((e) => MuscleGroupSeedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      equipment: (_required<List<dynamic>>(json, 'equipment'))
          .map((e) => EquipmentSeedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: (_required<List<dynamic>>(json, 'exercises'))
          .map((e) => ExerciseSeedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategorySeedModel {
  CategorySeedModel({
    required this.code,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.active,
  });

  final String code;
  final String name;
  final String? description;
  final int displayOrder;
  final bool active;

  factory CategorySeedModel.fromJson(Map<String, dynamic> json) {
    return CategorySeedModel(
      code: _required<String>(json, 'code'),
      name: _required<String>(json, 'name'),
      description: json['description'] as String?,
      displayOrder: _required<int>(json, 'displayOrder'),
      active: json['active'] as bool? ?? true,
    );
  }
}

class MuscleGroupSeedModel {
  MuscleGroupSeedModel({
    required this.code,
    required this.name,
    required this.active,
  });

  final String code;
  final String name;
  final bool active;

  factory MuscleGroupSeedModel.fromJson(Map<String, dynamic> json) {
    return MuscleGroupSeedModel(
      code: _required<String>(json, 'code'),
      name: _required<String>(json, 'name'),
      active: json['active'] as bool? ?? true,
    );
  }
}

class EquipmentSeedModel {
  EquipmentSeedModel({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.priority,
    required this.searchQuery,
    required this.active,
  });

  final String code;
  final String name;
  final String? description;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int priority;
  final String? searchQuery;
  final bool active;

  factory EquipmentSeedModel.fromJson(Map<String, dynamic> json) {
    return EquipmentSeedModel(
      code: _required<String>(json, 'code'),
      name: _required<String>(json, 'name'),
      description: json['description'] as String?,
      category: json['category'] as String?,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      priority: json['priority'] as int? ?? 0,
      searchQuery: json['searchQuery'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }
}

class ExerciseEquipmentSeedModel {
  ExerciseEquipmentSeedModel({required this.code, required this.required});

  final String code;
  final bool required;

  factory ExerciseEquipmentSeedModel.fromJson(Map<String, dynamic> json) {
    return ExerciseEquipmentSeedModel(
      code: _required<String>(json, 'code'),
      required: json['required'] as bool? ?? true,
    );
  }
}

class ExerciseImageSeedModel {
  ExerciseImageSeedModel({
    required this.type,
    required this.sourceType,
    required this.path,
    required this.caption,
    required this.order,
  });

  final String type;
  final String sourceType;
  final String path;
  final String? caption;
  final int order;

  factory ExerciseImageSeedModel.fromJson(Map<String, dynamic> json) {
    return ExerciseImageSeedModel(
      type: _required<String>(json, 'type'),
      sourceType: _required<String>(json, 'sourceType'),
      path: _required<String>(json, 'path'),
      caption: json['caption'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}

class ExerciseAlternativeSeedModel {
  ExerciseAlternativeSeedModel({
    required this.code,
    required this.reason,
    required this.priority,
  });

  final String code;
  final String reason;
  final int priority;

  factory ExerciseAlternativeSeedModel.fromJson(Map<String, dynamic> json) {
    return ExerciseAlternativeSeedModel(
      code: _required<String>(json, 'code'),
      reason: _required<String>(json, 'reason'),
      priority: json['priority'] as int? ?? 0,
    );
  }
}

class ExerciseSeedModel {
  ExerciseSeedModel({
    required this.code,
    required this.name,
    required this.categoryCode,
    required this.description,
    required this.instructions,
    required this.breathingInstructions,
    required this.safetyNotes,
    required this.commonMistakes,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.impactLevel,
    required this.cardioIntensity,
    required this.balanceRequired,
    required this.floorRequired,
    required this.standingRequired,
    required this.supportAllowed,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultDurationSeconds,
    required this.defaultRestSeconds,
    required this.equipmentCodes,
    required this.primaryMuscleCodes,
    required this.secondaryMuscleCodes,
    required this.progressionCode,
    required this.progressionType,
    required this.alternativeCodes,
    required this.images,
  });

  final String code;
  final String name;
  final String categoryCode;
  final String description;
  final String instructions;
  final String? breathingInstructions;
  final String? safetyNotes;
  final String? commonMistakes;
  final int minimumLevel;
  final int? maximumLevel;
  final String impactLevel;
  final String? cardioIntensity;
  final bool balanceRequired;
  final bool floorRequired;
  final bool standingRequired;
  final bool supportAllowed;
  final int? defaultSets;
  final int? defaultReps;
  final int? defaultDurationSeconds;
  final int? defaultRestSeconds;
  final List<ExerciseEquipmentSeedModel> equipmentCodes;
  final List<String> primaryMuscleCodes;
  final List<String> secondaryMuscleCodes;
  final String? progressionCode;
  final String? progressionType;
  final List<ExerciseAlternativeSeedModel> alternativeCodes;
  final List<ExerciseImageSeedModel> images;

  factory ExerciseSeedModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSeedModel(
      code: _required<String>(json, 'code'),
      name: _required<String>(json, 'name'),
      categoryCode: _required<String>(json, 'categoryCode'),
      description: _required<String>(json, 'description'),
      instructions: _required<String>(json, 'instructions'),
      breathingInstructions: json['breathingInstructions'] as String?,
      safetyNotes: json['safetyNotes'] as String?,
      commonMistakes: json['commonMistakes'] as String?,
      minimumLevel: _required<int>(json, 'minimumLevel'),
      maximumLevel: json['maximumLevel'] as int?,
      impactLevel: _required<String>(json, 'impactLevel'),
      cardioIntensity: json['cardioIntensity'] as String?,
      balanceRequired: json['balanceRequired'] as bool? ?? false,
      floorRequired: json['floorRequired'] as bool? ?? false,
      standingRequired: json['standingRequired'] as bool? ?? false,
      supportAllowed: json['supportAllowed'] as bool? ?? false,
      defaultSets: json['defaultSets'] as int?,
      defaultReps: json['defaultReps'] as int?,
      defaultDurationSeconds: json['defaultDurationSeconds'] as int?,
      defaultRestSeconds: json['defaultRestSeconds'] as int?,
      equipmentCodes: ((json['equipmentCodes'] as List<dynamic>?) ?? const [])
          .map(
            (e) =>
                ExerciseEquipmentSeedModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      primaryMuscleCodes:
          ((json['primaryMuscleCodes'] as List<dynamic>?) ?? const [])
              .cast<String>(),
      secondaryMuscleCodes:
          ((json['secondaryMuscleCodes'] as List<dynamic>?) ?? const [])
              .cast<String>(),
      progressionCode: json['progressionCode'] as String?,
      progressionType: json['progressionType'] as String?,
      alternativeCodes:
          ((json['alternativeCodes'] as List<dynamic>?) ?? const [])
              .map(
                (e) => ExerciseAlternativeSeedModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      images: ((json['images'] as List<dynamic>?) ?? const [])
          .map(
            (e) => ExerciseImageSeedModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
