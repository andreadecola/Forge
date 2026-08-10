import 'workout_enums.dart';

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
    this.estimatedDurationMinutes,
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
  final int? estimatedDurationMinutes;
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
    int? Function()? estimatedDurationMinutes,
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
      level: level ?? this.level,
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
