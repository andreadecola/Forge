// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternative_esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$AlternativeEserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $AlternativeEserciziTableTable get alternativeEserciziTable =>
      attachedDatabase.alternativeEserciziTable;
  AlternativeEserciziDaoManager get managers =>
      AlternativeEserciziDaoManager(this);
}

class AlternativeEserciziDaoManager {
  final _$AlternativeEserciziDaoMixin _db;
  AlternativeEserciziDaoManager(this._db);
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$AlternativeEserciziTableTableTableManager get alternativeEserciziTable =>
      $$AlternativeEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.alternativeEserciziTable,
      );
}
