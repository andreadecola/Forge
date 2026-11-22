# Forge — Confronto tipografico preliminare

Stato: **scelta del font in attesa dell'utente**. Nessun font definitivo applicato.
La build normale mantiene la tipografia precedente. Nessun dato, algoritmo,
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
I valori hardcoded sono collegati ai token: nella build normale conservano
le misure precedenti, nell'anteprima si attivano quelle proposte.
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
Gli esiti conclusivi e l'indice immagini vengono aggiunti dopo l'acquisizione.

## Dopo la scelta

Applicare una sola soluzione a tutte le schermate, completare l'associazione
dei testi secondari ai rispettivi ruoli e rifinire i casi di nomi lunghi,
toolbar e timer su telefono. Eliminare le famiglie non scelte dal bundle.
La selezione del tema e le palette Ambra/Blu rimangono quelle già approvate.
Commit e push non effettuati.
