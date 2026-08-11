import '../../../domain/entities/forge_adaptation_decision.dart';
import '../../../domain/entities/forge_exercise_adaptation_decision.dart';
import '../../../domain/entities/forge_exercise_adaptation_action.dart';
import '../../../domain/entities/forge_adaptation_reason.dart';
import '../../../domain/entities/forge_generation_error.dart';
import '../../../domain/entities/forge_generation_warning.dart';
import '../../../domain/entities/workout_enums.dart';

/// Traduzioni italiane per gli enum tecnici del Forge Engine (Milestone
/// 5.5). Stesso principio di `WorkoutLabels`: nessun valore enum, nessuna
/// motivazione medica/diagnostica dedotta qui — solo una traduzione diretta
/// di ciò che il domain ha già deciso (STOP 4 della Milestone 5.5).
abstract final class ForgeLabels {
  /// `WorkoutType.custom` non è generabile dal motore (Milestone 5.1,
  /// sezione 24/32): non va mai offerto nel selettore Forge.
  static List<WorkoutType> get supportedWorkoutTypes =>
      WorkoutType.values.where((type) => type != WorkoutType.custom).toList();

  static String adaptationSummary(ForgeAdaptationDecision decision) {
    switch (decision) {
      case ForgeAdaptationDecision.maintain:
        return 'Piano mantenuto sulla configurazione attuale';
      case ForgeAdaptationDecision.progress:
        return 'L\'allenamento è stato adattato in base alle sessioni recenti';
      case ForgeAdaptationDecision.simplify:
        return 'L\'allenamento è stato adattato in modo più graduale';
    }
  }

  /// Etichetta discreta per un singolo esercizio, se la decisione porta
  /// un'informazione utile da mostrare (sezione 20). `null` se non c'è
  /// nulla da segnalare (es. `keep` senza progressione di parametri, o
  /// `avoidTemporarily`: un segnale interno di questa generazione, non un
  /// giudizio da mostrare all'utente).
  static String? exerciseAdaptationDetail(
    ForgeExerciseAdaptationDecision decision,
  ) {
    switch (decision.action) {
      case ForgeExerciseAdaptationAction.progress:
        return decision.reasons.contains(
              ForgeAdaptationReason.parameterProgressionApplied,
            )
            ? 'Parametri aumentati'
            : 'Progressione applicata';
      case ForgeExerciseAdaptationAction.regress:
        return 'Variante più graduale';
      case ForgeExerciseAdaptationAction.replace:
        return 'Alternativa selezionata';
      case ForgeExerciseAdaptationAction.keep:
        return decision.reasons.contains(
              ForgeAdaptationReason.parameterProgressionApplied,
            )
            ? 'Parametri aumentati'
            : null;
      case ForgeExerciseAdaptationAction.avoidTemporarily:
        return null;
    }
  }

  static String generationErrorMessage(ForgeGenerationError error) {
    switch (error) {
      case ForgeGenerationError.invalidRequest:
        return 'La configurazione non è valida.';
      case ForgeGenerationError.unsupportedWorkoutType:
        return 'Questo tipo di allenamento non è generabile automaticamente.';
      case ForgeGenerationError.insufficientEligibleExercises:
        return 'Non ci sono abbastanza esercizi disponibili per questa '
            'configurazione.';
      case ForgeGenerationError.missingRequiredCoverage:
        return 'Non è possibile coprire i gruppi muscolari richiesti con '
            'attrezzatura e livello selezionati.';
      case ForgeGenerationError.cannotBuildExecutablePlan:
        return 'Non è stato possibile creare un allenamento con questa '
            'configurazione.';
    }
  }

  static String generationWarningMessage(ForgeGenerationWarning warning) {
    switch (warning) {
      case ForgeGenerationWarning.durationBelowTarget:
        return 'La durata stimata è inferiore a quella richiesta.';
      case ForgeGenerationWarning.durationAboveTarget:
        return 'La durata stimata è superiore a quella richiesta.';
      case ForgeGenerationWarning.missingPreferredCoverage:
        return 'Alcuni gruppi muscolari preferiti non sono stati coperti '
            'completamente.';
      case ForgeGenerationWarning.limitedExercisePool:
        return 'Gli esercizi disponibili per questa configurazione sono '
            'limitati.';
      case ForgeGenerationWarning.minimumExerciseFallback:
        return 'È stato usato il numero minimo di esercizi per completare '
            'il piano.';
    }
  }
}
