import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/backup/backup_filename.dart';

void main() {
  test('genera esattamente forge_backup_YYYYMMDD_HHMMSS.json con clock '
      'fisso', () {
    final instant = DateTime(2026, 8, 30, 7, 30, 15);
    expect(
      BackupFilename.generate(instant),
      'forge_backup_20260830_073015.json',
    );
  });

  test('due istanti a un secondo di distanza producono nomi distinti', () {
    final a = BackupFilename.generate(DateTime(2026, 1, 1, 12, 0, 0));
    final b = BackupFilename.generate(DateTime(2026, 1, 1, 12, 0, 1));
    expect(a, isNot(b));
  });

  test('non contiene mai : / o spazi', () {
    final name = BackupFilename.generate(DateTime(2026, 12, 31, 23, 59, 59));
    expect(name, isNot(contains(':')));
    expect(name, isNot(contains('/')));
    expect(name, isNot(contains(' ')));
  });

  test(
    'componenti a singola cifra sono zero-paddate (es. gennaio, ore 09)',
    () {
      final name = BackupFilename.generate(DateTime(2026, 1, 5, 9, 3, 7));
      expect(name, 'forge_backup_20260105_090307.json');
    },
  );
}
