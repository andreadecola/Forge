/// Value type per la programmazione settimanale (Milestone 8.1).
///
/// Stesso pattern di `workout_enums.dart`/`exercise_catalog_enums.dart`: ogni
/// enum espone [code], la stringa stabile persistita nelle colonne SQLite,
/// mentre i nomi Dart restano idiomatici (lowerCamelCase).
library;

/// Tipo di attività pianificata. **Non va confuso con `WorkoutType.recovery`**
/// (Milestone 4): quello è un tipo di allenamento leggero, eseguibile come
/// scheda vera e propria; [recovery] qui è un giorno di riposo pianificato,
/// senza alcuna scheda né sessione collegata (sezione 17 della Milestone
/// 8.1).
enum PlannedActivityType {
  workout('WORKOUT'),
  walk('WALK'),
  recovery('RECOVERY');

  const PlannedActivityType(this.code);

  final String code;

  static PlannedActivityType fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

/// Stato persistito dell'attività pianificata (Milestone 8.6, sezione 5/22).
///
/// Il "completamento" **non** è uno stato qui: si deriva sempre dalla
/// sessione reale collegata (`PlannedActivitySessionState`, Milestone 8.5),
/// mai da un valore scritto su questa colonna — vedi
/// `PlannedActivityPresentation.displayState`.
///
/// Non esiste un valore `MOVED`: "spostare" un'attività è solo un cambio di
/// [PlannedActivity.scheduledDate] (vedi `UpdatePlannedActivity`), mai un
/// nuovo stato persistito — introdurne uno avrebbe richiesto uno storico
/// degli spostamenti che nessuna milestone documentata richiede (sezione
/// 6/17/18).
///
/// [skipped]/[postponed] sono **sempre** una decisione esplicita
/// dell'utente (azioni "Salta"/"Rinvia"): mai dedotti automaticamente da
/// `scheduledDate < oggi` (vietato esplicitamente, sezione 9/107) — vedi
/// `SkipPlannedActivity`/`PostponePlannedActivity`.
enum PlannedActivityStatus {
  planned('PLANNED'),
  skipped('SKIPPED'),
  postponed('POSTPONED');

  const PlannedActivityStatus(this.code);

  final String code;

  static PlannedActivityStatus fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}

/// Chi ha creato l'attività pianificata. Enum dedicato (non si riusa
/// `WorkoutOrigin`, sezione 29): stesso significato concettuale di
/// USER/FORGE_ENGINE, ma i due concetti (origine di una scheda, origine di
/// un'attività pianificata) potrebbero divergere in futuro — nessun
/// accoppiamento tra i due moduli. Nessun valore `system`: a differenza di
/// `WorkoutOrigin.system` (mai usato nemmeno lì), qui non esiste alcun caso
/// d'uso per un'attività pianificata "di sistema".
enum PlannedActivityOrigin {
  user('USER'),
  forgeEngine('FORGE_ENGINE');

  const PlannedActivityOrigin(this.code);

  final String code;

  static PlannedActivityOrigin fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
