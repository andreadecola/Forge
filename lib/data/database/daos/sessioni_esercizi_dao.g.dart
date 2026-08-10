// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessioni_esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$SessioniEserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  $SessioniAllenamentoTableTable get sessioniAllenamentoTable =>
      attachedDatabase.sessioniAllenamentoTable;
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $AllenamentiEserciziTableTable get allenamentiEserciziTable =>
      attachedDatabase.allenamentiEserciziTable;
  $SessioniEserciziTableTable get sessioniEserciziTable =>
      attachedDatabase.sessioniEserciziTable;
  SessioniEserciziDaoManager get managers => SessioniEserciziDaoManager(this);
}

class SessioniEserciziDaoManager {
  final _$SessioniEserciziDaoMixin _db;
  SessioniEserciziDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
  $$AllenamentiTableTableTableManager get allenamentiTable =>
      $$AllenamentiTableTableTableManager(
        _db.attachedDatabase,
        _db.allenamentiTable,
      );
  $$SessioniAllenamentoTableTableTableManager get sessioniAllenamentoTable =>
      $$SessioniAllenamentoTableTableTableManager(
        _db.attachedDatabase,
        _db.sessioniAllenamentoTable,
      );
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$AllenamentiEserciziTableTableTableManager get allenamentiEserciziTable =>
      $$AllenamentiEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.allenamentiEserciziTable,
      );
  $$SessioniEserciziTableTableTableManager get sessioniEserciziTable =>
      $$SessioniEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.sessioniEserciziTable,
      );
}
