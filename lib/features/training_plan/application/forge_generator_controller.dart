import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/forge_providers.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/forge_generation_result.dart';
import '../../../domain/entities/forge_request.dart';
import '../../../domain/entities/persist_generated_workout_request.dart';
import '../../../domain/entities/workout_enums.dart';
import '../../exercises/application/exercise_catalog_providers.dart';
import 'forge_generator_state.dart';

/// Controller applicativo del flusso di generazione Forge (Milestone 5.5):
/// raccoglie la configurazione scelta dall'utente, costruisce la
/// `ForgeRequest` con i dati già reali del profilo/attrezzatura (nessun
/// secondo selettore attrezzatura, sezione 7), invoca
/// `GenerateAdaptedForgeWorkout` e poi, al salvataggio, `PersistGeneratedWorkout`
/// — mai una nuova regola Forge qui (STOP 1/4 della milestone).
class ForgeGeneratorController extends Notifier<ForgeGeneratorState> {
  @override
  ForgeGeneratorState build() => const ForgeGeneratorState();

  void setWorkoutType(WorkoutType type) {
    state = state.copyWith(selectedWorkoutType: type);
  }

  void setTargetDurationMinutes(int minutes) {
    state = state.copyWith(targetDurationMinutes: minutes);
  }

  void setUserLevel(int level) {
    state = state.copyWith(userLevel: level);
  }

  /// Torna alla configurazione: pulisce l'esito precedente (successo,
  /// fallimento o salvataggio) senza toccare i parametri scelti
  /// dall'utente (sezione 25: "Modifica configurazione", non "Rigenera").
  void resetResult() {
    state = state.copyWith(
      clearGenerationResult: true,
      clearError: true,
      clearSaveError: true,
      clearSavedWorkoutId: true,
    );
  }

  /// Genera un piano adattato. Guardia di concorrenza sincrona (sezione
  /// 32): una seconda chiamata mentre la prima è in corso non fa nulla.
  Future<void> generate() async {
    if (state.isGenerating) return;
    state = state.copyWith(
      isGenerating: true,
      clearGenerationResult: true,
      clearError: true,
      clearSaveError: true,
      clearSavedWorkoutId: true,
    );

    try {
      final profile = await ref.read(currentProfileProvider.future);
      final profileId = profile?.id;
      if (profileId == null) {
        state = state.copyWith(
          isGenerating: false,
          error: 'Completa prima il profilo per usare Forge.',
        );
        return;
      }

      final equipmentCodes = await ref.read(
        ownedMasterEquipmentCodesProvider.future,
      );

      final request = ForgeRequest(
        profileId: profileId,
        userLevel: state.userLevel,
        availableEquipmentCodes: equipmentCodes,
        targetDurationMinutes: state.targetDurationMinutes,
        workoutType: state.selectedWorkoutType,
      );

      final result = await ref.read(generateAdaptedForgeWorkoutProvider)(
        request: request,
        profileId: profileId,
        now: ref.read(clockProvider).now(),
      );

      state = state.copyWith(isGenerating: false, generationResult: result);
    } catch (_) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Si è verificato un errore. Riprova.',
      );
    }
  }

  /// Persiste ESATTAMENTE il piano mostrato in anteprima (sezione 26/STOP
  /// 5): nessuna nuova generazione qui, il piano viene preso da
  /// `state.generationResult` e passato tale e quale a
  /// `PersistGeneratedWorkout` — lo stesso use case già validato dalla
  /// Milestone 5.3, non duplicato.
  Future<int?> save() async {
    final result = state.generationResult;
    if (state.isSaving || result == null || !result.success) return null;
    final adaptedPlan = result.plan;
    if (adaptedPlan == null) return null;

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final profile = await ref.read(currentProfileProvider.future);
      final profileId = profile?.id;
      if (profileId == null) {
        state = state.copyWith(
          isSaving: false,
          saveError: 'Non è stato possibile salvare l\'allenamento.',
        );
        return null;
      }

      final generationResult = ForgeGenerationResult(
        plan: adaptedPlan.plan,
        errors: result.errors,
        warnings: result.warnings,
        evaluation: result.evaluation,
      );

      final persistResult = await ref.read(persistGeneratedWorkoutProvider)(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: generationResult,
        ),
      );

      if (persistResult.success) {
        state = state.copyWith(
          isSaving: false,
          savedWorkoutId: persistResult.workoutId,
        );
        return persistResult.workoutId;
      }

      state = state.copyWith(
        isSaving: false,
        saveError: 'Non è stato possibile salvare l\'allenamento.',
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        saveError: 'Non è stato possibile salvare l\'allenamento.',
      );
      return null;
    }
  }
}

final forgeGeneratorControllerProvider =
    NotifierProvider<ForgeGeneratorController, ForgeGeneratorState>(
      ForgeGeneratorController.new,
    );
