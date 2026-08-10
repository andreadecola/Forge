// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progressioni_esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgressioniEserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $ProgressioniEserciziTableTable get progressioniEserciziTable =>
      attachedDatabase.progressioniEserciziTable;
  ProgressioniEserciziDaoManager get managers =>
      ProgressioniEserciziDaoManager(this);
}

class ProgressioniEserciziDaoManager {
  final _$ProgressioniEserciziDaoMixin _db;
  ProgressioniEserciziDaoManager(this._db);
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$ProgressioniEserciziTableTableTableManager get progressioniEserciziTable =>
      $$ProgressioniEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.progressioniEserciziTable,
      );
}
