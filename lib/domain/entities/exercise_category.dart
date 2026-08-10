class ExerciseCategory {
  const ExerciseCategory({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.active,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final int displayOrder;
  final bool active;
}
