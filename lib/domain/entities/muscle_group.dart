class MuscleGroup {
  const MuscleGroup({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.active,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final bool active;
}
