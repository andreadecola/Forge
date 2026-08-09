import 'package:flutter/material.dart';

import 'forge_colors.dart';

/// Tema Forge: dark-oriented, industriale, Material 3.
abstract final class ForgeTheme {
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: ForgeColors.copper,
      onPrimary: ForgeColors.anthracite,
      secondary: ForgeColors.steelGray,
      onSecondary: ForgeColors.textPrimary,
      surface: ForgeColors.anthraciteSurface,
      onSurface: ForgeColors.textPrimary,
      surfaceContainerHighest: ForgeColors.anthraciteSurfaceHigh,
      error: ForgeColors.danger,
      onError: ForgeColors.textPrimary,
      outline: ForgeColors.steelGray,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ForgeColors.anthracite,
      appBarTheme: const AppBarTheme(
        backgroundColor: ForgeColors.anthracite,
        foregroundColor: ForgeColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ForgeColors.anthraciteSurface,
        indicatorColor: ForgeColors.copper.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? ForgeColors.copper : ForgeColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? ForgeColors.copper : ForgeColors.textSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: ForgeColors.anthraciteSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ForgeColors.steelGray, width: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ForgeColors.copper,
          foregroundColor: ForgeColors.anthracite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: ForgeColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: ForgeColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: ForgeColors.textPrimary),
        bodyMedium: TextStyle(color: ForgeColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: ForgeColors.steelGray,
        thickness: 0.6,
      ),
    );
  }
}
