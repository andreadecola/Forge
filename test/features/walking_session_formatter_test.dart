import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/walking/presentation/walking_session_formatter.dart';

void main() {
  test('formatta MM:SS sotto un ora', () {
    expect(formatWalkingDuration(0), '00:00');
    expect(formatWalkingDuration(8), '00:08');
    expect(formatWalkingDuration(763), '12:43');
    expect(formatWalkingDuration(3599), '59:59');
  });

  test('passa a HH:MM:SS sopra un ora', () {
    expect(formatWalkingDuration(3600), '01:00:00');
    expect(formatWalkingDuration(3920), '01:05:20');
  });

  test('valori negativi sono protetti', () {
    expect(formatWalkingDuration(-1), '00:00');
  });
}
