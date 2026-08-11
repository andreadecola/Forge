import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../domain/entities/adapted_generated_workout_plan.dart';
import '../../../exercises/application/exercise_catalog_providers.dart';
import '../../../../domain/entities/forge_generation_warning.dart';
import '../../../../domain/services/forge_workout_naming_policy.dart';
import '../../application/forge_generator_controller.dart';
import '../forge_labels.dart';
import '../widgets/forge_exercise_preview_card.dart';
import '../workout_labels.dart';

/// Anteprima del piano generato da Forge (Milestone 5.5, sezione 16): mostra
/// ESATTAMENTE il piano che `PersistGeneratedWorkout` salverà se l'utente
/// confermerà — nessuna rigenerazione silenziosa (STOP 5). Nessuna logica di
/// eligibility/scoring/adaptation/coverage/duration ricostruita qui: ogni
/// informazione mostrata è già stata decisa dal domain (STOP 4).
class ForgeWorkoutPreviewPage extends ConsumerWidget {
  const ForgeWorkoutPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgeGeneratorControllerProvider);
    final controller = ref.read(forgeGeneratorControllerProvider.notifier);

    ref.listen(forgeGeneratorControllerProvider, (previous, next) {
      final workoutId = next.savedWorkoutId;
      if (workoutId != null && previous?.savedWorkoutId != workoutId) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(content: Text('Allenamento creato con Forge')),
        );
        context.pushReplacement(AppRoutes.workoutDetailPath(workoutId));
      }
    });

    final result = state.generationResult;
    final adaptedPlan = result != null && result.success ? result.plan : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Anteprima allenamento')),
      body: adaptedPlan == null
          ? _NoPlanState(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.forgeGenerator);
                }
              },
            )
          : _PreviewBody(
              adaptedPlan: adaptedPlan,
              warnings: result!.warnings,
              isSaving: state.isSaving,
              saveError: state.saveError,
              onSave: controller.save,
            ),
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  const _PreviewBody({
    required this.adaptedPlan,
    required this.warnings,
    required this.isSaving,
    required this.saveError,
    required this.onSave,
  });

  final AdaptedGeneratedWorkoutPlan adaptedPlan;
  final List<ForgeGenerationWarning> warnings;
  final bool isSaving;
  final String? saveError;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = adaptedPlan.plan;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryNameById = {
      for (final category in categoriesAsync.valueOrNull ?? const [])
        category.id: category.name,
    };

    final subtitleParts = <String>[
      WorkoutLabels.type(plan.workoutType),
      'Livello ${plan.request.userLevel}',
      'Target ${plan.targetDurationMinutes} min',
      'Stimata ${plan.estimatedDurationMinutes} min',
      plan.exercises.length == 1
          ? '1 esercizio'
          : '${plan.exercises.length} esercizi',
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                ForgeWorkoutNamingPolicy.defaultNameFor(plan.workoutType),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitleParts.join(' · '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _InfoBanner(
                text: ForgeLabels.adaptationSummary(adaptedPlan.decision),
              ),
              if (!plan.isComplete) ...[
                const SizedBox(height: 8),
                _WarningBanner(
                  text:
                      'Il piano generato non è completo e non può essere '
                      'salvato. Modifica la configurazione e riprova.',
                ),
              ],
              for (final warning in warnings) ...[
                const SizedBox(height: 8),
                _WarningBanner(
                  text: ForgeLabels.generationWarningMessage(warning),
                ),
              ],
              const SizedBox(height: 20),
              Text('Esercizi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (var i = 0; i < plan.exercises.length; i++)
                ForgeExercisePreviewCard(
                  order: i + 1,
                  entry: plan.exercises[i],
                  categoryName:
                      categoryNameById[plan.exercises[i].exercise.categoryId] ??
                      '',
                  adaptationDetail: ForgeLabels.exerciseAdaptationDetail(
                    adaptedPlan.exerciseDecisions[i],
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                if (saveError != null) ...[
                  _WarningBanner(text: saveError!),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (isSaving || !plan.isComplete) ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Salva allenamento'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.forgeGenerator);
                            }
                          },
                    child: const Text('Modifica configurazione'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}

class _NoPlanState extends StatelessWidget {
  const _NoPlanState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Nessun allenamento generato da mostrare.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBack,
              child: const Text('Torna alla configurazione'),
            ),
          ],
        ),
      ),
    );
  }
}
