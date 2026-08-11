import '../entities/exercise_details.dart';
import '../entities/forge_candidate.dart';
import '../entities/forge_engine_config.dart';
import '../entities/forge_evaluation_result.dart';
import '../entities/forge_exercise_evaluation.dart';
import '../entities/forge_request.dart';
import 'exercise_duration_estimator.dart';
import 'forge_eligibility_service.dart';
import 'forge_request_normalizer.dart';
import 'forge_request_validator.dart';
import 'forge_scoring_service.dart';

/// Orchestratore del Forge Engine (Milestone 5.1, sezione 46): domain
/// puro, nessuna dipendenza da Drift/DAO/AppDatabase/Riverpod (sezione
/// 50) — riceve [exercises] già caricati dal chiamante (l'use case
/// applicativo, sezione 51).
///
/// **Non genera ancora un `Workout`**: produce solo un
/// [ForgeEvaluationResult] spiegabile (eleggibili ordinati + esclusi con
/// motivo). La composizione reale di una scheda arriva con la Milestone
/// 5.2.
class ForgeEngine {
  const ForgeEngine({
    this.eligibilityService = const ForgeEligibilityService(),
    this.scoringService = const ForgeScoringService(),
    this.config = const ForgeEngineConfig(),
  });

  final ForgeEligibilityService eligibilityService;
  final ForgeScoringService scoringService;
  final ForgeEngineConfig config;

  ForgeEvaluationResult evaluateExercises(
    ForgeRequest request,
    List<ExerciseDetails> exercises,
  ) {
    final normalizedRequest = ForgeRequestNormalizer.normalize(request);
    final validation = ForgeRequestValidator.validate(normalizedRequest);
    if (!validation.isValid) {
      // Nessuna eccezione: un risultato vuoto e spiegato (sezione 11), non
      // un crash — il motore resta puro e prevedibile anche su input non
      // valido.
      return ForgeEvaluationResult(
        normalizedRequest: normalizedRequest,
        eligible: const [],
        excluded: const [],
        warnings: validation.errors,
      );
    }

    final eligible = <ForgeExerciseEvaluation>[];
    final excluded = <ForgeExerciseEvaluation>[];

    for (final details in exercises) {
      final candidate = ForgeCandidate.fromExerciseDetails(details);
      final eligibility = eligibilityService.evaluate(
        candidate: candidate,
        userLevel: normalizedRequest.userLevel,
        availableEquipmentCodes: normalizedRequest.availableEquipmentCodes,
        config: config,
      );

      if (!eligibility.eligible) {
        excluded.add(
          ForgeExerciseEvaluation(
            candidate: candidate,
            eligibility: eligibility,
          ),
        );
        continue;
      }

      // Eleggibile implica che la durata sia stimabile: l'unico motivo
      // per cui `estimateSeconds` potrebbe tornare `null`
      // (`unsupportedParameters`) avrebbe già escluso il candidato sopra.
      final estimatedDurationSeconds =
          ExerciseDurationEstimator.estimateSeconds(
            exercise: candidate.exercise,
            config: config,
          )!;
      final score = scoringService.score(
        candidate: candidate,
        workoutType: normalizedRequest.workoutType,
        userLevel: normalizedRequest.userLevel,
        estimatedDurationSeconds: estimatedDurationSeconds,
        targetDurationMinutes: normalizedRequest.targetDurationMinutes,
        config: config,
      );

      eligible.add(
        ForgeExerciseEvaluation(
          candidate: candidate,
          eligibility: eligibility,
          estimatedDurationSeconds: estimatedDurationSeconds,
          score: score,
        ),
      );
    }

    eligible.sort(_compareByStableRanking);

    return ForgeEvaluationResult(
      normalizedRequest: normalizedRequest,
      eligible: eligible,
      excluded: excluded,
    );
  }

  /// Ordinamento deterministico (sezione 41-43): punteggio decrescente,
  /// poi livello minimo crescente (a parità di punteggio, propone prima
  /// l'esercizio più accessibile), poi codice esercizio crescente come
  /// ultimo spareggio — sempre stabile, mai legato a `Random()`, timestamp
  /// o ordine di provenienza dal catalogo (sezione 42, verificato dal
  /// test "stesso input, ordine di input diverso -> stesso risultato").
  int _compareByStableRanking(
    ForgeExerciseEvaluation a,
    ForgeExerciseEvaluation b,
  ) {
    final scoreCompare = b.score!.total.compareTo(a.score!.total);
    if (scoreCompare != 0) return scoreCompare;

    final levelCompare = a.candidate.exercise.minimumLevel.compareTo(
      b.candidate.exercise.minimumLevel,
    );
    if (levelCompare != 0) return levelCompare;

    return a.candidate.exercise.code.compareTo(b.candidate.exercise.code);
  }
}
