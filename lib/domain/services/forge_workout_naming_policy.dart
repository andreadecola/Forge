import '../entities/workout_enums.dart';

/// Nome default per una scheda persistita da un piano generato (Milestone
/// 5.3, sezione 6): deterministico e leggibile, **mai un timestamp** — lo
/// stesso `WorkoutType` produce sempre lo stesso nome base. Due
/// generazioni distinte dello stesso tipo condividono quindi lo stesso
/// nome default: non è un errore (sezione 32, nessuna deduplica), la UI
/// futura potrà lasciare all'utente la scelta di rinominare.
///
/// Volutamente **non** la stessa mappa di `WorkoutLabels` (livello
/// presentazione, Milestone 4.3): quella etichetta un badge nella UI
/// esistente, questa produce il nome persistito di una scheda — scopi
/// diversi, nessuna duplicazione di uno stesso concetto. Il domain non
/// importa comunque mai la presentation layer.
abstract final class ForgeWorkoutNamingPolicy {
  static const Map<WorkoutType, String> _defaultNames = {
    WorkoutType.fullBody: 'Forge Full Body',
    WorkoutType.upperBody: 'Forge Parte Superiore',
    WorkoutType.lowerBody: 'Forge Parte Inferiore',
    WorkoutType.mobility: 'Forge Mobilità',
    WorkoutType.cardio: 'Forge Cardio',
    WorkoutType.recovery: 'Forge Recupero',
  };

  /// Lancia per `WorkoutType.custom` (non generabile dal motore, stesso
  /// comportamento di `ForgeWorkoutTypePolicy.tierFor` — sezione 32): non
  /// dovrebbe mai essere chiamato con quel tipo, un piano generato non
  /// esiste per CUSTOM.
  static String defaultNameFor(WorkoutType workoutType) {
    final name = _defaultNames[workoutType];
    if (name == null) {
      throw ArgumentError.value(
        workoutType,
        'workoutType',
        'Nessun nome default Forge per questo WorkoutType (CUSTOM non è '
            'generabile dal motore).',
      );
    }
    return name;
  }
}
