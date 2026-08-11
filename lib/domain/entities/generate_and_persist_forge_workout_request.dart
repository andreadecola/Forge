import 'forge_request.dart';

/// Input del use case combinato `GenerateAndPersistForgeWorkout`
/// (Milestone 5.3, sezione 30/31): compone `GenerateForgeWorkout` e
/// `PersistGeneratedWorkout` senza sostituirli — restano entrambi
/// disponibili e componibili separatamente.
class GenerateAndPersistForgeWorkoutRequest {
  const GenerateAndPersistForgeWorkoutRequest({
    required this.forgeRequest,
    required this.profileId,
    this.name,
    this.description,
  });

  final ForgeRequest forgeRequest;

  /// Profilo per cui persistere la scheda — passato esplicitamente
  /// (anziché riusare `forgeRequest.profileId`, che il motore usa solo
  /// internamente) così che il chiamante decida sempre a chi appartiene
  /// la scheda salvata, indipendentemente da come [forgeRequest] è stato
  /// costruito.
  final int profileId;

  final String? name;
  final String? description;
}
