import 'package:drift/drift.dart';

import '../../domain/entities/planned_activity.dart';
import '../../domain/entities/planned_activity_enums.dart';
import '../database/app_database.dart';

/// Conversioni tra righe Drift e [PlannedActivity], stesso ruolo di
/// `WorkoutMappers` per gli allenamenti.
abstract final class PlannedActivityMappers {
  static PlannedActivity plannedActivity(AttivitaPianificateTableData row) {
    return PlannedActivity(
      id: row.id,
      profileId: row.idProfilo,
      scheduledDate: row.dataPianificata,
      type: PlannedActivityType.fromCode(row.tipo),
      workoutId: row.idAllenamento,
      plannedDurationMinutes: row.durataPianificataMinuti,
      status: PlannedActivityStatus.fromCode(row.stato),
      origin: PlannedActivityOrigin.fromCode(row.origine),
      notes: row.note,
      workoutSessionId: row.idSessioneAllenamento,
      walkingSessionId: row.idSessioneCamminata,
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  static AttivitaPianificateTableCompanion toCompanion(
    PlannedActivity activity, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return AttivitaPianificateTableCompanion(
      id: activity.id == null ? const Value.absent() : Value(activity.id!),
      idProfilo: Value(activity.profileId),
      dataPianificata: Value(activity.scheduledDate),
      tipo: Value(activity.type.code),
      idAllenamento: Value(activity.workoutId),
      durataPianificataMinuti: Value(activity.plannedDurationMinutes),
      stato: Value(activity.status.code),
      origine: Value(activity.origin.code),
      note: Value(activity.notes),
      idSessioneAllenamento: Value(activity.workoutSessionId),
      idSessioneCamminata: Value(activity.walkingSessionId),
      dataCreazione: Value(activity.createdAt ?? timestamp),
      dataModifica: Value(timestamp),
    );
  }
}
