import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repository_providers.dart';
import '../../application/equipment_providers.dart';

class MyEquipmentPage extends ConsumerWidget {
  const MyEquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      data: (profile) => profile == null
          ? const Scaffold(
              body: Center(child: Text('Completa prima l\'onboarding.')),
            )
          : _EquipmentPageBody(profileId: profile.id!),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Errore: $error'))),
    );
  }
}

class _EquipmentPageBody extends ConsumerWidget {
  const _EquipmentPageBody({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statesAsync = ref.watch(equipmentStatesProvider(profileId));
    return Scaffold(
      appBar: AppBar(title: const Text('La mia palestra')),
      body: statesAsync.when(
        data: (states) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: states.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final state = states[index];
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(state.item.label),
              value: state.owned,
              onChanged: (owned) => ref
                  .read(equipmentControllerProvider)
                  .setOwned(
                    profileId: profileId,
                    item: state.item,
                    owned: owned,
                  ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
      ),
    );
  }
}
