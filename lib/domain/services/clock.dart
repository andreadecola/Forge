import 'package:clock/clock.dart' as pkg_clock;

/// Astrazione domain su "adesso" (Milestone 5.3): permette a
/// `PersistGeneratedWorkout` di essere testato con un orario controllabile,
/// invece di dipendere da `DateTime.now()` sparso nel codice.
///
/// Deliberatamente **non** `SessionClock`
/// (`features/training_plan/application/workout_session_clock.dart`,
/// Milestone 4.4.2): stessa interfaccia a un solo metodo, ma quello vive
/// nella feature layer (timer di sessione) e il domain non importa mai la
/// feature layer — non è una duplicazione di logica di business (l'unico
/// metodo è un getter dell'ora corrente), solo la stessa astrazione
/// minimale ripetuta nel layer corretto per ciascun consumatore.
abstract class Clock {
  DateTime now();
}

/// Implementazione di produzione: usa `package:clock`'s `clock.now()`
/// (non `DateTime.now()` diretto) così che i test che girano dentro
/// `FakeAsync().run(...)` o `withClock` seguano un orario finto senza un
/// secondo meccanismo di override — stesso principio di
/// `SystemSessionClock`.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => pkg_clock.clock.now();
}
