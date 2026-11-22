# Forge — Restyling UX/UI e accessibilità

Autorizzato dall'utente il 22/11/2026 in otto fasi, senza commit o push.
Schema di partenza 14, catalogo 2. Modifiche preesistenti conservate.

**Stato finale:** implementazione e verifiche automatiche concluse; EVO-015
in collaudo utente. Build debug aggiornata e avviata sull'emulatore, tema scuro
selezionato e font Android originale ripristinato. 17 screenshot conservati.

## Fase 1 — Audit

Letti README, registro e documenti pertinenti; verificati router, temi,
onboarding, Home, catalogo, sessioni e Progressi. Home sovraccarica prima di
Oggi; tema scuro forzato; colori statici; diario davanti a immagini e timer.
Emulatore emulator-5554 disponibile. Screenshot acquisito ed esaminato:
`ux_ui/screenshots/before_dark.png` (piano settimanale).
Il tema chiaro precedente non esiste: nessuna baseline chiara simulata.
Nessun test eseguito nella fase di sola analisi.

## Fase 2 — Sistema visivo

Palette Ambra/Blu, contrasti corretti, controlli con minimo 48 dp,
campi, card e bottom sheet condividono il tema. Preferenza persistita tramite
app_settings esistente, osservata anche dopo restore. Nessuna migrazione.
4 test verdi: contrasto testi/azioni per entrambi i temi, layout 320 px e testo
200%. La verifica visiva finale resta da eseguire.

## Vincoli e collaudo

Controller e logica Forge preservati. Sessioni combinate, ordine prima/dopo,
backup e ripresa richiedono regressione automatica finale e collaudo Android.
EVO-015 registrata; EVO-009/010/012 riutilizzate senza sistemi paralleli.
Gli screenshot contengono dati locali di collaudo: rivederli prima di pubblicarli.

## Fase 3 — Home e navigazione

Oggi precede avvio libero e metriche. Le attività hanno pulsanti espliciti e
larghezza piena, nome, stato, conteggio esercizi e durata quando disponibili.
Il riepilogo settimanale riusa weeklyPlanSummaryProvider ed esclude i giorni
di recupero dal denominatore delle attività da completare. Tutti gli accessi
precedenti restano presenti. Gli avvii usano i controller e i collegamenti esistenti.
6 test avvio/ripresa verdi; i test Oggi sono stati aggiornati alle nuove CTA.

## Fase 4 — Onboarding e catalogo

Riutilizzati i sette passaggi e i controller dell'onboarding, aggiunte spiegazioni
per ciascun passaggio e validazione durante l'interazione. Nessuna modifica a
formule, obiettivi persistiti o istruzioni tecniche del catalogo.
Nome, categoria e attrezzatura delle card non sono più troncati. Galleria,
zoom, istruzioni, sicurezza e parametri restano quelli del catalogo.
13 test catalogo verdi; test dettaglio e restore iniziale inclusi nella regressione.

## Fase 5 — Sessione guidata

Diario spostato dopo immagini e timer. Indicati esercizio successivo o camminata,
ultimo esercizio e progresso delle serie con etichetta semantica. I segnaposto
delle serie vanno a capo; riepilogo finale scrollabile e conteggi adattabili.
Controller, countdown, completamento e ordine prima/dopo non modificati.
Test sessione e sessione combinata inclusi nelle verifiche mirate e finali.
Questa parte migliora la presentazione di EVO-012; non introduce le nuove azioni
di ripetizione/salto della singola serie previste nel registro.

## Fase 6 — Progressi e stati

Attività e risultati apre Progressi, con frase riepilogativa derivata dai dati.
Il confronto camminate appare solo per un incremento reale. Il componente
ForgeMessageState riunisce stati vuoti di schede e storici, con azione utile.
Rimosso il doppio ingresso Genera con Forge nello stato vuoto. Aggiunto spazio
di scorrimento per evitare sovrapposizione di CTA e pulsante flottante.
Il feedback di completamento esistente è mantenuto, senza premi inventati.

## Fase 7 — Accessibilità

Testi dei pulsanti secondari scuri usano il blu più chiaro per raggiungere
contrasto 4,5:1; il fondo delle azioni principali resta blu elettrico.
Il testo secondario chiaro usa una variante più scura della palette richiesta.
ThemeSettingsCard è in cima al Profilo; modalità Sistema segue Android, quelle
esplicite restano persistite. Stream osservato anche dopo restore.
4 test tema e 2 test Home/Profilo con schermo 320x640 e testo 200% verdi.
I test non certificano da soli l'intera esperienza TalkBack.

## Fase 8 — Regressione e confronto visivo

Prima esecuzione completa: rilevati test legati a vecchie etichette, posizione
delle azioni e tipo di pulsante; corretti i finder mantenendo i controlli su
sessione attiva, persistenza, collegamenti e dati. Il cleanup del nuovo test
tema è stato corretto per scaricare gli stream Drift fuori dal tempo simulato.
Un avvio parallelo dei test ha incontrato il lock sqlite3.dll: le suite finali
vengono eseguite senza altri runner contemporanei.

L'emulatore è stato aggiornato con flutter run conservando i dati. Richiesto
accesso al lock dell'SDK fuori workspace. Verificati visivamente Home, Profilo
e Progressi; scelta tema effettuata dalla UI. Screenshot in ux_ui/screenshots.
Non esiste un tema chiaro precedente con cui fare un confronto prima/dopo.
La configurazione iniziale è verificata automaticamente, senza azzerare il
profilo reale. TalkBack, comodità durante sforzo e telefono reale richiedono
ancora collaudo manuale. Risultati finali dei comandi da riportare a fine verifica.

### Osservazioni del collaudo

- Esaminati anche catalogo e dettaglio esercizio; la galleria usa contain per
  mostrare la fotografia intera. Le miniature restano cover nelle liste.
- Home chiara verificata con font Android al 200%, screenshot dedicato;
  font_scale ripristinato a 1.0 dopo la prova.
- Durante hot reload sotto carico della suite completa, Android ha mostrato
  un ANR. L'app è stata fermata senza cancellarne i dati e la prova è stata
  ripetuta senza test concorrenti: l'ANR non si è ripresentato durante avvio,
  navigazione, cambio tema e sessione. Resta da monitorare su telefono reale.
- Il warning Gradle relativo a flutter_timezone/Kotlin è preesistente alle
  modifiche UI; la build debug si è conclusa e installata. Nessuna dipendenza
  aggiornata nell'ambito del restyling.

## Verifica automatica finale

- Suite completa finale: **1176 superati, 0 falliti**.
- `flutter analyze --no-pub`: **nessun problema**.
- `git diff --check`: **superato**.
- Nuovi test: `test/core/forge_theme_test.dart` (5) e
  `test/features/ux_accessibility_test.dart` (2).
- Regressioni mantenute su backup, sessioni combinate prima/dopo, pausa/ripresa,
  concorrenza, immagini, generazione, pianificazione e formule.
- Test UI aggiornati ai nuovi controlli, con cleanup esplicito degli stream
  nel Profilo e nella configurazione iniziale. Nessun test disabilitato.
- Schema **14**, catalogo **2**, formato backup invariato.
- Nessun commit/push; `.claude/` non modificata.

### Riprova Android senza test concorrenti

Reinstallata la build debug finale mantenendo i dati. Home, cambio tema,
catalogo e avvio sessione hanno risposto senza riprodurre l'ANR. Verificati
visivamente esercizio, fotografia intera, serie, prescrizione, prossimo esercizio,
pausa e ripresa. Una sessione di collaudo è stata aggiunta e interrotta senza
completare serie: rimane nello storico come interrotta; i record precedenti
non sono stati cancellati. Non è stato simulato il completamento di un'attività.
La conferma di uscita ora spiega che la sessione interrotta resta nello storico.
Per l'ANR osservato durante hot reload sotto carico non è stata dimostrata una
causa nel codice: resta un'osservazione di collaudo, da monitorare su telefono.

## File principali del restyling

| Area | Componenti |
|---|---|
| Sistema visivo | forge_theme.dart, forge_colors.dart, theme_mode_provider.dart, theme_settings_card.dart, app.dart |
| Stati condivisi | core/widgets/forge_message_state.dart |
| Home | dashboard_page.dart, today_planned_activities_card.dart, ready_workout_launcher.dart, weekly_movement_summary.dart |
| Configurazione/catalogo | onboarding_page.dart, exercise_card.dart, galleria e widget immagini, badge disponibilità |
| Sessioni | workout_session_page.dart; colori delle viste camminate, riepiloghi e storico |
| Progressi | progress_page.dart, activity_dashboard_section.dart, colori dei grafici esistenti |
| Test | nuovi forge_theme_test.dart e ux_accessibility_test.dart; aggiornati finder e cleanup nei test UI esistenti |
| Documentazione | README, registro EVO-015, questo report e documenti master allenamenti/Progressi |

Il diff Git include anche le evolutive e i fix precedenti ancora non committati:
quelle modifiche sono state conservate. Il restyling non ha cambiato tabelle,
migrazioni, schema/catalogo, formato backup o algoritmo Forge.

La preferenza assente mantiene il tema scuro legacy, come getThemeMode nel
repository e nei backup. «Sistema» è una scelta esplicita, distinta dall'assenza
del valore. Un test aggiuntivo copre questa compatibilità. Le card non disponibili
non riducono l'opacità dei testi: disponibilità, motivazione e lucchetto restano
espliciti senza peggiorare il contrasto.
