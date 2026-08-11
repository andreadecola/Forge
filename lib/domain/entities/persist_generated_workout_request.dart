import 'forge_generation_result.dart';

/// Richiesta di persistenza di un piano generato (Milestone 5.3).
///
/// Porta l'intero [ForgeGenerationResult] (non solo il piano): i primi due
/// controlli richiesti dalla milestone — "verificare
/// ForgeGenerationResult success" e "verificare plan != null" — non sono
/// altrimenti verificabili con un semplice campo `plan`. Un secondo campo
/// `success` passato separatamente potrebbe divergere dal risultato
/// originale; portare l'intero risultato lo rende impossibile per
/// costruzione.
class PersistGeneratedWorkoutRequest {
  const PersistGeneratedWorkoutRequest({
    required this.profileId,
    required this.generationResult,
    this.name,
    this.description,
  });

  final int profileId;
  final ForgeGenerationResult generationResult;

  /// Se `null`, `ForgeWorkoutNamingPolicy` genera un nome default
  /// deterministico dal `WorkoutType` del piano.
  final String? name;

  /// Se `null`, nessuna descrizione tecnica viene inventata (sezione 22):
  /// resta `null` sul `Workout` persistito, come già consentito dal campo.
  final String? description;
}
