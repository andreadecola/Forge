/// Parses the decimal notation used by the manual numeric fields in Forge.
/// Both Italian comma and dot notation are accepted.
double? parseDecimalInput(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized.replaceAll(',', '.'));
}
