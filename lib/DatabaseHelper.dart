import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mobile_assign_3/foodItem.dart';
import 'package:mobile_assign_3/calcEntry.dart';
class DatabaseHelper {

  static const _databaseName = "flutDB.db";
  static const _databaseVersion = 1;
  static const table1 = 'item_tbl';
  static const table2 = 'calc_tbl';

  static const id=1;
  static const stCol1="name";
  static const stCol2="calories";

  static const stCol3="date";
  static const stCol4="total";
  static const stCol5="items";
  // make this a singleton class

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();


  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async =>
      _database ??= await _initDatabase();

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {

    await db.execute('''
          CREATE TABLE $table1 (
            id INTEGER NOT NULL PRIMARY KEY, $stCol1 TEXT,$stCol2 INT
           )
          ''');

    await db.execute('''
          CREATE TABLE $table2 (
            id INTEGER NOT NULL PRIMARY KEY, $stCol3 TEXT,$stCol4 INT, $stCol5 JSON
           )
          ''');


  }


  
  Future deleteTable() async {
    final Database db = await database;
    
    await db.execute("DROP TABLE IF EXISTS $table1");
    await db.execute("DROP TABLE IF EXISTS $table2");

  }
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.

  Future insert(foodItem row) async {
    // Get a reference to the database.
    final Database db = await database;

    try {
      await db.insert(
        table1,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Db Inserted');
    }
    catch(e){
      print('DbException$e');
    }
  }

  Future insertCalc(calcEntry row) async {
    // Get a reference to the database.
    final Database db = await database;

    try {
      await db.insert(
        table2,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Db Inserted into 2');
    }
    catch(e){
      print('DbException$e');
    }
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table1);
  }

  Future<List<Map<String, dynamic>>> getCalcs() async {
    Database db = await instance.database;
    return await db.query(table2);
  }

  Future<List<Map<String, dynamic>>> queryFilterRows() async {
    Database db = await instance.database;
    return await db.rawQuery("select * from $table1 where stCol2='111'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table1'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(foodItem uinput) async {
     Database db = await instance.database;
     int id = uinput.id!;

     return await db.update(table1, uinput.toMap(), where: 'id = ?', whereArgs: [id]);
   }

  Future<int> updateCalc(calcEntry uinput) async {
    Database db = await instance.database;
    int id = uinput.id!;

    return await db.update(table2, uinput.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table1, where: 'id = ?', whereArgs: [id]);
  }
  Future<int> deleteCalc(int id) async {
    Database db = await instance.database;
    return await db.delete(table2, where: 'id = ?', whereArgs: [id]);
  }
}