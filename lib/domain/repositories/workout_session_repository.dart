import '../entities/persisted_session_exercise.dart';
import '../entities/persisted_session_timer.dart';
import '../entities/persisted_workout_session.dart';
import '../entities/workout_details.dart';
import '../entities/workout_session_history_details.dart';
import '../entities/workout_session_history_item.dart';

/// Persistenza della sessione di allenamento in corso (Milestone 4.4.3):
/// permette di ripristinarla dopo la chiusura dell'app. Non sostituisce
/// [WorkoutSessionState]/`WorkoutSessionController` (Milestone 4.4.1/4.4.2),
/// che restano la fonte di verità *runtime*: questo repository viene
/// consultato solo su eventi significativi (avvio, cambio serie/esercizio,
/// timer avviato/scaduto, pausa/ripresa, fine/abbandono) — mai a ogni tick
/// del countdown (sezione 14).
abstract class WorkoutSessionRepository {
  /// Sessione ancora in corso (IN_PROGRESS o PAUSED) del profilo, se
  /// esiste. Usata al bootstrap per proporre il ripristino (sezione 30).
  Future<PersistedWorkoutSession?> getActiveSession({required int profileId});

  Future<PersistedWorkoutSession?> getSessionById(int sessionId);

  /// Righe scheda snapshot della sessione, in ordine (usate dal
  /// ripristino per ricostruire `WorkoutSessionState.exercises`).
  Future<List<PersistedSessionExercise>> getSessionExercises(int sessionId);

  /// Righe snapshot esercizio di più sessioni in un colpo solo (Milestone
  /// 5.4): usata da `ForgeProgressionAnalyzer` per aggregare per esercizio
  /// sulla finestra storica recente senza una query per sessione (sezione
  /// 42 — "evitare N+1"), stesso principio già applicato da
  /// `getBySessionIds` per lo storico (Milestone 4.5.1).
  Future<List<PersistedSessionExercise>> getSessionExercisesForSessions(
    List<int> sessionIds,
  );

  /// Crea la sessione e lo snapshot di ogni sua riga scheda in un'unica
  /// transazione. Ritorna l'id della sessione creata. Lancia
  /// [ActiveSessionAlreadyExistsException] se il profilo ha già una
  /// sessione IN_PROGRESS/PAUSED: garantisce a livello di repository
  /// l'invariante "una sola sessione attiva alla volta" (sezione 20),
  /// stessa regola già applicata dal controller runtime.
  Future<int> createSession({
    required int profileId,
    required WorkoutDetails details,
    required DateTime startedAt,
  });

  /// Aggiorna in un'unica transazione ciò che è cambiato: indice esercizio
  /// corrente, progresso serie delle righe elencate in [exercises] (solo
  /// quelle da aggiornare, non serve l'elenco completo), ed
  /// eventualmente il timer attivo. Un parametro omesso lascia il valore
  /// già persistito invariato — stesso pattern "lambda di reset" di
  /// `WorkoutSessionState.copyWith` per [timer], dove passare
  /// `() => null` lo azzera esplicitamente invece di lasciarlo com'è.
  Future<void> updateProgress({
    required int sessionId,
    int? currentExerciseIndex,
    List<SessionExerciseProgressUpdate> exercises = const [],
    PersistedSessionTimer? Function()? timer,
    required DateTime updatedAt,
  });

  /// Scorciatoia semantica su [updateProgress] per il solo timer (avvio
  /// serie a tempo, avvio/fine recupero, fine naturale del countdown).
  Future<void> updateTimerState({
    required int sessionId,
    PersistedSessionTimer? timer,
    required DateTime updatedAt,
  });

  /// `stato = PAUSED`, `in_pausa = true`, timer congelato se presente.
  Future<void> pauseSession({
    required int sessionId,
    PersistedSessionTimer? frozenTimer,
    required DateTime updatedAt,
  });

  /// `stato = IN_PROGRESS`, `in_pausa = false`, timer ripreso se presente.
  Future<void> resumeSession({
    required int sessionId,
    PersistedSessionTimer? resumedTimer,
    required DateTime updatedAt,
  });

  /// `stato = COMPLETED`, `completata = true`, `data_fine` valorizzata. Il
  /// record non viene mai eliminato (sezione 38/39).
  Future<void> completeSession({
    required int sessionId,
    required DateTime endedAt,
  });

  /// `stato = ABORTED`, `data_fine` valorizzata. Il record non viene mai
  /// eliminato (sezione 40).
  Future<void> abortSession({
    required int sessionId,
    required DateTime endedAt,
  });

  /// Storico delle sessioni concluse (COMPLETED/ABORTED) del profilo, più
  /// recenti prima (Milestone 4.5.1). Le sessioni IN_PROGRESS/PAUSED non
  /// compaiono qui: sono già gestite come sessione attiva
  /// (`getActiveSession`/il banner di ripristino).
  ///
  /// [since] limita la query alle sessioni con `dataInizio >= since`
  /// (Milestone 4.5.2, sezione 40): usato dalle statistiche per periodo,
  /// per non dover leggere tutto lo storico quando serve solo una
  /// finestra recente. `null` (default) equivale a nessun limite — il
  /// comportamento di `WorkoutHistoryPage` resta invariato.
  Future<List<WorkoutSessionHistoryItem>> getSessionHistory({
    required int profileId,
    DateTime? since,
  });

  Stream<List<WorkoutSessionHistoryItem>> watchSessionHistory({
    required int profileId,
    DateTime? since,
  });

  /// Dettaglio di una sessione storica con gli esercizi risolti (nome dal
  /// catalogo, parametri dallo snapshot). `null` se la sessione non
  /// esiste.
  Future<WorkoutSessionHistoryDetails?> getSessionHistoryDetails(int sessionId);
}

/// Lanciata da [WorkoutSessionRepository.createSession] se il profilo ha
/// già una sessione IN_PROGRESS/PAUSED: Forge non permette mai due sessioni
/// attive contemporaneamente (sezione 20/52).
class ActiveSessionAlreadyExistsException implements Exception {
  const ActiveSessionAlreadyExistsException(this.activeSessionId);

  final int activeSessionId;

  @override
  String toString() =>
      'ActiveSessionAlreadyExistsException: sessione $activeSessionId già '
      'attiva.';
}
