// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attivita_pianificate_dao.dart';

// ignore_for_file: type=lint
mixin _$AttivitaPianificateDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  $SessioniAllenamentoTableTable get sessioniAllenamentoTable =>
      attachedDatabase.sessioniAllenamentoTable;
  $CamminateTableTable get camminateTable => attachedDatabase.camminateTable;
  $AttivitaPianificateTableTable get attivitaPianificateTable =>
      attachedDatabase.attivitaPianificateTable;
  AttivitaPianificateDaoManager get managers =>
      AttivitaPianificateDaoManager(this);
}

class AttivitaPianificateDaoManager {
  final _$AttivitaPianificateDaoMixin _db;
  AttivitaPianificateDaoManager(this._db);
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
  $$CamminateTableTableTableManager get camminateTable =>
      $$CamminateTableTableTableManager(
        _db.attachedDatabase,
        _db.camminateTable,
      );
  $$AttivitaPianificateTableTableTableManager get attivitaPianificateTable =>
      $$AttivitaPianificateTableTableTableManager(
        _db.attachedDatabase,
        _db.attivitaPianificateTable,
      );
}
