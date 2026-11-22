// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attivita_pianificate_dao.dart';

// ignore_for_file: type=lint
mixin _$AttivitaPianificateDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  $AllenamentiTableTable get allenamentiTable =>
      attachedDatabase.allenamentiTable;
  $CamminateTableTable get camminateTable => attachedDatabase.camminateTable;
  $SessioniAllenamentoTableTable get sessioniAllenamentoTable =>
      attachedDatabase.sessioniAllenamentoTable;
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
  $$CamminateTableTableTableManager get camminateTable =>
      $$CamminateTableTableTableManager(
        _db.attachedDatabase,
        _db.camminateTable,
      );
  $$SessioniAllenamentoTableTableTableManager get sessioniAllenamentoTable =>
      $$SessioniAllenamentoTableTableTableManager(
        _db.attachedDatabase,
        _db.sessioniAllenamentoTable,
      );
  $$AttivitaPianificateTableTableTableManager get attivitaPianificateTable =>
      $$AttivitaPianificateTableTableTableManager(
        _db.attachedDatabase,
        _db.attivitaPianificateTable,
      );
}
