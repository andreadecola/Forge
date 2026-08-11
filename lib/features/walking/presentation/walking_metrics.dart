// Pure parsing and formatting helpers for manually entered walking metrics.

int? parseWalkingDistanceKm(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;

  final parsed = double.tryParse(normalized.replaceAll(',', '.'));
  if (parsed == null || !parsed.isFinite || parsed < 0) return null;
  return (parsed * 1000).round();
}

int? parseWalkingSteps(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^\d+$').hasMatch(normalized)) return null;

  final parsed = int.tryParse(normalized);
  return parsed == null || parsed < 0 ? null : parsed;
}

String formatWalkingDistance(int meters) {
  if (meters < 1000) return '$meters m';
  final kilometers = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$kilometers km';
}

String formatWalkingSteps(int steps) {
  final raw = steps.toString();
  final groups = <String>[];
  for (var end = raw.length; end > 0; end -= 3) {
    final start = end - 3 < 0 ? 0 : end - 3;
    groups.insert(0, raw.substring(start, end));
  }
  return groups.join('.');
}

/// Keeps the exact meter value when pre-filling the kilometre field.
String formatWalkingDistanceForInput(int meters) {
  final value = (meters / 1000).toStringAsFixed(3);
  return value.replaceFirst(RegExp(r'\.?0+$'), '').replaceAll('.', ',');
}

class WalkingMetricsInput {
  const WalkingMetricsInput({
    required this.distanceMeters,
    required this.steps,
  });

  final int? distanceMeters;
  final int? steps;
}
