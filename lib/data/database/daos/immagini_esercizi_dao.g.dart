// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'immagini_esercizi_dao.dart';

// ignore_for_file: type=lint
mixin _$ImmaginiEserciziDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $ImmaginiEserciziTableTable get immaginiEserciziTable =>
      attachedDatabase.immaginiEserciziTable;
  ImmaginiEserciziDaoManager get managers => ImmaginiEserciziDaoManager(this);
}

class ImmaginiEserciziDaoManager {
  final _$ImmaginiEserciziDaoMixin _db;
  ImmaginiEserciziDaoManager(this._db);
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$ImmaginiEserciziTableTableTableManager get immaginiEserciziTable =>
      $$ImmaginiEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.immaginiEserciziTable,
      );
}
