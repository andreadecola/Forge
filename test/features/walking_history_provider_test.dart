import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/walking_session_status.dart';
import 'package:forge/features/walking/application/walking_history_providers.dart';

import 'walking_test_helpers.dart';

void main() {
  test('filtri storico lavorano sulla lista già caricata', () {
    final repository = FakeWalkingSessionRepository();
    final completed = repository.seed(status: WalkingSessionStatus.completed);
    final aborted = repository.seed(status: WalkingSessionStatus.aborted);
    final active = repository.seed();
    final sessions = [completed, aborted, active];

    expect(
      filterWalkingHistory(sessions, WalkingHistoryFilter.all),
      hasLength(3),
    );
    expect(filterWalkingHistory(sessions, WalkingHistoryFilter.completed), [
      completed,
    ]);
    expect(filterWalkingHistory(sessions, WalkingHistoryFilter.aborted), [
      aborted,
    ]);
  });
}
