import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/activity_level.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/services/body_metrics_service.dart';
import '../../../equipment/application/equipment_providers.dart';
import '../../../pressure/application/pressure_providers.dart';
import '../../../training_plan/presentation/widgets/active_session_banner.dart';
import '../../../walking/presentation/widgets/walking_entry_card.dart';
import '../../../weight/application/weight_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('FORGE')),
      body: profileAsync.when(
        data: (profile) => profile == null
            ? const Center(child: CircularProgressIndicator())
            : _DashboardBody(profile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileId = profile.id!;
    final latestWeightAsync = ref.watch(latestWeightProvider(profileId));
    final latestPressureAsync = ref.watch(latestPressureProvider(profileId));
    final ownedEquipmentAsync = ref.watch(ownedEquipmentProvider(profileId));

    final currentWeight = latestWeightAsync.valueOrNull?.weightKg;

    double? bmi;
    double? bmr;
    double? tdee;
    double? weightDifference;
    if (currentWeight != null) {
      bmi = BodyMetricsService.calculateBmi(
        weightKg: currentWeight,
        heightCm: profile.heightCm,
      );
      bmr = BodyMetricsService.calculateBmr(
        weightKg: currentWeight,
        heightCm: profile.heightCm,
        age: calculateAge(profile.birthDate),
        biologicalSexForFormula: profile.biologicalSexForFormula,
      );
      tdee = BodyMetricsService.calculateTdee(
        bmr: bmr,
        activityFactor: ActivityFactors.factorFor(profile.activityLevel),
      );
      weightDifference = BodyMetricsService.calculateWeightDifference(
        initialWeight: profile.initialWeightKg,
        currentWeight: currentWeight,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Ciao, ${profile.name}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Il bisogno di ricominciare.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ForgeColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const ActiveSessionBanner(),
        const SizedBox(height: 16),
        WalkingEntryCard(profileId: profile.id!),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metricRow(
                  context,
                  'Peso attuale',
                  currentWeight == null
                      ? null
                      : '${currentWeight.toStringAsFixed(1)} kg',
                ),
                _metricRow(
                  context,
                  'Variazione',
                  weightDifference == null
                      ? null
                      : '${weightDifference >= 0 ? '+' : ''}${weightDifference.toStringAsFixed(1)} kg',
                ),
                _metricRow(context, 'BMI', bmi?.toStringAsFixed(1)),
                _metricRow(
                  context,
                  'BMR stimato',
                  bmr == null ? null : '${bmr.toStringAsFixed(0)} kcal/giorno',
                  unavailableHint: bmr == null && currentWeight != null
                      ? 'Imposta il parametro sesso nel profilo per stimarlo'
                      : null,
                ),
                _metricRow(
                  context,
                  'TDEE stimato',
                  tdee == null
                      ? null
                      : '${tdee.toStringAsFixed(0)} kcal/giorno',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metricRow(
                  context,
                  'Camminata preferita',
                  '${profile.preferredWalkMinutes} min',
                ),
                latestPressureAsync.when(
                  data: (pressure) => _metricRow(
                    context,
                    'Ultima pressione',
                    pressure == null
                        ? null
                        : '${pressure.systolic}/${pressure.diastolic} mmHg',
                  ),
                  loading: () => _metricRow(context, 'Ultima pressione', null),
                  error: (_, _) =>
                      _metricRow(context, 'Ultima pressione', null),
                ),
                ownedEquipmentAsync.when(
                  data: (equipment) => _metricRow(
                    context,
                    'Attrezzatura posseduta',
                    equipment.isEmpty
                        ? null
                        : equipment.map((e) => e.item.label).join(', '),
                  ),
                  loading: () =>
                      _metricRow(context, 'Attrezzatura posseduta', null),
                  error: (_, _) =>
                      _metricRow(context, 'Attrezzatura posseduta', null),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Catalogo esercizi'),
            subtitle: const Text(
              '118 esercizi domestici, con filtri e progressioni',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.exercises),
          ),
        ),
        const SizedBox(height: 24),
        Text('Azioni rapide', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _quickAction(
              context,
              Icons.monitor_weight_outlined,
              'Peso',
              AppRoutes.progress,
            ),
            _quickAction(
              context,
              Icons.favorite_outline,
              'Pressione',
              AppRoutes.pressure,
            ),
            _quickAction(
              context,
              Icons.fitness_center_outlined,
              'Attrezzatura',
              AppRoutes.equipment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricRow(
    BuildContext context,
    String label,
    String? value, {
    String? unavailableHint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value ?? 'Non disponibile',
                  textAlign: TextAlign.end,
                  style: value == null
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodyLarge,
                ),
                if (unavailableHint != null)
                  Text(
                    unavailableHint,
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return OutlinedButton.icon(
      onPressed: () => context.push(route),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
