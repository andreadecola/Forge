import 'workout_enums.dart';

/// Richiesta di generazione al Forge Engine (Milestone 5.1). Solo dati di
/// input: nessuna logica, nessuna dipendenza da repository/DB.
///
/// Nessun campo "seed" per la casualità: il motore non usa mai `Random()`
/// (sezione 42) — non c'è nulla da rendere deterministico con un seed,
/// perché non c'è alcuna fonte di non-determinismo da controllare.
class ForgeRequest {
  const ForgeRequest({
    required this.profileId,
    required this.userLevel,
    required this.availableEquipmentCodes,
    required this.targetDurationMinutes,
    required this.workoutType,
  });

  final int profileId;
  final int userLevel;

  /// Codici attrezzatura **master** (già risolti da `UserEquipmentResolver`
  /// a monte, a cura del chiamante — sezione 8): il motore non traduce
  /// codici utente, riceve solo codici master.
  final Set<String> availableEquipmentCodes;

  final int targetDurationMinutes;
  final WorkoutType workoutType;
}
