import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'backup_file_storage.dart';
import 'backup_save_result.dart';

/// Implementazione reale via Storage Access Framework Android (Backup.3,
/// sezione 6/7): usa `FilePicker.saveFile` (package `file_picker`), che
/// su Android apre `ACTION_CREATE_DOCUMENT` e scrive [content] al
/// content-provider di destinazione scelto dall'utente — nessun
/// permesso storage legacy, nessun path filesystem assunto (l'esito è
/// sempre un `Uri` opaco, tipicamente `content://...`).
///
/// `null` di ritorno da `FilePicker.saveFile` significa "utente ha
/// annullato il picker" (documentato dal package): mai un errore
/// (Backup.3, sezione 14).
class FilePickerBackupFileStorage implements BackupFileStorage {
  const FilePickerBackupFileStorage({this.dialogTitle = 'Salva backup Forge'});

  final String dialogTitle;

  @override
  Future<BackupSaveResult> saveBackup({
    required String suggestedFileName,
    required String content,
  }) async {
    final Uint8List bytes;
    try {
      bytes = Uint8List.fromList(utf8.encode(content));
    } catch (e) {
      return BackupSaveResult.failure(
        BackupSaveFailureReason.invalidResult,
        'Codifica UTF-8 del backup fallita: $e',
      );
    }

    final Uri? savedUri;
    try {
      savedUri = await FilePicker.saveFile(
        fileName: suggestedFileName,
        bytes: bytes,
        mimeType: 'application/json',
        dialogTitle: dialogTitle,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
    } on PlatformException catch (e) {
      return BackupSaveResult.failure(
        BackupSaveFailureReason.unexpectedPlatformFailure,
        'Errore piattaforma durante il salvataggio: ${e.message ?? e.code}',
      );
    } catch (e) {
      return BackupSaveResult.failure(
        BackupSaveFailureReason.writeFailed,
        'Scrittura del file di backup fallita: $e',
      );
    }

    if (savedUri == null) {
      return BackupSaveResult.cancelled();
    }
    return BackupSaveResult.success(savedUri.toString());
  }
}
