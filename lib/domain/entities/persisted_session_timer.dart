import 'persisted_session_timer_kind.dart';

/// Timer persistito di una sessione (Milestone 4.4.3): stessa forma di
/// `SessionTimer` (applicazione, Milestone 4.4.2) più [kind] per distinguere
/// se è il countdown della serie a tempo o quello del recupero — nella
/// sessione runtime questo si sa già da *quale* campo è popolato
/// (`exerciseTimer` vs `restTimer`); qui, con un'unica terna di colonne
/// condivisa (vedi `sessioni_allenamento_table.dart`), serve un tag esplicito.
///
/// Stessa filosofia timestamp-first di `SessionTimer`: [remainingPaused]
/// non nullo significa "timer in pausa, residuo congelato"; altrimenti il
/// residuo si ricalcola sempre da [startedAt] rispetto a un orologio
/// (sezione 13/26).
class PersistedSessionTimer {
  const PersistedSessionTimer({
    required this.kind,
    required this.startedAt,
    required this.targetSeconds,
    this.remainingPaused,
  });

  final PersistedSessionTimerKind kind;
  final DateTime startedAt;
  final int targetSeconds;
  final int? remainingPaused;

  bool get isPaused => remainingPaused != null;
}
