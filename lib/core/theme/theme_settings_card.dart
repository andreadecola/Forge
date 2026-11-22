import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';
import 'theme_mode_provider.dart';

class ThemeSettingsCard extends ConsumerWidget {
  const ThemeSettingsCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode =
        ref.watch(forgeThemeModeProvider).valueOrNull ?? ThemeMode.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aspetto', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Scegli il tema più comodo per te.'),
            Wrap(
              spacing: 8,
              children: [
                for (final item in const {
                  ThemeMode.system: 'Sistema',
                  ThemeMode.light: 'Chiaro',
                  ThemeMode.dark: 'Scuro',
                }.entries)
                  ChoiceChip(
                    label: Text(item.value),
                    selected: mode == item.key,
                    onSelected: (_) async {
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .setThemeMode(item.key.name);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Impossibile salvare il tema. Riprova.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
