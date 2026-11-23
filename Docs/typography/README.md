# Forge — Confronto tipografico preliminare

Stato: **Inter unico font approvato e applicato il 23 novembre 2026**.
La build normale usa Inter e la scala centralizzata. Nessun dato, algoritmo,
database, backup o preferenza del font viene modificato dalle anteprime.

## Audit

Il tema esistente usa la tipografia Material senza famiglia personalizzata:
su Android il riferimento è Roboto. Gli stili erano principalmente derivati
da TextTheme, con dimensioni locali a 11, 12 e 16 sp. Badge e numeri a 11 sp,
etichette rapide a 11 sp e titoli con peso non uniforme riducono la gerarchia.
I pulsanti principali avevano 16 sp espliciti; quelli secondari seguivano i
valori Material. Il timer camminata ha un FittedBox: va rivalutato sulla
famiglia scelta per evitare riduzioni eccessive nelle durate lunghe.
Il selettore delle schede conserva ellipsis per i nomi nel menu; i nomi delle
card catalogo e dell'esercizio corrente sono già a capo senza troncamento.

## Scala proposta, uguale per i tre confronti

| Ruolo | Dimensione | Peso | Altezza riga | Spaziatura |
|---|---:|---:|---:|---:|
| Titolo pagina | 28 sp | 700 | 1,25 | −0,3 sp |
| Titolo sezione | 26 sp | 700 | 1,25 | −0,2 sp |
| Titolo card | 20 sp | 600 | 1,30 | 0 |
| Sottotitolo | 18 sp | 600 | 1,35 | 0 |
| Corpo | 16 sp | 400 | 1,50 | 0 |
| Secondario | 14 sp | 400 | 1,45 | 0 |
| Badge | 12–13 sp | 600 | 1,30 | 0 |
| Pulsante | 16 sp | 600 | 1,30 | 0 |
| Timer | 40 / 48 / 56 sp | 700 | 1,15 | cifre tabulari |

Definizione centralizzata in `lib/core/theme/forge_typography.dart`.
I valori locali sono collegati ai token approvati: badge 13 sp, didascalie 13 sp e secondari 14 sp.
Non sono stati introdotti clamp o sostituzioni del text scaling Android.
La toolbar dell'anteprima è più alta per ospitare titoli grandi; la stessa
altezza è usata con tutti i font.

## Metodo

Screenshot reali ADB su emulator-5554. Identiche schermate, dati, tema e scala;
cambia la famiglia, tramite build debug separate. Nessuna ricostruzione grafica
degli screenshot. Il confronto Manrope usa una famiglia unica per consentire
un confronto controllato; l'eventuale abbinamento Manrope titoli / Inter corpo
richiede una scelta successiva.

Comando per una variante (sostituire Inter con Roboto o Manrope):

```powershell
flutter run -d emulator-5554 --dart-define=FORGE_TYPOGRAPHY_PREVIEW=true --dart-define=FORGE_TYPOGRAPHY_FAMILY=Inter
```

Senza questi define l'app mantiene il font e le dimensioni precedenti.

## Font locali e licenze

File scaricati dal repository Google Fonts, con le rispettive licenze OFL
conservate in `assets/fonts/preview` e incluse nel bundle. Nessun caricamento
web a runtime e nessuna dipendenza aggiuntiva.

- [Inter: fonte](https://github.com/google/fonts/tree/main/ofl/inter),
  [licenza](https://github.com/google/fonts/blob/main/ofl/inter/OFL.txt).
- [Manrope: fonte](https://github.com/google/fonts/tree/main/ofl/manrope),
  [licenza](https://github.com/google/fonts/blob/main/ofl/manrope/OFL.txt).
  Il confronto usa la versione OFL di Google Fonts, non altre distribuzioni.

SHA-256 degli asset acquisiti:

```text
Inter.ttf   29160A80FF49DDCAB2C97711247E08B1FAB27A484A329CE8B813D820DC559031
Manrope.ttf 3AE11C49DB0455A3CC33E37D380F20FDB8C7F8B41DC07625C177E3D87A9D6AE6
```

## Verifiche

Prima verifica normale: 17 test verdi (scala, font caricabili, contrasto e
Home/Profilo). Anteprima Inter: 23 test verdi, comprese sessioni combinate
prima/dopo, ripresa e backup. Un finder è stato corretto per portare la CTA
completamente sopra la barra di navigazione prima del tap. Nessun test disabilitato.
Anteprima Manrope: 12 test verdi. Regressione normale su catalogo, dettaglio
esercizio, sessione, generazione settimanale e progressi: 60 test verdi.
`flutter analyze --no-pub`: nessun problema. `git diff --check`: superato.
La suite completa non è stata rieseguita per questa anteprima.

## Confronto visivo

Aprire [confronto.html](confronto.html) nel browser: 18 screenshot reali,
sei viste per ciascuna famiglia. Home nei due temi, catalogo chiaro,
pianificazione, progressi e Profilo scuri. Le immagini sono a scala Android
100%; i controlli 320 px / 200% sono test widget, non collaudo completo
di ogni schermata sull'emulatore. La baseline separata conserva le dimensioni
precedenti. Le catture delle tre varianti risalgono al 22 novembre 2026.

Proposta: Inter come unica famiglia, per una gerarchia chiara e uniforme.
Manrope offre un aspetto più arrotondato; l'abbinamento ai soli titoli
resta un'opzione da confermare. L'applicazione definitiva a tutte le schermate,
compresa la sessione, attende la scelta dell'utente dopo il confronto.

## Dopo la scelta

Applicare una sola soluzione a tutte le schermate, completare l'associazione
dei testi secondari ai rispettivi ruoli e rifinire i casi di nomi lunghi,
toolbar e timer su telefono. Eliminare le famiglie non scelte dal bundle.
La selezione del tema e le palette Ambra/Blu rimangono quelle già approvate.
Commit e push non effettuati.

## Scelta definitiva — 23 novembre 2026

L'utente ha scelto Inter come unica famiglia e richiesto di fermare il lavoro
al termine di questa applicazione. Inter e la scala proposta sono ora attivi
in entrambe le palette, per avvio normale e release. I define di anteprima
non sono più necessari e non controllano il tema dell'app.
Manrope è escluso dal bundle; i confronti precedenti restano come storico.
Le sezioni sul metodo di anteprima sopra descrivono il confronto precedente,
non le istruzioni correnti di avvio. Usare semplicemente `flutter run`.
Nessuna modifica a logica applicativa, database, backup o algoritmi.
I nomi lunghi nei menu e il FittedBox del timer camminata rimangono punti
di rifinitura documentati; nessun collaudo completo di tutte le schermate
al 200% sull'emulatore viene dichiarato.
Verifica della configurazione definitiva: 82 test mirati/regressione superati, 0 falliti. Include temi, tipografia, accessibilità, sessioni combinate, catalogo, dettaglio esercizio, sessione, pianificazione e progressi. Suite completa non rieseguita in questa attività. Commit e push: NO.

Analisi finale Inter: flutter analyze --no-pub, nessun problema (177,2 s). git diff --check: superato. Home definitiva verificata visivamente sull'emulatore e conservata in screenshots/home_Inter_final_dark.png. Lavoro fermato su richiesta dell'utente.
