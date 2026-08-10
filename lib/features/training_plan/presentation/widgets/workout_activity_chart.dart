import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/workout_activity_point.dart';

/// Grafico ad barre semplice (Milestone 4.5.2, sezione 26): widget Flutter
/// puri, nessuna libreria grafica — non necessaria per una manciata di
/// barre. Mostra sempre valori reali: uno zero è una barra reale (nessuna
/// sessione quel giorno/settimana/mese), non un dato inventato (sezione
/// 27) — l'assenza *totale* di dati è invece gestita a monte da chi
/// costruisce [points] (vuota se non ci sono sessioni nel periodo).
class WorkoutActivityChart extends StatelessWidget {
  const WorkoutActivityChart({super.key, required this.points});

  final List<WorkoutActivityPoint> points;

  static const double _maxBarHeight = 80;

  @override
  Widget build(BuildContext context) {
    final maxCount = points
        .map((p) => p.sessionCount)
        .fold(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: _maxBarHeight + 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${point.sessionCount}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: maxCount == 0
                          ? 4
                          : (point.sessionCount / maxCount * _maxBarHeight)
                                .clamp(4, _maxBarHeight),
                      decoration: BoxDecoration(
                        color: point.sessionCount == 0
                            ? ForgeColors.steelGrayLight.withValues(alpha: 0.3)
                            : ForgeColors.copper,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${point.periodStart.day}/${point.periodStart.month}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ForgeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
