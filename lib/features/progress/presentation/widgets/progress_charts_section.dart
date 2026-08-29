import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_colors.dart';
import '../../../../core/utils/italian_date_formatter.dart';
import '../../../../domain/entities/body_measurement.dart';
import '../../../../domain/entities/pressure_measurement.dart';
import '../../../../domain/entities/progress_chart_point.dart';
import '../../../../domain/services/progress_chart_service.dart';
import '../progress_metrics.dart';

enum ProgressChartMetric { weight, waist, pressure }

/// Historical charts for the measurements already loaded by ProgressPage.
///
/// The widget owns only ephemeral selection state. The two [AsyncValue]s are
/// the same streams used by the dashboard cards, so changing CRUD data updates
/// the selected chart without issuing per-chart queries.
class ProgressChartsSection extends StatefulWidget {
  const ProgressChartsSection({
    super.key,
    required this.bodyMeasurements,
    required this.pressureMeasurements,
    required this.now,
  });

  final AsyncValue<List<BodyMeasurement>> bodyMeasurements;
  final AsyncValue<List<PressureMeasurement>> pressureMeasurements;
  final DateTime now;

  @override
  State<ProgressChartsSection> createState() => _ProgressChartsSectionState();
}

class _ProgressChartsSectionState extends State<ProgressChartsSection> {
  ProgressChartMetric _metric = ProgressChartMetric.weight;
  ProgressChartRange _range = ProgressChartRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Andamento', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_metricTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricChip(
                  context,
                  metric: ProgressChartMetric.weight,
                  label: 'Peso (kg)',
                ),
                _metricChip(
                  context,
                  metric: ProgressChartMetric.waist,
                  label: 'Girovita (cm)',
                ),
                _metricChip(
                  context,
                  metric: ProgressChartMetric.pressure,
                  label: 'Pressione (mmHg)',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _rangeChip(
                  context,
                  range: ProgressChartRange.sevenDays,
                  label: '7 giorni',
                ),
                _rangeChip(
                  context,
                  range: ProgressChartRange.thirtyDays,
                  label: '30 giorni',
                ),
                _rangeChip(
                  context,
                  range: ProgressChartRange.ninetyDays,
                  label: '90 giorni',
                ),
                _rangeChip(
                  context,
                  range: ProgressChartRange.all,
                  label: 'Tutto',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSelectedChart(context),
          ],
        ),
      ),
    );
  }

  String get _metricTitle => switch (_metric) {
    ProgressChartMetric.weight => 'Peso (kg)',
    ProgressChartMetric.waist => 'Girovita (cm)',
    ProgressChartMetric.pressure => 'Pressione (mmHg)',
  };

  Widget _metricChip(
    BuildContext context, {
    required ProgressChartMetric metric,
    required String label,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _metric == metric,
      onSelected: (selected) {
        if (selected) setState(() => _metric = metric);
      },
    );
  }

  Widget _rangeChip(
    BuildContext context, {
    required ProgressChartRange range,
    required String label,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _range == range,
      onSelected: (selected) {
        if (selected) setState(() => _range = range);
      },
    );
  }

  Widget _buildSelectedChart(BuildContext context) {
    switch (_metric) {
      case ProgressChartMetric.weight:
        return widget.bodyMeasurements.when(
          data: (measurements) => _BodyMetricChart(
            points: ProgressChartService.weightPoints(
              measurements: measurements,
              range: _range,
              now: widget.now,
            ),
            title: 'Peso',
            unit: 'kg',
            formatValue: (value) => formatWeightKg(value),
            color: Theme.of(context).colorScheme.primary,
          ),
          loading: () => const _ChartLoading(),
          error: (error, _) => _ChartError(error: error),
        );
      case ProgressChartMetric.waist:
        return widget.bodyMeasurements.when(
          data: (measurements) => _BodyMetricChart(
            points: ProgressChartService.waistPoints(
              measurements: measurements,
              range: _range,
              now: widget.now,
            ),
            title: 'Girovita',
            unit: 'cm',
            formatValue: (value) => formatWaistCm(value),
            color: Theme.of(context).colorScheme.primary,
          ),
          loading: () => const _ChartLoading(),
          error: (error, _) => _ChartError(error: error),
        );
      case ProgressChartMetric.pressure:
        return widget.pressureMeasurements.when(
          data: (measurements) => _PressureChart(
            points: ProgressChartService.pressurePoints(
              measurements: measurements,
              range: _range,
              now: widget.now,
            ),
          ),
          loading: () => const _ChartLoading(),
          error: (error, _) => _ChartError(error: error),
        );
    }
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Text('Errore nel caricamento dei dati: $error');
  }
}

class _BodyMetricChart extends StatelessWidget {
  const _BodyMetricChart({
    required this.points,
    required this.title,
    required this.unit,
    required this.formatValue,
    required this.color,
  });

  final List<BodyMetricPoint> points;
  final String title;
  final String unit;
  final String Function(double value) formatValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _ChartEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChartCount(count: points.length),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: _LineChart(
            series: [
              _ChartSeries(
                label: title,
                unit: unit,
                color: color,
                points: [
                  for (final point in points)
                    _ChartValue(date: point.measuredAt, value: point.value),
                ],
                formatValue: formatValue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PressureChart extends StatelessWidget {
  const _PressureChart({required this.points});

  final List<PressureChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _ChartEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ChartLegend(
          entries: [
            _LegendEntry(label: 'Sistolica', color: ForgeColors.copper),
            _LegendEntry(
              label: 'Diastolica',
              color: ForgeColors.steelGrayLight,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ChartCount(count: points.length),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: _LineChart(
            series: [
              _ChartSeries(
                label: 'Sistolica',
                unit: 'mmHg',
                color: ForgeColors.copper,
                points: [
                  for (final point in points)
                    _ChartValue(
                      date: point.measuredAt,
                      value: point.systolic.toDouble(),
                    ),
                ],
                formatValue: (value) => '${value.round()} mmHg',
              ),
              _ChartSeries(
                label: 'Diastolica',
                unit: 'mmHg',
                color: ForgeColors.steelGrayLight,
                points: [
                  for (final point in points)
                    _ChartValue(
                      date: point.measuredAt,
                      value: point.diastolic.toDouble(),
                    ),
                ],
                formatValue: (value) => '${value.round()} mmHg',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('Nessun dato disponibile per questo intervallo'),
    );
  }
}

class _ChartCount extends StatelessWidget {
  const _ChartCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${count == 1 ? 'misurazione' : 'misurazioni'} nel periodo selezionato',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.entries});

  final List<_LegendEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(entry.label),
            ],
          ),
      ],
    );
  }
}

class _LegendEntry {
  const _LegendEntry({required this.label, required this.color});

  final String label;
  final Color color;
}

class _ChartValue {
  const _ChartValue({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class _ChartSeries {
  const _ChartSeries({
    required this.label,
    required this.unit,
    required this.color,
    required this.points,
    required this.formatValue,
  });

  final String label;
  final String unit;
  final Color color;
  final List<_ChartValue> points;
  final String Function(double value) formatValue;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.series});

  final List<_ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    final allPoints = [for (final chartSeries in series) ...chartSeries.points];
    final xValues = allPoints
        .map((point) => point.date.millisecondsSinceEpoch.toDouble())
        .toList();
    final yValues = allPoints.map((point) => point.value).toList();
    final xBounds = _axisBounds(xValues, const Duration(days: 1));
    final yBounds = _axisBounds(yValues, null);

    return LineChart(
      LineChartData(
        minX: xBounds.$1,
        maxX: xBounds.$2,
        minY: yBounds.$1,
        maxY: yBounds.$2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: _axisInterval(yBounds.$1, yBounds.$2),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(_formatAxisNumber(value)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _axisInterval(xBounds.$1, xBounds.$2),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(_formatAxisDate(value)),
              ),
            ),
          ),
        ),
        lineBarsData: [
          for (final chartSeries in series)
            LineChartBarData(
              spots: [
                for (final point in chartSeries.points)
                  FlSpot(
                    point.date.millisecondsSinceEpoch.toDouble(),
                    point.value,
                  ),
              ],
              color: chartSeries.color,
              barWidth: 3,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => [
              for (final spot in spots) _tooltipItem(context, spot),
            ],
          ),
        ),
      ),
    );
  }

  LineTooltipItem _tooltipItem(BuildContext context, LineBarSpot spot) {
    final chartSeries = series[spot.barIndex];
    final point = chartSeries.points[spot.spotIndex];
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    return LineTooltipItem(
      '${chartSeries.label}: ${chartSeries.formatValue(point.value)}\n'
      '${formatItalianDate(point.date)} · ${formatItalianTime(point.date)}',
      textStyle,
    );
  }

  static (double, double) _axisBounds(List<double> values, Duration? padding) {
    final min = values.reduce((left, right) => left < right ? left : right);
    final max = values.reduce((left, right) => left > right ? left : right);
    if (min != max) return (min, max);

    final valuePadding =
        padding?.inMilliseconds.toDouble() ??
        (min.abs() * 0.1).clamp(1, double.infinity).toDouble();
    return (min - valuePadding, max + valuePadding);
  }

  static double _axisInterval(double min, double max) {
    final span = max - min;
    return span / 3;
  }

  static String _formatAxisNumber(double value) {
    final rounded = value.roundToDouble();
    return value == rounded
        ? rounded.toInt().toString()
        : value.toStringAsFixed(1);
  }

  static String _formatAxisDate(double value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.round());
    return '${date.day}/${date.month}';
  }
}
