import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

const _batchCodes = <String>{
  'MOB-001',
  'MOB-013',
  'LEG-002',
  'LEG-007',
  'LEG-018',
  'LEG-001',
  'LEG-012',
  'PUSH-003',
  'PUSH-005',
  'PUSH-009',
  'BACK-001',
  'BACK-002',
  'BACK-003',
  'BACK-004',
  'SHO-002',
  'SHO-006',
  'PUSH-001',
  'MOB-012',
  'ARM-001',
  'CORE-003',
  'CORE-005',
  'BAL-007',
  'STR-006',
  'CARD-004',
  'MOB-002',
  'MOB-003',
  'MOB-004',
  'MOB-006',
  'MOB-007',
  'MOB-008',
  'MOB-009',
  'MOB-014',
  'LEG-003',
  'LEG-004',
  'LEG-006',
  'LEG-009',
  'LEG-010',
  'LEG-013',
  'LEG-014',
  'LEG-015',
  'LEG-016',
  'PUSH-002',
  'PUSH-004',
  'PUSH-006',
  'PUSH-007',
  'PUSH-008',
  'PUSH-010',
  'BACK-005',
  'BACK-006',
  'BACK-007',
  'BACK-008',
  'BACK-009',
  'SHO-001',
  'SHO-003',
  'SHO-004',
  'SHO-005',
  'SHO-007',
  'SHO-008',
  'ARM-002',
  'ARM-003',
  'ARM-004',
  'ARM-005',
  'ARM-007',
  'CORE-001',
  'CORE-002',
  'CORE-004',
  'CORE-006',
  'CORE-007',
  'CORE-009',
  'BAL-001',
  'BAL-004',
};

const _newBatchCodes = <String>{
  'MOB-001',
  'MOB-013',
  'LEG-002',
  'LEG-007',
  'LEG-018',
  'PUSH-003',
  'PUSH-005',
  'BACK-003',
  'BACK-004',
  'SHO-002',
  'ARM-001',
  'CORE-003',
  'CORE-005',
  'BAL-007',
  'STR-006',
  'CARD-004',
};

const _targetBatchCodes = <String>{
  'MOB-002',
  'MOB-003',
  'MOB-004',
  'MOB-006',
  'MOB-007',
  'MOB-008',
  'MOB-009',
  'MOB-014',
  'LEG-003',
  'LEG-004',
  'LEG-006',
  'LEG-009',
  'LEG-010',
  'LEG-013',
  'LEG-014',
  'LEG-015',
  'LEG-016',
  'PUSH-002',
  'PUSH-004',
  'PUSH-006',
  'PUSH-007',
  'PUSH-008',
  'PUSH-010',
  'BACK-005',
  'BACK-006',
  'BACK-007',
  'BACK-008',
  'BACK-009',
  'SHO-001',
  'SHO-003',
  'SHO-004',
  'SHO-005',
  'SHO-007',
  'SHO-008',
  'ARM-002',
  'ARM-003',
  'ARM-004',
  'ARM-005',
  'ARM-007',
  'CORE-001',
  'CORE-002',
  'CORE-004',
  'CORE-006',
  'CORE-007',
  'CORE-009',
  'BAL-001',
  'BAL-004',
};

String _normalizedCode(String code) => code.toLowerCase().replaceAll('-', '_');

String _filesystemPath(String assetPath) =>
    assetPath.replaceAll('/', Platform.pathSeparator);

void main() {
  late Map<String, dynamic> catalog;

  setUpAll(() {
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    catalog = jsonDecode(raw) as Map<String, dynamic>;
  });

  test('il catalogo reale mantiene baseline e batch selezionato', () {
    final exercises = catalog['exercises'] as List<dynamic>;
    final imageReferences = exercises
        .expand(
          (exercise) =>
              (exercise as Map<String, dynamic>)['images'] as List<dynamic>,
        )
        .length;

    expect(catalog['catalogVersion'], 2);
    expect(exercises, hasLength(118));
    expect(imageReferences, 236);
    expect(_batchCodes, hasLength(71));
  });

  test('ogni asset del batch esiste ed e ordinato START/END', () {
    final exercises = catalog['exercises'] as List<dynamic>;
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final allPaths = <String>[];

    for (final exercise in exercises.cast<Map<String, dynamic>>()) {
      final code = exercise['code'] as String;
      final images = exercise['images'] as List<dynamic>;
      allPaths.addAll(
        images.cast<Map<String, dynamic>>().map(
          (image) => image['path'] as String,
        ),
      );
      if (!_batchCodes.contains(code)) continue;

      expect(images, hasLength(2), reason: code);
      expect(
        pubspec,
        contains('assets/images/img_allenamenti/${_normalizedCode(code)}/'),
        reason: code,
      );

      final start = images[0] as Map<String, dynamic>;
      final end = images[1] as Map<String, dynamic>;
      expect(start['type'], 'POSIZIONE_INIZIALE', reason: code);
      expect(start['sourceType'], 'ASSET', reason: code);
      expect(start['order'], 1, reason: code);
      expect(end['type'], 'POSIZIONE_FINALE', reason: code);
      expect(end['sourceType'], 'ASSET', reason: code);
      expect(end['order'], 2, reason: code);

      for (final image in [start, end]) {
        final path = image['path'] as String;
        expect(
          path,
          startsWith('assets/images/img_allenamenti/'),
          reason: code,
        );
        expect(path, endsWith('.jpg'), reason: code);
        expect(path, contains('/${_normalizedCode(code)}/'), reason: code);
        final file = File(_filesystemPath(path));
        expect(file.existsSync(), isTrue, reason: path);
        final dimensions = _jpegDimensions(file);
        expect(dimensions.$1, 1024, reason: path);
        expect(dimensions.$2, 1024, reason: path);
      }
    }

    expect(allPaths.toSet(), hasLength(allPaths.length));
  });

  test(
    'un esercizio fuori dal batch conserva il fallback senza asset locale',
    () {
      final exercises = catalog['exercises'] as List<dynamic>;
      final unworked = exercises.cast<Map<String, dynamic>>().firstWhere(
          (exercise) => exercise['code'] == 'MOB-005',
      );
      final images = unworked['images'] as List<dynamic>;

      expect(images, hasLength(2));
      for (final image in images.cast<Map<String, dynamic>>()) {
        final path = image['path'] as String;
        expect(File(_filesystemPath(path)).existsSync(), isFalse, reason: path);
      }
    },
  );

  test('il registry dichiara tutti gli asset del batch come ORIGINAL_FORGE', () {
    final registry = File(
      'assets/images/exercises/asset_registry.csv',
    ).readAsLinesSync();
    for (final code in _newBatchCodes) {
      final rows = registry
          .where(
            (row) =>
                row.startsWith('$code,') && row.contains(',ORIGINAL_FORGE,'),
          )
          .toList();
      expect(rows, hasLength(2), reason: code);
      expect(
        rows.every(
          (row) => row.endsWith(
            ',APPROVED,"Asset originale fotorealistico; batch IMMAGINI.3.1; 1024x1024 JPEG quality 88."',
          ),
        ),
        isTrue,
        reason: code,
      );
    }
  });

  test('il registry dichiara il batch target al 60% come ORIGINAL_FORGE', () {
    final registry = File(
      'assets/images/exercises/asset_registry.csv',
    ).readAsLinesSync();
    for (final code in _targetBatchCodes) {
      final rows = registry
          .where(
            (row) =>
                row.startsWith('$code,') && row.contains(',ORIGINAL_FORGE,'),
          )
          .toList();
      expect(rows, hasLength(2), reason: code);
      expect(
        rows.every(
          (row) => row.endsWith(
            ',APPROVED,"Asset originale fotorealistico; batch IMMAGINI.3 target 60%; 1024x1024 JPEG quality 88."',
          ),
        ),
        isTrue,
        reason: code,
      );
    }
  });

  test(
    'seed, repository e gallery ricevono i due asset reali in ordine',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await ExerciseCatalogSeeder(database).seedFromString(
        File('assets/data/exercises_v1.json').readAsStringSync(),
      );

      final repository = DriftExerciseRepository(database);
      final exercise = await repository.getExerciseByCode('LEG-001');
      expect(exercise, isNotNull);

      final images = await repository.getImages(exercise!.id);
      expect(images, hasLength(2));
      expect(images[0].imageType.code, 'POSIZIONE_INIZIALE');
      expect(images[0].path, 'assets/images/img_allenamenti/leg_001/start.jpg');
      expect(images[1].imageType.code, 'POSIZIONE_FINALE');
      expect(images[1].path, 'assets/images/img_allenamenti/leg_001/end.jpg');
    },
  );
}

(int, int) _jpegDimensions(File file) {
  final bytes = file.readAsBytesSync();
  if (bytes.length < 4 || bytes[0] != 0xff || bytes[1] != 0xd8) {
    throw StateError('JPEG non valido: ${file.path}');
  }

  var offset = 2;
  const sofMarkers = <int>{
    0xc0,
    0xc1,
    0xc2,
    0xc3,
    0xc5,
    0xc6,
    0xc7,
    0xc9,
    0xca,
    0xcb,
    0xcd,
    0xce,
    0xcf,
  };
  while (offset + 9 < bytes.length) {
    if (bytes[offset] != 0xff) {
      offset++;
      continue;
    }
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset++;
    }
    if (offset >= bytes.length) break;
    final marker = bytes[offset++];
    if (marker == 0xd9 || marker == 0xda) break;
    if (marker == 0xd8 || marker == 0x01) continue;
    if (offset + 1 >= bytes.length) break;
    final length = (bytes[offset] << 8) | bytes[offset + 1];
    if (sofMarkers.contains(marker)) {
      final height = (bytes[offset + 3] << 8) | bytes[offset + 4];
      final width = (bytes[offset + 5] << 8) | bytes[offset + 6];
      return (width, height);
    }
    offset += length;
  }
  throw StateError('Dimensioni JPEG non trovate: ${file.path}');
}
