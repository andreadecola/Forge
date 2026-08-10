import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import 'exercise_category_illustration.dart';

/// Placeholder Forge mostrato quando un'immagine non è disponibile
/// (asset non ancora presente, lista vuota, tipo sorgente non supportato).
/// Non deve mai apparire un errore Flutter rosso/giallo al suo posto.
///
/// Quando [categoryCode] è noto, al posto dell'icona generica mostra una
/// stick-figure disegnata internamente (nessun asset scaricato) che
/// richiama la posa tipica della categoria dell'esercizio.
class ExerciseImagePlaceholder extends StatelessWidget {
  const ExerciseImagePlaceholder({super.key, this.message, this.categoryCode});

  final String? message;
  final String? categoryCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ForgeColors.anthraciteSurfaceHigh,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Spazi molto piccoli (thumbnail di lista): solo l'icona, per
          // evitare testo compresso o overflow.
          final compact = constraints.maxHeight < 80;
          final code = categoryCode;
          final icon = code == null
              ? Icon(
                  Icons.accessibility_new,
                  size: compact ? 20 : 40,
                  color: ForgeColors.steelGrayLight,
                  semanticLabel: compact
                      ? (message ?? 'Immagine dimostrativa in preparazione')
                      : null,
                )
              : ExerciseCategoryIllustration(
                  categoryCode: code,
                  size: compact ? 28 : 48,
                );
          if (compact) {
            return icon;
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 8),
                Text(
                  message ?? 'Immagine dimostrativa in preparazione',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ForgeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
