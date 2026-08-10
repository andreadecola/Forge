import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../data/repositories/catalog_providers.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/exercise_availability_status.dart';
import '../../../../domain/entities/exercise_details.dart';
import '../../../../domain/entities/muscle_group.dart';
import '../../application/exercise_catalog_providers.dart';
import '../exercise_labels.dart';
import '../widgets/availability_badge.dart';
import '../widgets/exercise_image_gallery.dart';

class ExerciseDetailPage extends ConsumerWidget {
  const ExerciseDetailPage({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(exerciseDetailsProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio esercizio')),
      body: detailsAsync.when(
        data: (details) => details == null
            ? const _MessageState(
                icon: Icons.search_off,
                message: 'Esercizio non trovato.',
              )
            : _ExerciseDetailBody(details: details),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MessageState(
          icon: Icons.error_outline,
          message: 'Non è stato possibile caricare questo esercizio.',
          actionLabel: 'Riprova',
          onAction: () => ref.invalidate(exerciseDetailsProvider(exerciseId)),
        ),
      ),
    );
  }
}

class _ExerciseDetailBody extends ConsumerWidget {
  const _ExerciseDetailBody({required this.details});

  final ExerciseDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLevel = ref.watch(
      exerciseFiltersProvider.select((f) => f.userLevel),
    );
    final ownedAsync = ref.watch(ownedMasterEquipmentCodesProvider);
    final service = ref.watch(exerciseAvailabilityServiceProvider);

    return ownedAsync.when(
      data: (owned) {
        final requiredEquipment = details.equipment.where((e) => e.required);
        final status = service.evaluate(
          exercise: details.exercise,
          userLevel: userLevel,
          ownedEquipmentCodes: owned,
          requiredEquipmentCodes: requiredEquipment.map(
            (e) => e.equipment.code,
          ),
        );
        final missingEquipmentNames = requiredEquipment
            .where((e) => !owned.contains(e.equipment.code))
            .map((e) => e.equipment.name)
            .toList();

        return _DetailContent(
          details: details,
          status: status,
          missingEquipmentNames: missingEquipmentNames,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _MessageState(
        icon: Icons.error_outline,
        message: 'Non è stato possibile calcolare la disponibilità.',
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.details,
    required this.status,
    required this.missingEquipmentNames,
  });

  final ExerciseDetails details;
  final ExerciseAvailabilityStatus status;
  final List<String> missingEquipmentNames;

  @override
  Widget build(BuildContext context) {
    final exercise = details.exercise;
    final equipmentNames = details.equipment
        .where((e) => e.equipment.code != Equipment.noneCode)
        .map((e) => e.equipment.name)
        .toList();

    final levelLabel = exercise.maximumLevel == null
        ? 'Livello ${exercise.minimumLevel}+'
        : 'Livello ${exercise.minimumLevel}-${exercise.maximumLevel}';

    final params = <(String, String)>[
      if (exercise.defaultSets != null) ('Serie', '${exercise.defaultSets}'),
      if (exercise.defaultReps != null)
        ('Ripetizioni', '${exercise.defaultReps}'),
      if (exercise.defaultDurationSeconds != null)
        ('Durata', '${exercise.defaultDurationSeconds} sec'),
      if (exercise.defaultRestSeconds != null)
        ('Recupero', '${exercise.defaultRestSeconds} sec'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Header: nome, categoria/livello, disponibilità. Il codice
        // tecnico (es. "ARM-001") resta nel modello/DB per uso interno ma
        // non deve mai essere renderizzato in questa pagina.
        Text(exercise.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          '${details.category.name} · $levelLabel',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        AvailabilityBadge(status: status),
        if (status != ExerciseAvailabilityStatus.available) ...[
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.info_outline,
            text: ExerciseLabels.availabilityReason(
              status,
              requiredLevel: exercise.minimumLevel,
              missingEquipmentNames: missingEquipmentNames,
            ),
          ),
        ],
        const SizedBox(height: 20),
        // 2. Immagini/gallery.
        ExerciseImageGallery(
          images: details.images,
          categoryCode: details.category.code,
        ),
        const SizedBox(height: 16),
        // 3. Descrizione.
        _SectionCard(title: 'Descrizione', child: Text(exercise.description)),
        const SizedBox(height: 12),
        // 4. Come eseguirlo / istruzioni.
        _SectionCard(
          title: 'Come eseguirlo',
          child: _InstructionsList(instructions: exercise.instructions),
        ),
        // 5. Parametri allenamento.
        if (params.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Parametri',
            child: Wrap(
              spacing: 20,
              runSpacing: 12,
              children: params
                  .map((p) => _ParameterTile(label: p.$1, value: p.$2))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        // 6. Attrezzatura.
        _SectionCard(
          title: 'Attrezzatura',
          child: equipmentNames.isEmpty
              ? const Text('Nessuna attrezzatura')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: equipmentNames
                      .map((name) => Chip(label: Text(name)))
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        // 7. Muscoli coinvolti.
        _MusclesSection(
          primary: details.primaryMuscles,
          secondary: details.secondaryMuscles,
        ),
        // 8. Respirazione.
        if (exercise.breathingInstructions != null) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Respirazione',
            child: Text(exercise.breathingInstructions!),
          ),
        ],
        // 9. Errori comuni / da evitare.
        if (exercise.commonMistakes != null) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Errori da evitare',
            leadingIcon: Icons.report_gmailerrorred_outlined,
            child: Text(exercise.commonMistakes!),
          ),
        ],
        // 10. Sicurezza / note di sicurezza.
        if (exercise.safetyNotes != null) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Attenzione durante l\'esecuzione',
            leadingIcon: Icons.shield_outlined,
            child: Text(exercise.safetyNotes!),
          ),
        ],
        // 11. Progressioni e regressioni.
        if (details.progressions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _RelatedExerciseSection(
            title: 'Progressione',
            entries: details.progressions
                .map((p) => (p.target.id, p.target.name, null))
                .toList(),
          ),
        ],
        if (details.regressions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _RelatedExerciseSection(
            title: 'Variante precedente',
            entries: details.regressions
                .map((r) => (r.target.id, r.target.name, null))
                .toList(),
          ),
        ],
        if (details.alternatives.isNotEmpty) ...[
          const SizedBox(height: 12),
          _RelatedExerciseSection(
            title: 'Alternative',
            entries: details.alternatives
                .map(
                  (a) => (
                    a.target.id,
                    a.target.name,
                    ExerciseLabels.alternativeReason(a.reason),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.leadingIcon,
  });

  final String title;
  final Widget child;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18, color: ForgeColors.copper),
                  const SizedBox(width: 8),
                ],
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MusclesSection extends StatelessWidget {
  const _MusclesSection({required this.primary, required this.secondary});

  final List<MuscleGroup> primary;
  final List<MuscleGroup> secondary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Muscoli',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Principali', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: primary.map((m) => Chip(label: Text(m.name))).toList(),
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Secondari', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondary
                  .map(
                    (m) => Chip(
                      label: Text(m.name),
                      backgroundColor: ForgeColors.anthraciteSurfaceHigh,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InstructionsList extends StatelessWidget {
  const _InstructionsList({required this.instructions});

  final String instructions;

  List<String> _steps() {
    final lines = instructions
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final stepPattern = RegExp(r'^\d+\.\s*(.*)$');
    return lines.map((line) {
      final match = stepPattern.firstMatch(line);
      return match != null ? match.group(1)! : line;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();
    if (steps.length <= 1) {
      return Text(instructions);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: ForgeColors.copper,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: ForgeColors.anthracite,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(steps[i])),
              ],
            ),
          ),
      ],
    );
  }
}

class _ParameterTile extends StatelessWidget {
  const _ParameterTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ForgeColors.textSecondary),
        ),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _RelatedExerciseSection extends StatelessWidget {
  const _RelatedExerciseSection({required this.title, required this.entries});

  final String title;

  /// (id esercizio, nome, sottotitolo facoltativo — es. motivo alternativa).
  final List<(int, String, String?)> entries;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Column(
        children: entries
            .map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: ForgeColors.anthraciteSurfaceHigh,
                child: ListTile(
                  title: Text(entry.$2),
                  subtitle: entry.$3 == null ? null : Text(entry.$3!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(AppRoutes.exerciseDetailPath(entry.$1)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ForgeColors.anthraciteSurfaceHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: ForgeColors.copper),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
