/// Stato di disponibilità di un esercizio per l'utente.
///
/// In Milestone 3.3 hanno logica solo [available], [lockedLevel],
/// [lockedEquipment]. Gli altri esistono per la futura logica del Forge
/// Engine (Milestone dedicata) ma non vengono ancora prodotti.
enum ExerciseAvailabilityStatus {
  recommended,
  available,
  lockedLevel,
  lockedEquipment,
  temporarilyAvoided,
  mastered,
}
