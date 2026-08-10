import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/workout_session_repository.dart';
import '../database/database_provider.dart';
import 'drift_workout_session_repository.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((
  ref,
) {
  return DriftWorkoutSessionRepository(ref.watch(databaseProvider));
});
