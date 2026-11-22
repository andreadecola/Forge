import 'workout_enums.dart';
import 'workout_walking_block.dart';

/// Definizione di una scheda allenamento (dati scalari). La lista di
/// esercizi risolta è aggregata in [WorkoutDetails]: `Workout` resta
/// leggero per le liste (`getWorkouts`/`watchWorkouts`).
class Workout {
  const Workout({
    this.id,
    required this.profileId,
    required this.name,
    this.description,
    required this.type,
    this.level = 1,
    this.selectedLevels,
    this.estimatedDurationMinutes,
    this.walkingBlock,
    required this.status,
    required this.origin,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int profileId;
  final String name;
  final String? description;
  final WorkoutType type;
  final int level;

  /// Livelli selezionati per la scheda. Le schede storiche prive del nuovo
  /// campo vengono ricostruite dal mapper come insieme contenente [level].
  final Set<int>? selectedLevels;

  /// Compatibilità per le schede create prima del campo multilivello.
  Set<int> get effectiveSelectedLevels => selectedLevels ?? {level};
  final int? estimatedDurationMinutes;
  final WorkoutWalkingBlock? walkingBlock;
  final WorkoutDefinitionStatus status;
  final WorkoutOrigin origin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Workout copyWith({
    int? id,
    int? profileId,
    String? name,
    String? Function()? description,
    WorkoutType? type,
    int? level,
    Set<int>? selectedLevels,
    int? Function()? estimatedDurationMinutes,
    WorkoutWalkingBlock? Function()? walkingBlock,
    WorkoutDefinitionStatus? status,
    WorkoutOrigin? origin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      type: type ?? this.type,
      walkingBlock: walkingBlock != null ? walkingBlock() : this.walkingBlock,
      level: level ?? this.level,
      selectedLevels: selectedLevels ?? this.selectedLevels,
      estimatedDurationMinutes: estimatedDurationMinutes != null
          ? estimatedDurationMinutes()
          : this.estimatedDurationMinutes,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
