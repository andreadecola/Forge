import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Istanza condivisa del database, valida per l'intera durata dell'app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
