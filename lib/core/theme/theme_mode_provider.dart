import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_provider.dart';
import '../../data/repositories/settings_repository_impl.dart';

ThemeMode forgeThemeModeFromStorage(String? value) => switch (value) {
  'light' => ThemeMode.light,
  null || 'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

/// Segue anche le modifiche effettuate dal ripristino dei backup.
final forgeThemeModeProvider = StreamProvider<ThemeMode>((ref) {
  return ref
      .watch(databaseProvider)
      .appSettingsDao
      .watchValue(SettingsKeys.themeMode)
      .map(forgeThemeModeFromStorage);
});
