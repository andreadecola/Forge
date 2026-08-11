import '../entities/forge_request.dart';

/// Normalizza una [ForgeRequest] (Milestone 5.1, sezione 10): rimuove
/// duplicati e stabilizza l'ordinamento dei codici attrezzatura, così
/// richieste "equivalenti" (stessi codici, ordine diverso) producono
/// sempre lo stesso stato interno — nessuna interrogazione al DB, nessuna
/// validazione qui (quella è responsabilità di [ForgeRequestValidator]).
abstract final class ForgeRequestNormalizer {
  static ForgeRequest normalize(ForgeRequest request) {
    // `Set<String>` già rimuove i duplicati; l'ordinamento (irrilevante
    // per l'uguaglianza logica di un Set, ma reso comunque stabile qui)
    // evita che l'iterazione dipenda dall'ordine di inserimento originale
    // in punti del motore che iterano questo campo.
    final sortedEquipment = request.availableEquipmentCodes.toList()..sort();

    return ForgeRequest(
      profileId: request.profileId,
      userLevel: request.userLevel,
      availableEquipmentCodes: sortedEquipment.toSet(),
      targetDurationMinutes: request.targetDurationMinutes,
      workoutType: request.workoutType,
    );
  }
}
