/// Riga di scheda: un esercizio del catalogo inserito in un allenamento,
/// con solo ciò che può variare da una scheda all'altra. Il resto (nome,
/// istruzioni, muscoli, immagini) si legge tramite [exerciseId] nel
/// catalogo esercizi (risolto in [WorkoutExerciseDetails]).
class WorkoutExercise {
  const WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.order,
    this.sets,
    this.repetitions,
    this.durationSeconds,
    this.restSeconds,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int workoutId;
  final int exerciseId;
  final int order;
  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final int? restSeconds;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutExercise copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    int? order,
    int? Function()? sets,
    int? Function()? repetitions,
    int? Function()? durationSeconds,
    int? Function()? restSeconds,
    String? Function()? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      sets: sets != null ? sets() : this.sets,
      repetitions: repetitions != null ? repetitions() : this.repetitions,
      durationSeconds: durationSeconds != null
          ? durationSeconds()
          : this.durationSeconds,
      restSeconds: restSeconds != null ? restSeconds() : this.restSeconds,
      notes: notes != null ? notes() : this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
