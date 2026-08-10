import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/repository_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/equipment/presentation/pages/my_equipment_page.dart';
import '../../features/exercises/presentation/pages/exercise_catalog_page.dart';
import '../../features/exercises/presentation/pages/exercise_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/pressure/presentation/pages/pressure_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/training_plan/presentation/pages/archived_workouts_page.dart';
import '../../features/training_plan/presentation/pages/create_workout_page.dart';
import '../../features/training_plan/presentation/pages/exercise_picker_page.dart';
import '../../features/training_plan/presentation/pages/program_page.dart';
import '../../features/training_plan/presentation/pages/workout_detail_page.dart';
import '../../features/training_plan/presentation/pages/workout_edit_page.dart';
import '../../features/training_plan/presentation/pages/workout_list_page.dart';
import '../../features/weight/presentation/pages/weight_page.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Router applicativo. Il redirect verso /onboarding legge lo stato
/// `onboardingCompleted` dal repository settings a ogni navigazione: non
/// dipende da uno stato in memoria, quindi resta corretto anche al primo
/// avvio dell'app.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      final onboardingCompleted = await ref
          .read(settingsRepositoryProvider)
          .isOnboardingCompleted();
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!onboardingCompleted && !goingToOnboarding) {
        return AppRoutes.onboarding;
      }
      if (onboardingCompleted && goingToOnboarding) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.weight,
        builder: (context, state) => const WeightPage(),
      ),
      GoRoute(
        path: AppRoutes.pressure,
        builder: (context, state) => const PressurePage(),
      ),
      GoRoute(
        path: AppRoutes.equipment,
        builder: (context, state) => const MyEquipmentPage(),
      ),
      GoRoute(
        path: AppRoutes.exercises,
        builder: (context, state) => const ExerciseCatalogPage(),
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dettaglio esercizio')),
              body: const Center(
                child: Text('Identificativo esercizio non valido.'),
              ),
            );
          }
          return ExerciseDetailPage(exerciseId: id);
        },
      ),
      // Rotte scheda allenamento: piatte come `/exercises`/`/exercises/:id`
      // (non annidate sotto `/workouts`) — un GoRoute con figli valuta il
      // proprio `redirect` anche per i figli, quindi un redirect su
      // `/workouts` da solo finirebbe per intercettare anche
      // `/workouts/new` ecc. Qui `/workouts` ha semplicemente la stessa
      // pagina della voce "Programma" della bottom navigation.
      GoRoute(
        path: AppRoutes.workouts,
        builder: (context, state) => const WorkoutListPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutNew,
        builder: (context, state) => const CreateWorkoutPage(),
      ),
      // Deve precedere `workoutDetail` (`/workouts/:id`): con rotte piatte
      // il primo match vince, e senza questa il segmento letterale
      // "archived" verrebbe interpretato come un `:id` non valido.
      GoRoute(
        path: AppRoutes.workoutArchived,
        builder: (context, state) => const ArchivedWorkoutsPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _InvalidWorkoutIdPage();
          return WorkoutDetailPage(workoutId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutEdit,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _InvalidWorkoutIdPage();
          return WorkoutEditPage(workoutId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutExercisePicker,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _InvalidWorkoutIdPage();
          return ExercisePickerPage(workoutId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.program,
                builder: (context, state) => const ProgramPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _InvalidWorkoutIdPage extends StatelessWidget {
  const _InvalidWorkoutIdPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheda allenamento')),
      body: const Center(child: Text('Identificativo scheda non valido.')),
    );
  }
}
