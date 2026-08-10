import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../data/repositories/workout_providers.dart';
import '../../../../domain/entities/workout.dart';
import '../../../../domain/entities/workout_enums.dart';
import '../widgets/workout_metadata_form.dart';

/// Crea una nuova scheda come BOZZA, con origine USER (l'utente non può
/// impostare l'origine: qui è sempre una scheda manuale). Dopo la creazione
/// naviga direttamente alla composizione (`WorkoutEditPage`).
class CreateWorkoutPage extends ConsumerStatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  ConsumerState<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends ConsumerState<CreateWorkoutPage> {
  bool _saving = false;

  Future<void> _create(WorkoutMetadataFormResult result) async {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile?.id == null) return;

    setState(() => _saving = true);
    try {
      final id = await ref
          .read(workoutRepositoryProvider)
          .createWorkout(
            Workout(
              profileId: profile!.id!,
              name: result.name,
              description: result.description,
              type: result.type,
              level: result.level,
              estimatedDurationMinutes: result.estimatedDurationMinutes,
              status: WorkoutDefinitionStatus.draft,
              origin: WorkoutOrigin.user,
            ),
          );
      if (!mounted) return;
      context.pushReplacement(AppRoutes.workoutEditPath(id));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si è verificato un errore. Riprova.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo allenamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: _saving,
          child: Opacity(
            opacity: _saving ? 0.6 : 1,
            child: WorkoutMetadataForm(submitLabel: 'Crea', onSubmit: _create),
          ),
        ),
      ),
    );
  }
}
