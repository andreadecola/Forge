/// Parametro sesso richiesto dalla formula di Mifflin-St Jeor.
///
/// Persistito solo quando l'utente sceglie esplicitamente di fornirlo.
/// La scelta "preferisco non specificarlo" in onboarding corrisponde
/// all'assenza di questo valore (null), non a un terzo stato salvato.
enum BiologicalSexForFormula { male, female }
