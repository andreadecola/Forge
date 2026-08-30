# FORGE

Forge è un coach personale offline-first per allenamento domestico,
camminata e monitoraggio dei progressi.

## Cosa fa Forge

L'app permette di:

- configurare e modificare il proprio profilo e i dati corporei iniziali;
- consultare un catalogo locale di esercizi con descrizioni, istruzioni,
  progressioni, alternative e requisiti di attrezzatura;
- creare workout personalizzati e svolgere sessioni guidate;
- generare proposte di allenamento tramite Forge Engine;
- registrare camminate con timer, pause, fatica e dolore;
- pianificare workout, camminate e recuperi in una vista settimanale;
- vedere le attività previste per oggi e collegarle alle sessioni realmente
  eseguite;
- monitorare peso, girovita e pressione arteriosa con storico, riepiloghi e
  grafici descrittivi;
- gestire attrezzatura e budget;
- esportare e importare i dati personali tramite backup JSON locale.

I dati restano sul dispositivo. Il catalogo esercizi è ricostruibile dal seed
locale e non viene incluso nel backup. Al primo avvio è possibile configurare
Forge oppure ripristinare direttamente un backup senza creare un profilo
temporaneo.

## Backup e ripristino

**BACKUP/RESTORE COMPLETATO E COLLAUDATO END-TO-END** (Backup.1-6).
Il ciclo reale export su file esterno → disinstallazione → reinstallazione
→ ripristino dalla prima configurazione è stato verificato con successo.

Il backup protegge il profilo, le impostazioni, l'attrezzatura, le
misurazioni, la pressione, workout e sessioni, camminate e Piano Settimanale.
Il ripristino è atomico, validato e con rollback in caso di errore. Quando
l'app è già configurata, l'import richiede una conferma esplicita prima di
sostituire i dati attuali.

## Baseline tecnica

- `schemaVersion`: **11**;
- `flutter analyze`: **0 issue**;
- `flutter test`: **1009/1009 passati**;
- Flutter, Dart, Riverpod, Drift, SQLite e go_router;
- grafici con `fl_chart`;
- storage backup Android tramite Storage Access Framework e `file_picker`;
- nessun permesso storage legacy richiesto;
- nessun server necessario per il funzionamento locale.

## Sviluppo

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

La documentazione tecnica delle milestone e delle aree funzionali è nella
cartella `Docs`.
