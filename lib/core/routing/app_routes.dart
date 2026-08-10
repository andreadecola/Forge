abstract final class AppRoutes {
  static const String dashboard = '/';
  static const String program = '/program';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String weight = '/weight';
  static const String pressure = '/pressure';
  static const String equipment = '/equipment';
  static const String exercises = '/exercises';
  static const String exerciseDetail = '/exercises/:id';
  static const String workouts = '/workouts';
  static const String workoutNew = '/workouts/new';
  static const String workoutArchived = '/workouts/archived';
  static const String workoutHistory = '/workouts/history';
  static const String workoutHistoryDetail = '/workouts/history/:sessionId';
  static const String workoutStatistics = '/workouts/statistics';
  static const String workoutDetail = '/workouts/:id';
  static const String workoutEdit = '/workouts/:id/edit';
  static const String workoutExercisePicker = '/workouts/:id/exercises';
  static const String workoutSession = '/workouts/:id/session';

  static String exerciseDetailPath(int id) => '/exercises/$id';
  static String workoutDetailPath(int id) => '/workouts/$id';
  static String workoutEditPath(int id) => '/workouts/$id/edit';
  static String workoutExercisePickerPath(int id) => '/workouts/$id/exercises';
  static String workoutSessionPath(int id) => '/workouts/$id/session';
  static String workoutHistoryDetailPath(int sessionId) =>
      '/workouts/history/$sessionId';
}
