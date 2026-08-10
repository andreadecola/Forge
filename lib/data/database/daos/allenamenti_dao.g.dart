// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allenamenti_dao.dart';

// ignore_for_file: type=lint
mixin _$AllenamentiDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  AllenamentiDaoManager get managers => AllenamentiDaoManager(this);
}

class AllenamentiDaoManager {
  final _$AllenamentiDaoMixin _db;
  AllenamentiDaoManager(this._db);
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
}
