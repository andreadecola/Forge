// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessioni_allenamento_dao.dart';

// ignore_for_file: type=lint
mixin _$SessioniAllenamentoDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  $SessioniAllenamentoTableTable get sessioniAllenamentoTable =>
      attachedDatabase.sessioniAllenamentoTable;
  SessioniAllenamentoDaoManager get managers =>
      SessioniAllenamentoDaoManager(this);
}

class SessioniAllenamentoDaoManager {
  final _$SessioniAllenamentoDaoMixin _db;
  SessioniAllenamentoDaoManager(this._db);
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
}
