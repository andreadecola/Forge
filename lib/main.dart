import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/repositories/catalog_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Un unico container condiviso con l'app, così il seed del catalogo usa la
  // stessa istanza di database della UI.
  final container = ProviderContainer();

  // Bootstrap del catalogo: idempotente e asincrono. Non blocca la UI (che
  // parte subito); gli errori vengono gestiti esplicitamente (log), non
  // ingoiati in silenzio.
  unawaited(_bootstrapCatalog(container));

  runApp(
    UncontrolledProviderScope(container: container, child: const ForgeApp()),
  );
}

Future<void> _bootstrapCatalog(ProviderContainer container) async {
  try {
    final result = await container.read(catalogBootstrapProvider.future);
    debugPrint(
      result.alreadyImported
          ? 'Catalogo già importato: nessuna modifica.'
          : 'Catalogo importato: ${result.exercises} esercizi.',
    );
  } catch (error, stackTrace) {
    debugPrint('Errore durante il bootstrap del catalogo: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
