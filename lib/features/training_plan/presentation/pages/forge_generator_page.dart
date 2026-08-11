import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/forge_generation_error.dart';
import '../../application/forge_generator_controller.dart';
import '../forge_labels.dart';
import '../workout_labels.dart';

/// Pagina di configurazione della generazione Forge (Milestone 5.5): solo
/// raccolta input, nessuna logica del motore qui (STOP 1/4). Il profilo e
/// l'attrezzatura posseduta sono già letti automaticamente dal controller —
/// questa pagina non li richiede mai di nuovo (sezione 6/7).
class ForgeGeneratorPage extends ConsumerWidget {
  const ForgeGeneratorPage({super.key});

  static const List<int> _durationOptions = [20, 30, 40, 50, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    ref.listen(forgeGeneratorControllerProvider, (previous, next) {
      final result = next.generationResult;
      final previousResult = previous?.generationResult;
      if (result != null &&
          result.success &&
          result.plan != null &&
          result != previousResult) {
        context.push(AppRoutes.forgePreview);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Genera con Forge')),
      body: profileAsync.when(
        data: (profile) {
          if (profile?.id == null) {
            return _MissingProfileState(
              onGoToProfile: () => context.go(AppRoutes.profile),
            );
          }
          return const _GeneratorForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ErrorState(),
      ),
    );
  }
}

class _GeneratorForm extends ConsumerWidget {
  const _GeneratorForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgeGeneratorControllerProvider);
    final controller = ref.read(forgeGeneratorControllerProvider.notifier);
    final failedResult =
        state.generationResult != null && !state.generationResult!.success
        ? state.generationResult
        : null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.error != null) ...[
                _MessageBanner(message: state.error!, isError: true),
                const SizedBox(height: 16),
              ],
              if (failedResult != null) ...[
                _GenerationFailureCard(
                  errors: failedResult.errors,
                  onEdit: controller.resetResult,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Tipo di allenamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in ForgeLabels.supportedWorkoutTypes)
                    ChoiceChip(
                      label: Text(WorkoutLabels.type(type)),
                      selected: state.selectedWorkoutType == type,
                      onSelected: (_) => controller.setWorkoutType(type),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Durata', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in ForgeGeneratorPage._durationOptions)
                    ChoiceChip(
                      label: Text('$minutes min'),
                      selected: state.targetDurationMinutes == minutes,
                      onSelected: (_) =>
                          controller.setTargetDurationMinutes(minutes),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Livello', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var level = 1; level <= 5; level++)
                    ChoiceChip(
                      label: Text('$level'),
                      selected: state.userLevel == level,
                      onSelected: (_) => controller.setUserLevel(level),
                    ),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isGenerating ? null : controller.generate,
                icon: state.isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bolt),
                label: const Text('Genera allenamento'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenerationFailureCard extends StatelessWidget {
  const _GenerationFailureCard({required this.errors, required this.onEdit});

  final List<ForgeGenerationError> errors;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Non è stato possibile creare un allenamento con questa '
              'configurazione.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final error in errors) ...[
              const SizedBox(height: 8),
              Text(ForgeLabels.generationErrorMessage(error)),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onEdit,
              child: const Text('Modifica configurazione'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? scheme.errorContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

class _MissingProfileState extends StatelessWidget {
  const _MissingProfileState({required this.onGoToProfile});

  final VoidCallback onGoToProfile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Completa prima il profilo per usare Forge.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onGoToProfile,
              child: const Text('Vai al profilo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Si è verificato un errore.', textAlign: TextAlign.center),
      ),
    );
  }
}
