import '../../../domain/entities/forge_adapted_generation_result.dart';
import '../../../domain/entities/workout_enums.dart';

/// Stato applicativo del flusso di generazione Forge (Milestone 5.5).
/// Nessuna informazione derivabile duplicata: il risultato del domain
/// ([generationResult]) resta l'unica fonte di verità su piano/errori/
/// warning/adattamento — questo stato porta solo la configurazione scelta
/// dall'utente e i flag di UI (caricamento/errore infrastrutturale).
class ForgeGeneratorState {
  const ForgeGeneratorState({
    this.selectedWorkoutType = WorkoutType.fullBody,
    this.targetDurationMinutes = 30,
    this.userLevel = 1,
    this.isGenerating = false,
    this.generationResult,
    this.error,
    this.isSaving = false,
    this.saveError,
    this.savedWorkoutId,
  });

  final WorkoutType selectedWorkoutType;
  final int targetDurationMinutes;
  final int userLevel;

  final bool isGenerating;

  /// Esito dell'ultima generazione riuscita ad arrivare a una risposta del
  /// domain (può avere `success == false`: un fallimento spiegabile non è
  /// un errore infrastrutturale, vedi [error]).
  final ForgeAdaptedGenerationResult? generationResult;

  /// Solo per fallimenti infrastrutturali (profilo mancante, eccezione
  /// imprevista) — mai una traduzione di un enum domain, che passa invece
  /// da `ForgeLabels` a partire da [generationResult].
  final String? error;

  final bool isSaving;
  final String? saveError;

  /// Non-null dopo un salvataggio riuscito: id della scheda persistita.
  final int? savedWorkoutId;

  ForgeGeneratorState copyWith({
    WorkoutType? selectedWorkoutType,
    int? targetDurationMinutes,
    int? userLevel,
    bool? isGenerating,
    ForgeAdaptedGenerationResult? generationResult,
    bool clearGenerationResult = false,
    String? error,
    bool clearError = false,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
    int? savedWorkoutId,
    bool clearSavedWorkoutId = false,
  }) {
    return ForgeGeneratorState(
      selectedWorkoutType: selectedWorkoutType ?? this.selectedWorkoutType,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      userLevel: userLevel ?? this.userLevel,
      isGenerating: isGenerating ?? this.isGenerating,
      generationResult: clearGenerationResult
          ? null
          : (generationResult ?? this.generationResult),
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      savedWorkoutId: clearSavedWorkoutId
          ? null
          : (savedWorkoutId ?? this.savedWorkoutId),
    );
  }
}
