/// Prestazione effettiva di una serie: separata dalla prescrizione snapshot.
class SetPerformance {
  const SetPerformance({
    required this.setNumber,
    this.repetitions,
    this.durationSeconds,
    this.loadKg,
    this.effort,
  });
  final int setNumber;
  final int? repetitions;
  final int? durationSeconds;
  final double? loadKg;

  /// Difficoltà percepita soggettiva da 1 a 10.
  final int? effort;

  void validate() {
    if (setNumber < 1 ||
        (repetitions != null && repetitions! < 0) ||
        (durationSeconds != null && durationSeconds! < 0) ||
        (loadKg != null && (!loadKg!.isFinite || loadKg! < 0)) ||
        (effort != null && (effort! < 1 || effort! > 10))) {
      throw const FormatException('Prestazione della serie non valida.');
    }
    if (repetitions == null &&
        durationSeconds == null &&
        loadKg == null &&
        effort == null) {
      throw const FormatException(
        'Inserisci almeno una prestazione effettiva.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'repetitions': repetitions,
    'durationSeconds': durationSeconds,
    'loadKg': loadKg,
    'effort': effort,
  };

  static SetPerformance fromJson(dynamic json) {
    if (json is! Map<String, dynamic> ||
        json['setNumber'] is! int ||
        (json['repetitions'] != null && json['repetitions'] is! int) ||
        (json['durationSeconds'] != null && json['durationSeconds'] is! int) ||
        (json['loadKg'] != null && json['loadKg'] is! num) ||
        (json['effort'] != null && json['effort'] is! int)) {
      throw const FormatException('Formato prestazione non valido.');
    }
    final value = SetPerformance(
      setNumber: json['setNumber'] as int,
      repetitions: json['repetitions'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      loadKg: (json['loadKg'] as num?)?.toDouble(),
      effort: json['effort'] as int?,
    );
    value.validate();
    return value;
  }

  static List<SetPerformance> decodeList(dynamic json, {int? totalSets}) {
    if (json == null) return const [];
    if (json is! List) {
      throw const FormatException('Elenco prestazioni non valido.');
    }
    final values = json.map(fromJson).toList();
    if (values.map((v) => v.setNumber).toSet().length != values.length ||
        (totalSets != null && values.any((v) => v.setNumber > totalSets))) {
      throw const FormatException('Numero serie non valido o duplicato.');
    }
    return values..sort((a, b) => a.setNumber.compareTo(b.setNumber));
  }
}
