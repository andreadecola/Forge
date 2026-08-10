import 'package:forge/features/training_plan/application/workout_session_clock.dart';

/// Orologio controllabile manualmente per i test (Milestone 4.4.2,
/// sezione 46): nessun test deve aspettare secondi reali.
class FakeSessionClock implements SessionClock {
  FakeSessionClock([DateTime? initial])
    : _now = initial ?? DateTime(2026, 1, 1);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}
