import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'backup_file_reader.dart';
import 'backup_read_result.dart';

/// Implementazione reale via `file_picker` (Backup.4, sezione 10): usa
/// `FilePicker.pickFiles` con filtro `.json` — non un affidamento sulla
/// sola estensione (sezione 11): il contenuto viene comunque validato da
/// `BackupJsonCodec`/`BackupValidator` più avanti, mai qui.
///
/// Legge le dimensioni (`PlatformFile.length()`) **prima** di caricare i
/// byte in memoria (`readAsBytes()`), per rispettare il limite
/// dimensionale senza dover comunque materializzare un file troppo
/// grande (Backup.4, sezione 14).
class FilePickerBackupFileReader implements BackupFileReader {
  const FilePickerBackupFileReader({
    this.dialogTitle = 'Seleziona un file di backup Forge',
  });

  final String dialogTitle;

  @override
  Future<BackupReadResult> pickAndReadBackup() async {
    final List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(
        dialogTitle: dialogTitle,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
    } on PlatformException catch (e) {
      return BackupReadResult.failure(
        BackupReadFailureReason.unexpectedPlatformFailure,
        'Errore piattaforma durante la selezione: ${e.message ?? e.code}',
      );
    } catch (e) {
      return BackupReadResult.failure(
        BackupReadFailureReason.storageUnavailable,
        'Selezione del file fallita: $e',
      );
    }

    if (files.isEmpty) {
      return BackupReadResult.cancelled();
    }
    // Se il picker restituisse più file nonostante il flusso preveda una
    // singola selezione, si usa solo il primo — mai un comportamento non
    // gestito.
    final file = files.first;

    final int length;
    try {
      length = await file.length();
    } catch (e) {
      return BackupReadResult.failure(
        BackupReadFailureReason.storageUnavailable,
        'Impossibile determinare la dimensione del file: $e',
      );
    }
    if (length > maxBackupFileSizeBytes) {
      return BackupReadResult.failure(
        BackupReadFailureReason.fileTooLarge,
        'File troppo grande ($length byte, limite $maxBackupFileSizeBytes '
        'byte).',
      );
    }

    final List<int> bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      return BackupReadResult.failure(
        BackupReadFailureReason.storageUnavailable,
        'Lettura del file fallita: $e',
      );
    }

    final String content;
    try {
      content = utf8.decode(bytes);
    } on FormatException catch (e) {
      return BackupReadResult.failure(
        BackupReadFailureReason.invalidEncoding,
        'Encoding non valido (atteso UTF-8): ${e.message}',
      );
    }

    return BackupReadResult.success(content);
  }
}
