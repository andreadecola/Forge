import 'package:flutter/material.dart';

/// Palette Forge: antracite, grigio acciaio, rame/arancio come accento.
abstract final class ForgeColors {
  static Color successFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF86D7AB)
      : const Color(0xFF24613F);
  static Color warningFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFD180)
      : const Color(0xFF805000);
  static const Color anthracite = Color(0xFF16171B);
  static const Color anthraciteSurface = Color(0xFF1F2126);
  static const Color anthraciteSurfaceHigh = Color(0xFF282B31);
  static const Color steelGray = Color(0xFF4B4F58);
  static const Color steelGrayLight = Color(0xFF8A8E99);
  static const Color copper = Color(0xFFD9722C);
  static const Color copperLight = Color(0xFFE8944F);
  static const Color textPrimary = Color(0xFFEDEDEF);
  static const Color textSecondary = Color(0xFFB4B7BF);
  static const Color danger = Color(0xFFCF5B4A);
  static const Color success = Color(0xFF6FA88A);
}
