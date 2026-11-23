import 'package:flutter/material.dart';

/// Scala tipografica condivisa: Inter in tutti i temi e tutte le build.
abstract final class ForgeTypography {
  static const bodySize = 16.0;
  static const family = 'Inter';
  static const badgeSize = 13.0;
  static const captionSize = 13.0;
  static const secondarySize = 14.0;

  static TextTheme proposed(TextTheme base, String family) {
    TextStyle style(
      double size,
      FontWeight weight,
      double height, {
      double spacing = 0,
    }) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
    );
    TextStyle timer(double size) => style(
      size,
      FontWeight.w700,
      1.15,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return base.copyWith(
      displayLarge: timer(56),
      displayMedium: timer(48),
      displaySmall: timer(40),
      headlineLarge: style(28, FontWeight.w700, 1.25, spacing: -.3),
      headlineMedium: style(28, FontWeight.w700, 1.25, spacing: -.3),
      headlineSmall: style(26, FontWeight.w700, 1.25, spacing: -.2),
      titleLarge: style(20, FontWeight.w600, 1.3),
      titleMedium: style(18, FontWeight.w600, 1.35),
      titleSmall: style(16, FontWeight.w600, 1.4),
      bodyLarge: style(16, FontWeight.w400, 1.5),
      bodyMedium: style(16, FontWeight.w400, 1.5),
      bodySmall: style(14, FontWeight.w400, 1.45),
      labelLarge: style(16, FontWeight.w600, 1.3),
      labelMedium: style(13, FontWeight.w600, 1.3),
      labelSmall: style(12, FontWeight.w600, 1.3),
    );
  }
}
