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
  final String imagesColumnnameImageTagID = 'image_tags';

  final String tagsTablename = 'tags';
  final String tagsColumnnameTagID = 'tag_id';
  final String tagsColumnnameTagName = 'tag_name';

  bool _createExampleTableData = false;

  DbManager._privateConstructor();
  static final DbManager instance = DbManager._privateConstructor();
  static Database? _db;

  Future<Database> get database async {
    debugPrint('Future<Database> get database async{}');
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
    debugPrint('_initDatabase');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, databaseName);
    debugPrint(
        "dbPath to see DB in DBBrowser when using iPhone-Simulator = $dbPath");

    return await openDatabase(dbPath,
        version: databaseVersion, onCreate: onCreate);
  }

  // SQL code to create the database tables
  Future onCreate(Database db, int version) async {
    debugPrint('_onCreate');
    _createExampleTableData = true;

    await db.execute('''
          CREATE TABLE $imagesTablename (
            $imagesColumnnameImageID INTEGER NOT NULL UNIQUE,
            $imagesColumnnameImageFileName TEXT NOT NULL,
            $imagesColumnnameImageNickName TEXT,
            $imagesColumnnameImageTagID TEXT,
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
      debugPrint('insertIntoTable errorCode : ' + error.toString());
      if (error.toString().contains('UNIQUE constraint failed')) {
        return 0;
      }
      return -1;
    }
    return _resultId;
  }

  void dropTable({required tableName}) async {
    debugPrint('\ndropTable');
    Database db = await instance.database;
    db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<List<Map<String, dynamic>>> queryAllRows(
      {required String tableName}) async {
    debugPrint('queryAllRows');
    Database db = await instance.database;
    List<Map<String, dynamic>> result;

    try {
      result = await db.query(tableName);
    } catch (e) {
      debugPrint('error! : ' + e.toString());
      result = e as List<Map<String, dynamic>>;
    }
    return result;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount({required String tableName}) async {
    debugPrint('queryRowCount');
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
  }

  Future<List<Map<String, Object?>>> queryItem(
      {required String tableName,
      required String Columnname,
      required int value}) async {
    debugPrint('queryItem');
    Database db = await instance.database;
    return await db
        .rawQuery('SELECT * FROM $tableName where $Columnname = $value');
  }

  Future<int> updateRow(
      {required String tableName,
      required String whereColumnIdName,
      required Map<String, dynamic> rowData}) async {
    debugPrint('updateRow()');

    Database db = await instance.database;
    int id = rowData[whereColumnIdName];

    return await db.update(tableName, rowData,
        where: '$whereColumnIdName = ?', whereArgs: [id]);
  }

  Future<int> deleteRow(
      {required String tableName,
      required String idColumnname,
      required int id}) async {
    debugPrint('deleteRow()');
    Database db = await instance.database;
    return await db
        .delete(tableName, where: '$idColumnname = ?', whereArgs: [id]);
  }

  Future<int?> isTableExists({required String tableName}) async {
    debugPrint('isTableExists()');
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
  }

  Future<int> deleteAllRows(
      {required String tableName, required String idColumnname}) async {
    debugPrint('\ndeleteAllRows()');
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
    debugPrint('rawQuery()');
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
}
