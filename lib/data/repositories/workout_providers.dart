import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_details.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/services/workout_exercise_factory.dart';
import '../../domain/services/workout_validation_service.dart';
import '../database/database_provider.dart';
import 'drift_workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return DriftWorkoutRepository(ref.watch(databaseProvider));
});

final workoutValidationServiceProvider = Provider<WorkoutValidationService>((
  ref,
) {
  return const WorkoutValidationService();
});

final workoutExerciseFactoryProvider = Provider<WorkoutExerciseFactory>((ref) {
  return const WorkoutExerciseFactory();
});

/// Schede attive del profilo (nessuna dipendenza da UI/Milestone 4.3: solo
/// lettura tecnica).
final workoutsProvider = FutureProvider.family<List<Workout>, int>((
  ref,
  profileId,
) {
  return ref.watch(workoutRepositoryProvider).getWorkouts(profileId: profileId);
});

final watchWorkoutsProvider = StreamProvider.family<List<Workout>, int>((
  ref,
  profileId,
) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchWorkouts(profileId: profileId);
});

final workoutDetailsProvider = FutureProvider.family<WorkoutDetails?, int>((
  ref,
  workoutId,
) {
  return ref.watch(workoutRepositoryProvider).getWorkoutDetails(workoutId);
});
