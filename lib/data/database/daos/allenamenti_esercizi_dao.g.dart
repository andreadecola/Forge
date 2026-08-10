// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allenamenti_esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$AllenamentiEserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $AllenamentiEserciziTableTable get allenamentiEserciziTable =>
      attachedDatabase.allenamentiEserciziTable;
  AllenamentiEserciziDaoManager get managers =>
      AllenamentiEserciziDaoManager(this);
}

class AllenamentiEserciziDaoManager {
  final _$AllenamentiEserciziDaoMixin _db;
  AllenamentiEserciziDaoManager(this._db);
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
}
