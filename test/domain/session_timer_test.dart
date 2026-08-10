import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/training_plan/application/session_timer.dart';

import 'fake_session_clock.dart';

void main() {
  test('remainingSeconds deriva dal tempo reale trascorso, non da un '
      'contatore', () {
    final clock = FakeSessionClock();
    final timer = SessionTimer(targetSeconds: 30, startedAt: clock.now());

    expect(timer.remainingSeconds(clock), 30);
    clock.advance(const Duration(seconds: 10));
    expect(timer.remainingSeconds(clock), 20);
    clock.advance(const Duration(seconds: 25));
    // Non scende sotto zero anche se il tempo trascorso supera il target.
    expect(timer.remainingSeconds(clock), 0);
    expect(timer.isFinished(clock), isTrue);
  });

  test('frozen congela il residuo esatto al momento della pausa', () {
    final clock = FakeSessionClock();
    final timer = SessionTimer(targetSeconds: 60, startedAt: clock.now());
    clock.advance(const Duration(seconds: 22));

    final frozen = timer.frozen(clock);
    expect(frozen.isPaused, isTrue);
    expect(frozen.remainingSeconds(clock), 38);

    // Il tempo che passa mentre è congelato non intacca il residuo.
    clock.advance(const Duration(minutes: 5));
    expect(frozen.remainingSeconds(clock), 38);
  });

  test('resumed riparte dal residuo congelato, senza deriva', () {
    final clock = FakeSessionClock();
    final timer = SessionTimer(targetSeconds: 60, startedAt: clock.now());
    clock.advance(const Duration(seconds: 22));
    final frozen = timer.frozen(clock);

    clock.advance(const Duration(minutes: 5)); // tempo "morto" in pausa
    final resumed = frozen.resumed(clock);

    expect(resumed.isPaused, isFalse);
    expect(resumed.remainingSeconds(clock), 38);
    clock.advance(const Duration(seconds: 10));
    expect(resumed.remainingSeconds(clock), 28);
  });
}
