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

  static String exerciseDetailPath(int id) => '/exercises/$id';
}
