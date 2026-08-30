import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/constants/app_constants.dart';

/// `AppConstants.appVersion` (Backup.2, sezione 4) rispecchia
/// manualmente il campo `version:` di `pubspec.yaml`, in assenza di
/// `package_info_plus` (nessuna dipendenza aggiunta solo per questo
/// campo diagnostico). Questo test rileva una futura divergenza — es.
/// un bump di `pubspec.yaml` senza aggiornare la costante — che
/// altrimenti nessun meccanismo automatico segnalerebbe (Backup.5,
/// hardening, sezione 13).
void main() {
  test('AppConstants.appVersion corrisponde alla parte semantica di '
      'pubspec.yaml (senza build number)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(
      match,
      isNotNull,
      reason:
          'Campo "version:" non trovato o in un formato inatteso in '
          'pubspec.yaml.',
    );
    final pubspecVersion = match!.group(1);

    expect(
      AppConstants.appVersion,
      pubspecVersion,
      reason:
          'AppConstants.appVersion ("${AppConstants.appVersion}") non '
          'corrisponde più a pubspec.yaml ("$pubspecVersion"): '
          'aggiornarla manualmente (nessuna sincronizzazione automatica '
          'esiste, Backup.2 sezione 4/13).',
    );
  });
}
