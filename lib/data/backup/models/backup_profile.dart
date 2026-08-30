import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `profili_utente` (Backup.1, sezione 1). [localId] è l'id
/// originale, usato **solo** per risolvere i riferimenti interni dentro
/// questo stesso file di backup (`profileLocalId` in ogni altra
/// collezione) — non implica che un futuro restore lo reinserisca come
/// PK (Backup.1, sezione 9).
///
/// [biologicalSexForFormula]/[activityLevel] sono la stringa **così
/// com'è realmente persistita** (`.name` camelCase, non `.code`
/// SCREAMING_SNAKE_CASE — l'eccezione già documentata in Backup.1,
/// sezione 3): nessuna normalizzazione silenziosa qui, la validazione di
/// riconoscibilità del valore spetta a `BackupValidator`.
class BackupProfile {
  const BackupProfile({
    required this.localId,
    required this.name,
    required this.birthDate,
    required this.biologicalSexForFormula,
    required this.heightCm,
    required this.initialWeightKg,
    required this.targetWeightKg,
    required this.preferredWalkMinutes,
    required this.equipmentBudgetLimit,
    required this.startDate,
    required this.activityLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  final int localId;
  final String name;
  final DateTime birthDate;
  final String? biologicalSexForFormula;
  final double heightCm;
  final double initialWeightKg;
  final double? targetWeightKg;
  final int preferredWalkMinutes;
  final double equipmentBudgetLimit;
  final DateTime startDate;
  final String activityLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'name': name,
    'birthDate': BackupDateCodec.encodeDateOnly(birthDate),
    'biologicalSexForFormula': biologicalSexForFormula,
    'heightCm': heightCm,
    'initialWeightKg': initialWeightKg,
    'targetWeightKg': targetWeightKg,
    'preferredWalkMinutes': preferredWalkMinutes,
    'equipmentBudgetLimit': equipmentBudgetLimit,
    'startDate': BackupDateCodec.encodeDateOnly(startDate),
    'activityLevel': activityLevel,
    'createdAt': BackupDateCodec.encodeTimestampOrNull(createdAt),
    'updatedAt': BackupDateCodec.encodeTimestampOrNull(updatedAt),
  };

  static BackupProfile fromJson(Map<String, dynamic> json, String path) {
    return BackupProfile(
      localId: requireInt(json, 'localId', path),
      name: requireString(json, 'name', path),
      birthDate: BackupDateCodec.decodeDateOnly(
        requireString(json, 'birthDate', path),
      ),
      biologicalSexForFormula: optionalString(
        json,
        'biologicalSexForFormula',
        path,
      ),
      heightCm: requireDouble(json, 'heightCm', path),
      initialWeightKg: requireDouble(json, 'initialWeightKg', path),
      targetWeightKg: optionalDouble(json, 'targetWeightKg', path),
      preferredWalkMinutes: requireInt(json, 'preferredWalkMinutes', path),
      equipmentBudgetLimit: requireDouble(json, 'equipmentBudgetLimit', path),
      startDate: BackupDateCodec.decodeDateOnly(
        requireString(json, 'startDate', path),
      ),
      activityLevel: requireString(json, 'activityLevel', path),
      createdAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'createdAt', path),
      ),
      updatedAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'updatedAt', path),
      ),
    );
  }
}
