import '../entities/forge_category_tier.dart';
import '../entities/forge_coverage_requirement.dart';
import '../entities/workout_enums.dart';
import 'forge_workout_type_policy.dart';

/// Copertura per categoria richiesta/preferita per ogni `WorkoutType`
/// (Milestone 5.2, sezioni 15/16/23-26/44/45).
///
/// Modella **due livelli distinti**, per risolvere la tensione tra
/// `ForgeGenerationWarning.missingPreferredCoverage` (avviso) e
/// `ForgeGenerationError.missingRequiredCoverage` (errore bloccante):
///
/// - **Obbligatoria** ([requiredCoverageFor]): un piccolo elenco esplicito
///   di [ForgeCoverageRequirement], minimo e deliberatamente conservativo
///   — solo raggruppamenti del tema centrale già preferito per quel tipo
///   in [ForgeWorkoutTypePolicy] (es. RECOVERY richiede almeno un
///   esercizio tra `MOBILITA`/`STRETCHING`/`EQUILIBRIO`). Se non
///   soddisfatta, il piano non può dirsi riuscito.
/// - **Preferita** ([preferredCategoriesFor]): **derivata dal vivo** dalle
///   categorie già marcate `preferred` in [ForgeWorkoutTypePolicy] — non è
///   una seconda mappa duplicata, è la stessa fonte di verità della
///   Milestone 5.1 letta da una prospettiva diversa (composizione invece
///   che punteggio). Se una categoria preferita resta a zero esercizi
///   selezionati, è solo un avviso non bloccante.
///
/// Usa solo i codici di categoria reali già verificati in Milestone 5.1
/// (STOP 4) — nessuna categoria nuova viene introdotta qui.
abstract final class ForgeWorkoutTypeCoveragePolicy {
  static const Map<WorkoutType, List<ForgeCoverageRequirement>>
  _requiredCoverage = {
    // CORE non è un requisito obbligatorio qui (a differenza della prima
    // versione di questa policy): sul catalogo reale, a livello 1 e senza
    // attrezzatura, zero esercizi CORE sono eleggibili — un requisito
    // obbligatorio lo avrebbe reso strutturalmente insoddisfacibile per
    // una combinazione realistica e comune (principiante, nessuna
    // attrezzatura). CORE resta comunque `preferred` in
    // `ForgeWorkoutTypePolicy`: la sua eventuale assenza risulta nel
    // warning non bloccante `missingPreferredCoverage`, non nell'errore
    // `missingRequiredCoverage`. Le due metà del corpo restano invece un
    // requisito genuino di "full body".
    WorkoutType.fullBody: [
      ForgeCoverageRequirement(categoryCodes: {'GAMBE_GLUTEI'}),
      ForgeCoverageRequirement(
        categoryCodes: {'PETTO_SPINTA', 'SCHIENA', 'SPALLE', 'BRACCIA'},
      ),
    ],
    WorkoutType.upperBody: [
      ForgeCoverageRequirement(
        categoryCodes: {'PETTO_SPINTA', 'SCHIENA', 'SPALLE', 'BRACCIA'},
      ),
    ],
    WorkoutType.lowerBody: [
      ForgeCoverageRequirement(categoryCodes: {'GAMBE_GLUTEI'}),
    ],
    WorkoutType.mobility: [
      ForgeCoverageRequirement(
        categoryCodes: {'MOBILITA', 'STRETCHING', 'EQUILIBRIO'},
      ),
    ],
    WorkoutType.cardio: [
      ForgeCoverageRequirement(categoryCodes: {'CARDIO'}),
    ],
    WorkoutType.recovery: [
      ForgeCoverageRequirement(
        categoryCodes: {'MOBILITA', 'STRETCHING', 'EQUILIBRIO'},
      ),
    ],
  };

  /// I requisiti di copertura obbligatoria per [workoutType], in ordine
  /// stabile dichiarato (usato da `ForgeWorkoutComposer` come ordine della
  /// Fase A). Lancia se [workoutType] non è supportato dal motore
  /// (`WorkoutType.custom`), stesso comportamento di
  /// [ForgeWorkoutTypePolicy.tierFor].
  static List<ForgeCoverageRequirement> requiredCoverageFor(
    WorkoutType workoutType,
  ) {
    final requirements = _requiredCoverage[workoutType];
    if (requirements == null) {
      throw ArgumentError.value(
        workoutType,
        'workoutType',
        'Nessuna policy di copertura Forge per questo WorkoutType (CUSTOM '
            'non è generabile dal motore, sezione 32).',
      );
    }
    return requirements;
  }

  /// Le categorie con tier `preferred` per [workoutType], lette dal vivo da
  /// [ForgeWorkoutTypePolicy] (nessuna mappa duplicata).
  static Set<String> preferredCategoriesFor(WorkoutType workoutType) =>
      ForgeWorkoutTypePolicy.categoriesWithTier(
        workoutType: workoutType,
        tier: ForgeCategoryTier.preferred,
      );
}
