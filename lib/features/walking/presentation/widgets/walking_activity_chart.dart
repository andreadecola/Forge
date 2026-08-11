import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../domain/entities/walking_activity_point.dart';

class WalkingActivityChart extends StatelessWidget {
  const WalkingActivityChart({super.key, required this.points});

  final List<WalkingActivityPoint> points;

  static const double _maxBarHeight = 80;

  @override
  Widget build(BuildContext context) {
    final maxCount = points
        .map((point) => point.sessionCount)
        .fold(0, math.max);
    final chartWidth = math.max(300.0, points.length * 48.0);

    return SizedBox(
      height: _maxBarHeight + 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
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
                                ? ForgeColors.steelGrayLight.withValues(
                                    alpha: 0.3,
                                  )
                                : ForgeColors.copper,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${point.periodStart.day}/${point.periodStart.month}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: ForgeColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
