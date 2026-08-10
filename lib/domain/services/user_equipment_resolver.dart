import '../entities/equipment_item.dart';

/// Traduce i codici attrezzatura dell'inventario utente (Milestone 2, es.
/// `resistance_bands`) nei codici del catalogo master (es. `BAND`).
///
/// Il mapping è centralizzato in [EquipmentItem.masterCode]: qui non c'è
/// alcun codice hardcoded. Codici non riconosciuti vengono ignorati (non si
/// inventano attrezzature master inesistenti).
abstract final class UserEquipmentResolver {
  static Set<String> toMasterCodes(Iterable<String> userEquipmentCodes) {
    final result = <String>{};
    for (final code in userEquipmentCodes) {
      final item = EquipmentItem.tryByCode(code);
      if (item != null) result.add(item.masterCode);
    }
    return result;
  }
}
