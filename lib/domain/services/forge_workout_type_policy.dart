import '../entities/forge_category_tier.dart';
import '../entities/workout_enums.dart';

/// Rilevanza delle categorie del catalogo per ogni `WorkoutType`
/// supportato dal Forge Engine (Milestone 5.1, sezione 25-32).
///
/// Usa solo i **codici reali** delle categorie seedate in
/// `assets/data/exercises_v1.json` (verificati sui dati effettivi, non
/// inventati): `MOBILITA`, `GAMBE_GLUTEI`, `PETTO_SPINTA`, `SCHIENA`,
/// `SPALLE`, `BRACCIA`, `CORE`, `EQUILIBRIO`, `CARDIO`, `STRETCHING` — vedi
/// 06_Exercise_Catalog.md per il vocabolario documentato.
///
/// `WorkoutType.custom` non ha una policy (sezione 32: rappresenta una
/// composizione manuale, non generabile dal motore — rifiutato a monte da
/// `ForgeRequestValidator`, [tierFor] non viene mai chiamato con quel
/// tipo).
///
/// Basata solo sulla **categoria** dell'esercizio, non sui gruppi
/// muscolari: la categoria è già il segnale pensato apposta per
/// classificare l'orientamento di un esercizio (es. `GAMBE_GLUTEI`),
/// mentre i gruppi muscolari sono un dettaglio più granulare pensato per
/// la scheda esercizio (Milestone 3.x), non per questa distinzione —
/// usarli entrambi introdurrebbe un secondo asse di classificazione
/// ridondante.
abstract final class ForgeWorkoutTypePolicy {
  static const Map<WorkoutType, Map<String, ForgeCategoryTier>> _policies = {
    WorkoutType.fullBody: {
      'GAMBE_GLUTEI': ForgeCategoryTier.preferred,
      'PETTO_SPINTA': ForgeCategoryTier.preferred,
      'SCHIENA': ForgeCategoryTier.preferred,
      'SPALLE': ForgeCategoryTier.preferred,
      'BRACCIA': ForgeCategoryTier.preferred,
      'CORE': ForgeCategoryTier.preferred,
      'MOBILITA': ForgeCategoryTier.neutral,
      'EQUILIBRIO': ForgeCategoryTier.neutral,
      'CARDIO': ForgeCategoryTier.neutral,
      'STRETCHING': ForgeCategoryTier.neutral,
    },
    WorkoutType.upperBody: {
      'PETTO_SPINTA': ForgeCategoryTier.preferred,
      'SCHIENA': ForgeCategoryTier.preferred,
      'SPALLE': ForgeCategoryTier.preferred,
      'BRACCIA': ForgeCategoryTier.preferred,
      'CORE': ForgeCategoryTier.preferred,
      'MOBILITA': ForgeCategoryTier.neutral,
      'EQUILIBRIO': ForgeCategoryTier.neutral,
      'STRETCHING': ForgeCategoryTier.neutral,
      'GAMBE_GLUTEI': ForgeCategoryTier.discouraged,
      'CARDIO': ForgeCategoryTier.discouraged,
    },
    WorkoutType.lowerBody: {
      'GAMBE_GLUTEI': ForgeCategoryTier.preferred,
      'MOBILITA': ForgeCategoryTier.neutral,
      'EQUILIBRIO': ForgeCategoryTier.neutral,
      'CORE': ForgeCategoryTier.neutral,
      'CARDIO': ForgeCategoryTier.neutral,
      'STRETCHING': ForgeCategoryTier.neutral,
      'PETTO_SPINTA': ForgeCategoryTier.discouraged,
      'SCHIENA': ForgeCategoryTier.discouraged,
      'SPALLE': ForgeCategoryTier.discouraged,
      'BRACCIA': ForgeCategoryTier.discouraged,
    },
    WorkoutType.mobility: {
      'MOBILITA': ForgeCategoryTier.preferred,
      'STRETCHING': ForgeCategoryTier.preferred,
      'EQUILIBRIO': ForgeCategoryTier.preferred,
      'CORE': ForgeCategoryTier.neutral,
      'GAMBE_GLUTEI': ForgeCategoryTier.discouraged,
      'PETTO_SPINTA': ForgeCategoryTier.discouraged,
      'SCHIENA': ForgeCategoryTier.discouraged,
      'SPALLE': ForgeCategoryTier.discouraged,
      'BRACCIA': ForgeCategoryTier.discouraged,
      'CARDIO': ForgeCategoryTier.discouraged,
    },
    WorkoutType.cardio: {
      'CARDIO': ForgeCategoryTier.preferred,
      'GAMBE_GLUTEI': ForgeCategoryTier.neutral,
      'EQUILIBRIO': ForgeCategoryTier.neutral,
      'MOBILITA': ForgeCategoryTier.neutral,
      'PETTO_SPINTA': ForgeCategoryTier.discouraged,
      'SCHIENA': ForgeCategoryTier.discouraged,
      'SPALLE': ForgeCategoryTier.discouraged,
      'BRACCIA': ForgeCategoryTier.discouraged,
      'CORE': ForgeCategoryTier.discouraged,
      'STRETCHING': ForgeCategoryTier.discouraged,
    },
    // "Prudente" (sezione 31): solo metadati di catalogo, nessun dato
    // sanitario. Favorisce mobilità/stretching dolci, non è una
    // prescrizione medica — resta una policy di rilevanza categoria,
    // identica nella forma a tutte le altre.
    WorkoutType.recovery: {
      'STRETCHING': ForgeCategoryTier.preferred,
      'MOBILITA': ForgeCategoryTier.preferred,
      'EQUILIBRIO': ForgeCategoryTier.neutral,
      'GAMBE_GLUTEI': ForgeCategoryTier.discouraged,
      'PETTO_SPINTA': ForgeCategoryTier.discouraged,
      'SCHIENA': ForgeCategoryTier.discouraged,
      'SPALLE': ForgeCategoryTier.discouraged,
      'BRACCIA': ForgeCategoryTier.discouraged,
      'CORE': ForgeCategoryTier.discouraged,
      'CARDIO': ForgeCategoryTier.discouraged,
    },
  };

  /// `neutral` per una combinazione tipo/categoria non elencata: rete di
  /// sicurezza per categorie future del catalogo, non un giudizio (nessuna
  /// categoria reale attuale è oggi priva di una voce esplicita per
  /// nessuno dei tipi supportati).
  static ForgeCategoryTier tierFor({
    required WorkoutType workoutType,
    required String categoryCode,
  }) {
    final policy = _policies[workoutType];
    if (policy == null) {
      throw ArgumentError.value(
        workoutType,
        'workoutType',
        'Nessuna policy Forge per questo WorkoutType (CUSTOM non è '
            'generabile dal motore, sezione 32).',
      );
    }
    return policy[categoryCode] ?? ForgeCategoryTier.neutral;
  }

  /// `true` per tutti i tipi con una policy definita — usato da
  /// [ForgeRequestValidator]/dai chiamanti per sapere se [tierFor] può
  /// essere invocato senza eccezione.
  static bool isSupported(WorkoutType workoutType) =>
      _policies.containsKey(workoutType);

  /// Tutte le categorie mappate a [tier] per [workoutType] (Milestone 5.2,
  /// usato da `ForgeWorkoutTypeCoveragePolicy` per derivare la copertura
  /// "preferita" senza duplicare questa mappa altrove — unica fonte di
  /// verità sulle tier per categoria).
  static Set<String> categoriesWithTier({
    required WorkoutType workoutType,
    required ForgeCategoryTier tier,
  }) {
    final policy = _policies[workoutType];
    if (policy == null) {
      throw ArgumentError.value(
        workoutType,
        'workoutType',
        'Nessuna policy Forge per questo WorkoutType (CUSTOM non è '
            'generabile dal motore, sezione 32).',
      );
    }
    return {
      for (final entry in policy.entries)
        if (entry.value == tier) entry.key,
    };
  }
}
