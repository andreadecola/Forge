import 'workout_session_clock.dart';

/// Countdown della sessione (serie a tempo o recupero), Milestone 4.4.2.
///
/// I secondi residui non sono un contatore decrementato a ogni tick: sono
/// sempre **derivati dal tempo reale trascorso** ([startedAt] rispetto a
/// [SessionClock.now]). Questo lo rende resistente a piccoli lag, rebuild
/// e frame persi — un tick saltato non fa perdere né guadagnare tempo,
/// perché il prossimo tick ricalcola comunque da zero la differenza reale.
class SessionTimer {
  const SessionTimer({
    required this.targetSeconds,
    required this.startedAt,
    this.pausedRemainingSeconds,
  });

  /// Durata totale del countdown (o, se ripreso dopo una pausa, i secondi
  /// residui al momento della ripresa: vedi [resumed]).
  final int targetSeconds;

  /// Istante da cui è partito questo countdown, secondo [SessionClock].
  final DateTime startedAt;

  /// Non nullo quando il timer è in pausa: i secondi residui congelati al
  /// momento della pausa. Nessun tempo scorre finché resta impostato.
  final int? pausedRemainingSeconds;

  bool get isPaused => pausedRemainingSeconds != null;

  int remainingSeconds(SessionClock clock) {
    final paused = pausedRemainingSeconds;
    if (paused != null) return paused;
    final elapsed = clock.now().difference(startedAt).inSeconds;
    final remaining = targetSeconds - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool isFinished(SessionClock clock) => remainingSeconds(clock) <= 0;

  /// Congela il timer: i secondi residui *in questo istante* diventano
  /// [pausedRemainingSeconds], così la pausa non fa perdere tempo residuo.
  SessionTimer frozen(SessionClock clock) {
    return SessionTimer(
      targetSeconds: targetSeconds,
      startedAt: startedAt,
      pausedRemainingSeconds: remainingSeconds(clock),
    );
  }

  /// Riprende un timer congelato: un nuovo countdown che parte da adesso,
  /// con target pari ai secondi residui congelati (nessuna deriva).
  SessionTimer resumed(SessionClock clock) {
    return SessionTimer(
      targetSeconds: pausedRemainingSeconds ?? remainingSeconds(clock),
      startedAt: clock.now(),
    );
  }
}
