class WalkingSessionValidationResult {
  const WalkingSessionValidationResult({required this.errors});

  static const valid = WalkingSessionValidationResult(errors: []);

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}
