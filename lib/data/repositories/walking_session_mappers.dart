import 'package:drift/drift.dart';

import '../../domain/entities/walking_session.dart';
import '../../domain/entities/walking_session_status.dart';
import '../database/app_database.dart';

abstract final class WalkingSessionMappers {
  static WalkingSession walkingSession(CamminateTableData row) {
    return WalkingSession(
      id: row.id,
      profileId: row.idProfilo,
      startedAt: row.dataInizio,
      endedAt: row.dataFine,
      distanceMeters: row.distanzaMetri,
      steps: row.passi,
      isPaused: row.pausaInCorso,
      pauseStartedAt: row.dataInizioPausa,
      accumulatedPauseSeconds: row.durataPausaSecondi,
      status: WalkingSessionStatus.fromCode(row.stato),
      notes: row.note,
      createdAt: row.dataCreazione,
      updatedAt: row.dataModifica,
    );
  }

  static CamminateTableCompanion toCompanion(
    WalkingSession session, {
    required DateTime now,
  }) {
    return CamminateTableCompanion(
      id: session.id == null ? const Value.absent() : Value(session.id!),
      idProfilo: Value(session.profileId),
      dataInizio: Value(session.startedAt),
      dataFine: Value(session.endedAt),
      distanzaMetri: Value(session.distanceMeters),
      passi: Value(session.steps),
      pausaInCorso: Value(session.isPaused),
      dataInizioPausa: Value(session.pauseStartedAt),
      durataPausaSecondi: Value(session.accumulatedPauseSeconds),
      stato: Value(session.status.code),
      note: Value(session.notes),
      dataCreazione: Value(session.createdAt ?? now),
      dataModifica: Value(now),
    );
  }

  static CamminateTableCompanion stateChanges({
    required WalkingSessionStatus status,
    required DateTime endedAt,
    required DateTime updatedAt,
    int? distanceMeters,
    int? steps,
    String? notes,
    required bool isPaused,
    required DateTime? pauseStartedAt,
    required int accumulatedPauseSeconds,
  }) {
    return CamminateTableCompanion(
      dataFine: Value(endedAt),
      distanzaMetri: Value(distanceMeters),
      passi: Value(steps),
      pausaInCorso: Value(isPaused),
      dataInizioPausa: Value(pauseStartedAt),
      durataPausaSecondi: Value(accumulatedPauseSeconds),
      stato: Value(status.code),
      note: Value(notes),
      dataModifica: Value(updatedAt),
    );
  }
}
