import '../backup_date_codec.dart';
import '../backup_json_helpers.dart';

/// Riga di `attrezzature_utente` (Backup.1, sezione 1). [equipmentCode] è
/// già il codice utente stabile persistito (`EquipmentItem.code`, es.
/// `"chair"`) — mai una FK numerica verso il catalogo master, stesso
/// pattern già seguito dal codice reale (Backup.1, sezione 5).
class BackupUserEquipment {
  const BackupUserEquipment({
    required this.localId,
    required this.profileLocalId,
    required this.equipmentCode,
    required this.owned,
    required this.acquiredAt,
    required this.notes,
  });

  final int localId;
  final int profileLocalId;
  final String equipmentCode;
  final bool owned;
  final DateTime? acquiredAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'profileLocalId': profileLocalId,
    'equipmentCode': equipmentCode,
    'owned': owned,
    'acquiredAt': BackupDateCodec.encodeTimestampOrNull(acquiredAt),
    'notes': notes,
  };

  static BackupUserEquipment fromJson(Map<String, dynamic> json, String path) {
    return BackupUserEquipment(
      localId: requireInt(json, 'localId', path),
      profileLocalId: requireInt(json, 'profileLocalId', path),
      equipmentCode: requireString(json, 'equipmentCode', path),
      owned: requireBool(json, 'owned', path),
      acquiredAt: BackupDateCodec.decodeTimestampOrNull(
        optionalString(json, 'acquiredAt', path),
      ),
      notes: optionalString(json, 'notes', path),
    );
  }
}
