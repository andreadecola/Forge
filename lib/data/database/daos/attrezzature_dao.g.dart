// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attrezzature_dao.dart';

// ignore_for_file: type=lint
mixin _$AttrezzatureDaoMixin on DatabaseAccessor<AppDatabase> {
  $AttrezzatureTableTable get attrezzatureTable =>
      attachedDatabase.attrezzatureTable;
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $AttrezzatureEserciziTableTable get attrezzatureEserciziTable =>
      attachedDatabase.attrezzatureEserciziTable;
  AttrezzatureDaoManager get managers => AttrezzatureDaoManager(this);
}

class AttrezzatureDaoManager {
  final _$AttrezzatureDaoMixin _db;
  AttrezzatureDaoManager(this._db);
  $$AttrezzatureTableTableTableManager get attrezzatureTable =>
      $$AttrezzatureTableTableTableManager(
        _db.attachedDatabase,
        _db.attrezzatureTable,
      );
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$AttrezzatureEserciziTableTableTableManager get attrezzatureEserciziTable =>
      $$AttrezzatureEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.attrezzatureEserciziTable,
      );
}
