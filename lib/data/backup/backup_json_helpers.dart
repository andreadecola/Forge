import 'backup_format_exception.dart';

/// Lettura tipizzata da un `Map<String, dynamic>` JSON già decodificato,
/// con errori strutturati (mai un cast/null-check grezzo, Backup.2
/// sezioni 45/46) — condivisa da ogni `fromJson` dei modelli di backup.
int requireInt(Map<String, dynamic> json, String key, String path) {
  final value = _require(json, key, path);
  if (value is int) return value;
  throw BackupFormatException(path, _typeError(key, 'int', value));
}

int? optionalInt(Map<String, dynamic> json, String key, String path) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  throw BackupFormatException(path, _typeError(key, 'int?', value));
}

double requireDouble(Map<String, dynamic> json, String key, String path) {
  final value = _require(json, key, path);
  if (value is num) return value.toDouble();
  throw BackupFormatException(path, _typeError(key, 'number', value));
}

double? optionalDouble(Map<String, dynamic> json, String key, String path) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  throw BackupFormatException(path, _typeError(key, 'number?', value));
}

String requireString(Map<String, dynamic> json, String key, String path) {
  final value = _require(json, key, path);
  if (value is String) return value;
  throw BackupFormatException(path, _typeError(key, 'string', value));
}

String? optionalString(Map<String, dynamic> json, String key, String path) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw BackupFormatException(path, _typeError(key, 'string?', value));
}

bool requireBool(Map<String, dynamic> json, String key, String path) {
  final value = _require(json, key, path);
  if (value is bool) return value;
  throw BackupFormatException(path, _typeError(key, 'bool', value));
}

/// Lista obbligatoria (può essere vuota, ma la chiave deve esistere ed
/// essere una lista JSON) di oggetti `Map<String, dynamic>`.
List<Map<String, dynamic>> requireObjectList(
  Map<String, dynamic> json,
  String key,
  String path,
) {
  final value = _require(json, key, path);
  if (value is! List) {
    throw BackupFormatException(path, _typeError(key, 'array', value));
  }
  final result = <Map<String, dynamic>>[];
  for (var i = 0; i < value.length; i++) {
    final item = value[i];
    if (item is! Map<String, dynamic>) {
      throw BackupFormatException(
        '$path.$key[$i]',
        'Elemento di tipo errato: atteso object, trovato '
            '${item.runtimeType}.',
      );
    }
    result.add(item);
  }
  return result;
}

Map<String, dynamic> requireObject(
  Map<String, dynamic> json,
  String key,
  String path,
) {
  final value = _require(json, key, path);
  if (value is Map<String, dynamic>) return value;
  throw BackupFormatException(path, _typeError(key, 'object', value));
}

Object _require(Map<String, dynamic> json, String key, String path) {
  if (!json.containsKey(key)) {
    throw BackupFormatException(path, 'Campo obbligatorio "$key" assente.');
  }
  final value = json[key];
  if (value == null) {
    throw BackupFormatException(path, 'Campo obbligatorio "$key" nullo.');
  }
  return value;
}

String _typeError(String key, String expected, Object? value) =>
    'Campo "$key" di tipo errato: atteso $expected, trovato '
    '${value.runtimeType}.';
