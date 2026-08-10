import 'package:drift/drift.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_enums.dart';
import '../../domain/entities/workout_exercise.dart';
import '../database/app_database.dart';

/// Conversioni tra righe Drift e entità di dominio degli allenamenti,
/// stesso ruolo di `CatalogMappers` per il catalogo esercizi: isolano il
/// dominio dai tipi generati e centralizzano il parsing dei codici → enum.
abstract final class WorkoutMappers {
  static Workout workout(AllenamentiTableData row) {
    return Workout(
      id: row.id,
      profileId: row.idProfilo,
      name: row.nome,
      description: row.descrizione,
      type: WorkoutType.fromCode(row.tipoAllenamento),
      level: row.livello,
      estimatedDurationMinutes: row.durataStimataMinuti,
      status: WorkoutDefinitionStatus.fromCode(row.stato),
      origin: WorkoutOrigin.fromCode(row.origine),
      isActive: row.attivo,
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  static WorkoutExercise workoutExercise(AllenamentiEserciziTableData row) {
    return WorkoutExercise(
      id: row.id,
      workoutId: row.idAllenamento,
      exerciseId: row.idEsercizio,
      order: row.ordine,
      sets: row.serie,
      repetitions: row.ripetizioni,
      durationSeconds: row.durataSecondi,
      restSeconds: row.recuperoSecondi,
      notes: row.note,
      isActive: row.attivo,
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  /// [workout] senza `id` produce un Companion adatto sia a insert che a
  /// update (a differenza del costruttore `.insert()`, non richiede tutti i
  /// campi non-nullable: qui li fornisce comunque tutti come [Value]).
  static AllenamentiTableCompanion workoutToCompanion(
    Workout workout, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return AllenamentiTableCompanion(
      id: workout.id == null ? const Value.absent() : Value(workout.id!),
      idProfilo: Value(workout.profileId),
      nome: Value(workout.name),
      descrizione: Value(workout.description),
      tipoAllenamento: Value(workout.type.code),
      livello: Value(workout.level),
      durataStimataMinuti: Value(workout.estimatedDurationMinutes),
      stato: Value(workout.status.code),
      origine: Value(workout.origin.code),
      attivo: Value(workout.isActive),
      dataCreazione: Value(workout.createdAt ?? timestamp),
      dataModifica: Value(timestamp),
    );
  }

  static AllenamentiEserciziTableCompanion workoutExerciseToCompanion(
    WorkoutExercise entry, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return AllenamentiEserciziTableCompanion(
      id: entry.id == null ? const Value.absent() : Value(entry.id!),
      idAllenamento: Value(entry.workoutId),
      idEsercizio: Value(entry.exerciseId),
      ordine: Value(entry.order),
      serie: Value(entry.sets),
      ripetizioni: Value(entry.repetitions),
      durataSecondi: Value(entry.durationSeconds),
      recuperoSecondi: Value(entry.restSeconds),
      note: Value(entry.notes),
      attivo: Value(entry.isActive),
      dataCreazione: Value(entry.createdAt ?? timestamp),
      dataModifica: Value(timestamp),
    );
  }
}
