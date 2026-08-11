import '../entities/forge_adaptation_context.dart';
import '../entities/forge_engine_config.dart';
import '../repositories/workout_session_repository.dart';
import '../services/forge_progression_analyzer.dart';

/// Use case applicativo (Milestone 5.4, sezione 43): recupera lo storico
/// tramite [WorkoutSessionRepository] e lo passa a
/// [ForgeProgressionAnalyzer], che resta ignaro di come i dati sono stati
/// caricati — stesso schema di `EvaluateForgeRequest`/`GenerateForgeWorkout`.
///
/// [now] è iniettato dal chiamante (sezione 36: mai un `DateTime.now()`
/// diretto qui) e usato solo per delimitare la query storica
/// (`adaptationHistoryLookbackDays`, un argine defensivo — il meccanismo
/// di finestra primario resta il numero di sessioni recenti, deciso
/// dall'analyzer).
class BuildForgeAdaptationContext {
  BuildForgeAdaptationContext(
    this._repository, {
    this.config = const ForgeEngineConfig(),
  });

  final WorkoutSessionRepository _repository;
  final ForgeEngineConfig config;

  Future<ForgeAdaptationContext> call({
    required int profileId,
    required DateTime now,
  }) async {
    final since = now.subtract(
      Duration(days: config.adaptationHistoryLookbackDays),
    );
    final sessions = await _repository.getSessionHistory(
      profileId: profileId,
      since: since,
    );
    final sessionIds = sessions.map((s) => s.sessionId).toList();
    final sessionExercises = await _repository.getSessionExercisesForSessions(
      sessionIds,
    );
    return ForgeProgressionAnalyzer.analyze(
      sessions: sessions,
      sessionExercises: sessionExercises,
      config: config,
    );
  }
}
