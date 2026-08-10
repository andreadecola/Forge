// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$EserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  EserciziDaoManager get managers => EserciziDaoManager(this);
}

class EserciziDaoManager {
  final _$EserciziDaoMixin _db;
  EserciziDaoManager(this._db);
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
}
