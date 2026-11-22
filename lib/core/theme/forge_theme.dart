import 'package:flutter/material.dart';
import 'forge_typography.dart';

/// Ambra sportiva e Blu elettrico con contrasti accessibili.
abstract final class ForgeTheme {
  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);
  static ThemeData preview(bool dark, String family) =>
      _build(dark, family: family);
  static ThemeData _build(bool dark, {String? family}) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: dark ? const Color(0xFF3B82F6) : const Color(0xFFB45309),
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: dark ? const Color(0xFF3B82F6) : const Color(0xFFB45309),
          onPrimary: dark ? const Color(0xFF071426) : Colors.white,
          secondary: dark ? const Color(0xFF60A5FA) : const Color(0xFF795A29),
          surface: dark ? const Color(0xFF242C39) : Colors.white,
          onSurface: dark ? const Color(0xFFF1F5FC) : const Color(0xFF3B3020),
          onSurfaceVariant: dark
              ? const Color(0xFFBAC8DD)
              : const Color(0xFF74624B),
          primaryContainer: dark
              ? const Color(0xFF243E66)
              : const Color(0xFFFEF3C7),
          onPrimaryContainer: dark
              ? const Color(0xFFDCEAFF)
              : const Color(0xFF603000),
        );
    var base = ThemeData(useMaterial3: true, colorScheme: scheme);
    if (family != null) {
      base = base.copyWith(
        textTheme: ForgeTypography.proposed(base.textTheme, family),
      );
    }
    final button = FilledButton.styleFrom(
      minimumSize: const Size(48, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: family == null
          ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
          : base.textTheme.labelLarge,
    );
    final background = dark ? const Color(0xFF151A23) : const Color(0xFFFFFBF0);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        toolbarHeight: family == null ? null : 72,
        titleTextStyle: family == null
            ? null
            : base.textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(style: button),
      elevatedButtonTheme: ElevatedButtonThemeData(style: button),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? scheme.secondary : scheme.primary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: family == null ? null : base.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: dark ? scheme.secondary : scheme.primary,
          textStyle: family == null ? null : base.textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: scheme.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      chipTheme: base.chipTheme.copyWith(
        showCheckmark: true,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
