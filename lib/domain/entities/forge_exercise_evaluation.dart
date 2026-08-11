import 'forge_candidate.dart';
import 'forge_eligibility_result.dart';
import 'forge_score.dart';

/// Valutazione completa di un candidato (Milestone 5.1, sezione 45): per
/// gli esclusi, [estimatedDurationSeconds] e [score] sono `null` — non ha
/// senso stimarli/calcolarli per un esercizio che non entrerà comunque nel
/// pool (in particolare, `unsupportedParameters` significa proprio che la
/// durata non è stimabile).
class ForgeExerciseEvaluation {
  const ForgeExerciseEvaluation({
    required this.candidate,
    required this.eligibility,
    this.estimatedDurationSeconds,
    this.score,
  });

  final ForgeCandidate candidate;
  final ForgeEligibilityResult eligibility;
  final int? estimatedDurationSeconds;
  final ForgeScore? score;
}
