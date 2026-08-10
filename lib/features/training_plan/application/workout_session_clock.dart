import 'package:clock/clock.dart' as pkg_clock;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Astrazione su "adesso": permette al timer della sessione (Milestone
/// 4.4.2) di essere testato con un orologio controllabile manualmente,
/// invece di dover aspettare secondi reali nei test.
abstract class SessionClock {
  DateTime now();
}

/// Implementazione di produzione: **non** `DateTime.now()` direttamente
/// (una chiamata al costruttore statico, che ignora qualunque zona di
/// test), ma `package:clock`'s `clock.now()` — che consulta l'orologio
/// eventualmente iniettato nella zona corrente. In produzione (nessuna
/// zona speciale) equivale comunque all'ora di sistema reale; nei test
/// che girano dentro `FakeAsync().run(...)` (che inietta il proprio
/// orologio finto via `withClock`) segue invece il tempo finto, senza
/// bisogno di un secondo meccanismo di override.
class SystemSessionClock implements SessionClock {
  const SystemSessionClock();

  @override
  DateTime now() => pkg_clock.clock.now();
}

final sessionClockProvider = Provider<SessionClock>(
  (ref) => const SystemSessionClock(),
);
