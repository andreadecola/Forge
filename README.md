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
- configurare reminder locali per workout e camminate pianificati;
- ricostruire i reminder dopo startup, restore, resume e cambio timezone;
- vedere le attività previste per oggi e collegarle alle sessioni realmente
  eseguite;
- pianificare settimane con schede e camminate nei giorni scelti, anche
  manualmente, con anteprima e verifica delle sovrapposizioni;
- eliminare camminate concluse e schede preservando lo storico degli allenamenti;
- annotare prestazioni effettive per serie e confrontare attività settimanali
  e mensili nella pagina Progressi;
- monitorare peso, girovita e pressione arteriosa con storico, riepiloghi e
  grafici descrittivi;
- gestire attrezzatura e budget;
- esportare e importare i dati personali tramite backup JSON locale.

I dati restano sul dispositivo. Il catalogo esercizi è ricostruibile dal seed
locale e non viene incluso nel backup. Al primo avvio è possibile configurare
Forge oppure ripristinare direttamente un backup senza creare un profilo
temporaneo.

La generazione Forge consente di selezionare uno o più livelli tra 1 e 5.
L'eleggibilità mantiene i vincoli di livello minimo/massimo, attrezzatura,
stato attivo e adattamento; la selezione multipla non forza un esercizio per
livello e non aumenta automaticamente durata o volume. La specifica tecnica è
in `Docs/FORGE_ENGINE_Multilevel.md`.

Ogni schermata che mostra esercizi individuali risolve la miniatura fotografica
START tramite il componente condiviso `ExerciseImageThumbnail` e il catalogo
locale SQLite; il fallback compare solo se l'asset manca o non è caricabile.

Gli allenamenti manuali e quelli generati possono conservare più livelli
selezionati. `Workout.level` resta il massimo numerico legacy, mentre il set
completo è persistito in `allenamenti.livelli` dalla schemaVersion 12; le
schede precedenti vengono lette come monolivello senza perdita di dati.

Il backup JSON conserva l'intera selezione multilivello e legge i backup
precedenti tramite il livello legacy. La protezione degli avvii concorrenti e
il ripristino dei timer sono documentati in
[Hardening backup e sessioni](Docs/HARDENING_Backup_And_Sessions.md).

Le evolutive EVO-001–010 autorizzate (escluse 007/008) sono descritte in
[Evolutive 001–010](Docs/EVOLUTIVE_001_010.md). Lo schema 13 aggiunge diario
prestazioni e rinvio persistente dei promemoria. Lo schema corrente è 14:
la camminata può far parte della stessa scheda, prima o dopo gli esercizi,
con gli stessi giorni pianificati e ripresa persistente. La Home espone
«Pianifica allenamento» sotto «Inizia allenamento». Il catalogo resta alla versione 2.
Il collaudo Android complessivo è ancora da effettuare.

Il restyling UX/UI introduce i temi Ambra sportiva e Blu elettrico con scelta
Chiaro/Scuro/Sistema nel Profilo. La Home mette in primo piano le attività di
oggi; sessioni, catalogo e Progressi riutilizzano dati e logica esistenti.
Specifica, evidenze e limiti: [Restyling UX/UI](Docs/UX_UI_Restyling.md).


