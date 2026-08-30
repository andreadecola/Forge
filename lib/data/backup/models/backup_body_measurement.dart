import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `misurazioni_corporee` (Backup.1, sezione 1). [weightKg] e
/// tutte le circonferenze sono nullable indipendentemente (dallo schema
/// 8, Milestone 7.2): `null` qui significa sempre "non misurato", mai un
/// valore reale di 0 (Backup.1, sezione 7.4).
class BackupBodyMeasurement {
  const BackupBodyMeasurement({
    required this.localId,
    required this.profileLocalId,
    required this.measuredAt,
    required this.weightKg,
    required this.neckCm,
    required this.chestCm,
    required this.waistCm,
    required this.abdomenCm,
    required this.hipsCm,
    required this.leftArmCm,
    required this.rightArmCm,
    required this.leftThighCm,
    required this.rightThighCm,
    required this.leftCalfCm,
    required this.rightCalfCm,
    required this.notes,
  });

  final int localId;
  final int profileLocalId;
  final DateTime measuredAt;
  final double? weightKg;
  final double? neckCm;
  final double? chestCm;
  final double? waistCm;
  final double? abdomenCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;
  final double? leftCalfCm;
  final double? rightCalfCm;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'measuredAt': BackupDateCodec.encodeTimestamp(measuredAt),
    'weightKg': weightKg,
    'neckCm': neckCm,
    'chestCm': chestCm,
    'waistCm': waistCm,
    'abdomenCm': abdomenCm,
    'hipsCm': hipsCm,
    'leftArmCm': leftArmCm,
    'rightArmCm': rightArmCm,
    'leftThighCm': leftThighCm,
    'rightThighCm': rightThighCm,
    'leftCalfCm': leftCalfCm,
    'rightCalfCm': rightCalfCm,
    'notes': notes,
  };

  static BackupBodyMeasurement fromJson(
    Map<String, dynamic> json,
    String path,
  ) {
    return BackupBodyMeasurement(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      measuredAt: BackupDateCodec.decodeTimestamp(
        requireString(json, 'measuredAt', path),
      ),
      weightKg: optionalDouble(json, 'weightKg', path),
      neckCm: optionalDouble(json, 'neckCm', path),
      chestCm: optionalDouble(json, 'chestCm', path),
      waistCm: optionalDouble(json, 'waistCm', path),
      abdomenCm: optionalDouble(json, 'abdomenCm', path),
      hipsCm: optionalDouble(json, 'hipsCm', path),
      leftArmCm: optionalDouble(json, 'leftArmCm', path),
      rightArmCm: optionalDouble(json, 'rightArmCm', path),
      leftThighCm: optionalDouble(json, 'leftThighCm', path),
      rightThighCm: optionalDouble(json, 'rightThighCm', path),
      leftCalfCm: optionalDouble(json, 'leftCalfCm', path),
      rightCalfCm: optionalDouble(json, 'rightCalfCm', path),
      notes: optionalString(json, 'notes', path),
    );
  }
}
