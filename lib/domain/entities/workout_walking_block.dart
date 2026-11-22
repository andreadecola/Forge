import 'dart:convert';

enum WalkingPlacement { beforeExercises, afterExercises }

/// Parte della scheda, con gli stessi giorni e la stessa sessione complessiva.
/// I dati reali della camminata continuano a vivere nel modulo Camminate.
class WorkoutWalkingBlock {
  const WorkoutWalkingBlock({required this.minutes, required this.placement});
  final int minutes;
  final WalkingPlacement placement;

  void validate() {
    if (minutes <= 0 || minutes > 1440) {
      throw const FormatException('Durata camminata non valida.');
    }
  }

  String get positionLabel => placement == WalkingPlacement.beforeExercises
      ? 'Prima degli esercizi'
      : 'Dopo gli esercizi';
  Map<String, dynamic> toJson() => {
    'minutes': minutes,
    'placement': placement.name,
  };
  String encode() {
    validate();
    return jsonEncode(toJson());
  }

  static WorkoutWalkingBlock? fromStorage(String? raw) =>
      raw == null ? null : fromJson(jsonDecode(raw));
  static WorkoutWalkingBlock? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> ||
        value['minutes'] is! int ||
        !WalkingPlacement.values.any((p) => p.name == value['placement'])) {
      throw const FormatException('Blocco camminata non valido.');
    }
    final result = WorkoutWalkingBlock(
      minutes: value['minutes'] as int,
      placement: WalkingPlacement.values.firstWhere(
        (p) => p.name == value['placement'],
      ),
    );
    result.validate();
    return result;
  }
}
