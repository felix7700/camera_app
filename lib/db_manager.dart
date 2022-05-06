import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbManager {
  static const databaseName = "database.db";
  static const databaseVersion = 1;

  final String imagesTablename = 'images';
  final String imagesColumnnameImageID = 'image_id';
  final String imagesColumnnameImageFileName = 'image_filename';
  final String imagesColumnnameImageNickName = 'image_nickname';
  final String imagesColumnnameImageTagID = 'image_tag_id';

  final String tagsTablename = 'tags';
  final String tagsColumnnameTagID = 'tag_id';
  final String tagsColumnnameTagName = 'tag_name';

  bool _createExampleTableData = false;

  DbManager._privateConstructor();
  static final DbManager instance = DbManager._privateConstructor();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    // lazily instantiate the db the first time it is accessed
    _db = await _initDatabase();

    if (_createExampleTableData) {
      // await _insertExampleDataIntoAllTables();
    }

    return _db!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, databaseName);
    return await openDatabase(dbPath,
        version: databaseVersion, onCreate: onCreate);
  }

  // SQL code to create the database tables
  Future onCreate(Database db, int version) async {
    _createExampleTableData = true;

    await db.execute('''
          CREATE TABLE $imagesTablename (
            $imagesColumnnameImageID INTEGER NOT NULL UNIQUE,
            $imagesColumnnameImageFileName TEXT NOT NULL,
            $imagesColumnnameImageNickName TEXT,
            $imagesColumnnameImageTagID INTEGER,
            PRIMARY KEY("$imagesColumnnameImageID" AUTOINCREMENT)
          )
          ''');

    await db.execute('''
          CREATE TABLE $tagsTablename (
            $tagsColumnnameTagID INTEGER NOT NULL UNIQUE,
            $tagsColumnnameTagName TEXT NOT NULL,
            PRIMARY KEY("$tagsColumnnameTagID" AUTOINCREMENT)
          )
          ''');
  }

  Future<int> insertIntoTable(
      {required String tableName, required Map<String, dynamic> row}) async {
    Database db = await instance.database;
    int? _resultId;
    try {
      _resultId = await db.insert(tableName, row);
    } catch (error) {
      // if error contains 'UNIQUE constraint failed', it´s no error, because id its auto increment, when value is null
      if (error.toString().contains('UNIQUE constraint failed')) {
        return 0;
      }
      return -1;
    }
    return _resultId;
  }

  void dropTable({required tableName}) async {
    Database db = await instance.database;
    db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<List<Map<String, dynamic>>> queryAllRowsFromAtable(
      {required String tableName}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result;

    try {
      result = await db.query(tableName);
    } catch (e) {
      result = e as List<Map<String, dynamic>>;
    }
    return result;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount({required String tableName}) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
  }

  Future<List<Map<String, Object?>>> queryItem(
      {required String tableName,
      required String columnName,
      required int value}) async {
    Database db = await instance.database;
    return await db
        .rawQuery('SELECT * FROM $tableName where $columnName = $value');
  }

  Future<int> updateRow(
      {required String tableName,
      required String whereColumnIdName,
      required Map<String, dynamic> rowData}) async {
    Database db = await instance.database;
    int id = rowData[whereColumnIdName];

    return await db.update(tableName, rowData,
        where: '$whereColumnIdName = ?', whereArgs: [id]);
  }

  Future<int> deleteRow(
      {required String tableName,
      required String idColumnname,
      required int id}) async {
    Database db = await instance.database;
    return await db
        .delete(tableName, where: '$idColumnname = ?', whereArgs: [id]);
  }

  Future<int?> isTableExists({required String tableName}) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
  }

  Future<int> deleteAllRows(
      {required String tableName, required String idColumnname}) async {
    Database db = await instance.database;
    int? tableExists = 0;

    tableExists = await isTableExists(tableName: tableName);
    if (tableExists! > 0) {
      return await db
          .rawDelete('DELETE FROM $tableName WHERE $idColumnname > 0');
    } else {
      return -1;
    }
  }

  Future<List<Map<String, Object?>>> rawQuery(
      {required String queryString}) async {
    Database db = await instance.database;
    List<Map<String, Object?>> _queryResult;
    try {
      _queryResult = await db.rawQuery(queryString);
    } catch (error) {
      _queryResult = [
        {'error': error}
      ];
    }
    return _queryResult;
  }

  Future<int> updateAValueInARow({
    required String tableName,
    required String whereColumnName,
    required var whereColumnValue,
    required String updateValueColumnName,
    required var updateValue,
  }) async {
    Database db = await instance.database;
    int _error = await db.rawUpdate(
        'UPDATE $tableName SET $updateValueColumnName = $updateValue WHERE $whereColumnName = $whereColumnValue');
    return _error;
  }

  Future<List<Map<String, Object?>>> queryRelatedRowsFromAtable({
    required String tableName,
    required String whereColumnName,
    required var whereColumnValue,
  }) async {
    Database db = await instance.database;
    List<Map<String, Object?>> _result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $whereColumnName = $whereColumnValue');
    return _result;
  }
}
