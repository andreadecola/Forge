import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_enums.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_walking_block.dart';
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
      selectedLevels: _decodeLevels(row.livelli, fallback: row.livello),
      estimatedDurationMinutes: row.durataStimataMinuti,
      walkingBlock: WorkoutWalkingBlock.fromStorage(row.camminata),
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
      livelli: Value(_encodeLevels(workout.effectiveSelectedLevels)),
      durataStimataMinuti: Value(workout.estimatedDurationMinutes),
      camminata: Value(workout.walkingBlock?.encode()),
      stato: Value(workout.status.code),
      origine: Value(workout.origin.code),
      attivo: Value(workout.isActive),
      dataCreazione: Value(workout.createdAt ?? timestamp),
      dataModifica: Value(timestamp),
    );
  }

  static Set<int> _decodeLevels(String? raw, {required int fallback}) {
    if (raw == null || raw.trim().isEmpty) return {fallback};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final levels = decoded.whereType<num>().map((e) => e.toInt()).toSet();
        if (levels.isNotEmpty) return levels;
      }
    } on FormatException {
      // Le righe legacy non hanno JSON: il fallback mantiene il livello noto.
    }
    return {fallback};
  }

  static String _encodeLevels(Set<int> levels) {
    final sorted = levels.toList()..sort();
    return jsonEncode(sorted);
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
