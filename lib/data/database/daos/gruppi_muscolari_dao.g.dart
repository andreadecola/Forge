// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gruppi_muscolari_dao.dart';

// ignore_for_file: type=lint
mixin _$GruppiMuscolariDaoMixin on DatabaseAccessor<AppDatabase> {
  $GruppiMuscolariTableTable get gruppiMuscolariTable =>
      attachedDatabase.gruppiMuscolariTable;
  $CategorieEserciziTableTable get categorieEserciziTable =>
      attachedDatabase.categorieEserciziTable;
  $EserciziTableTable get eserciziTable => attachedDatabase.eserciziTable;
  $EserciziGruppiMuscolariTableTable get eserciziGruppiMuscolariTable =>
      attachedDatabase.eserciziGruppiMuscolariTable;
  GruppiMuscolariDaoManager get managers => GruppiMuscolariDaoManager(this);
}

class GruppiMuscolariDaoManager {
  final _$GruppiMuscolariDaoMixin _db;
  GruppiMuscolariDaoManager(this._db);
  $$GruppiMuscolariTableTableTableManager get gruppiMuscolariTable =>
      $$GruppiMuscolariTableTableTableManager(
        _db.attachedDatabase,
        _db.gruppiMuscolariTable,
      );
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db.attachedDatabase,
        _db.categorieEserciziTable,
      );
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db.attachedDatabase, _db.eserciziTable);
  $$EserciziGruppiMuscolariTableTableTableManager
  get eserciziGruppiMuscolariTable =>
      $$EserciziGruppiMuscolariTableTableTableManager(
        _db.attachedDatabase,
        _db.eserciziGruppiMuscolariTable,
      );
}
