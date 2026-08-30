import 'adapted_generated_workout_plan.dart';
import 'forge_adapted_generation_result.dart';

/// Un allenamento Forge proposto per un giorno specifico della settimana
/// (Milestone 8.4): ancora nulla di persistito, [generationResult] è lo
/// stesso oggetto in-memory che la preview mostra e che la conferma
/// persisterà — mai una rigenerazione al momento della conferma (stesso
/// principio già stabilito per il generatore singolo, Milestone 5.5, "il
/// piano persistito è esattamente quello mostrato"). Sempre `success`
/// (`buildProposal` non aggiunge mai una voce fallita alla proposta).
class ProposedForgeWorkout {
  const ProposedForgeWorkout({
    required this.scheduledDate,
    required this.generationResult,
  });

  final DateTime scheduledDate;
  final ForgeAdaptedGenerationResult generationResult;

  AdaptedGeneratedWorkoutPlan get adaptedPlan => generationResult.plan!;
}

/// Proposta di generazione automatica per una settimana (Milestone 8.4):
/// modello transient, non persistito — nessuna nuova tabella (sezione 24/25).
/// Rappresenta solo ciò che serve alla preview e alla successiva conferma.
class WeeklyPlanGenerationProposal {
  const WeeklyPlanGenerationProposal({
    required this.weekStart,
    required this.weekEnd,
    required this.entries,
  });

  final DateTime weekStart;
  final DateTime weekEnd;

  /// Ordinati per data crescente.
  final List<ProposedForgeWorkout> entries;
}
