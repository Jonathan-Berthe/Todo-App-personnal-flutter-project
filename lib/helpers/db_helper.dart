import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as systpaths;

class DBHelper {
 

  static Future<String> saveImagesToFile(
      ByteData image, String pathName) async {
    final buffer = image.buffer;
    Directory tempDir = await systpaths.getExternalStorageDirectory();
    //Directory tempDir = await systpaths.getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    String filePath = tempPath + pathName;
    File file = File(filePath);
    await file.writeAsBytes(
        buffer.asUint8List(image.offsetInBytes, image.lengthInBytes));
    return filePath;
  }

  static Future<ByteData> loadImageFromFile(String path) async {
    final file = File(path);
    Uint8List contentUint8 = await file.readAsBytes();
    ByteData content = contentUint8.buffer.asByteData();
    return content;
  }

   static Future<void> deleteImageFile(String path) async {
    await File(path).delete();
  }

  static Future<sql.Database> databaseTodos() async {
    Directory tempDir = await systpaths.getExternalStorageDirectory();
    final dbPath = tempDir.path;//await sql.getDatabasesPath(); //////////// TODO: remettre dans le DatabasesPath en prod
    return sql.openDatabase(
      path.join(dbPath, 'user_todos.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE user_todos(id TEXT PRIMARY KEY, todoJson TEXT)');
      },
      version: 1,
    );
  }

  static Future<void> insertTodos(Map<String, String> data) async {
    final db = await DBHelper.databaseTodos();
    db.insert('user_todos', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> updateTodos(Map<String, String> data) async {
    final db = await DBHelper.databaseTodos();
    db.update('user_todos', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  static Future<void> deleteTodos(String id) async {
    final db = await DBHelper.databaseTodos();
    db.delete('user_todos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getDataTodos() async {
    final db = await DBHelper.databaseTodos();
    return db.query('user_todos') ;
  }

  static Future<sql.Database> databaseCategory() async {
    Directory tempDir = await systpaths.getExternalStorageDirectory();
    final dbPath = tempDir.path;//await sql.getDatabasesPath(); //////////// TODO: remettre dans le DatabasesPath en prod
    return sql.openDatabase(
      path.join(dbPath, 'user_category.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE user_category(id TEXT PRIMARY KEY, categoryJson TEXT)');
      },
      version: 1,
    );
  }

  static Future<void> insertCategory(Map<String, String> data) async {
    final db = await DBHelper.databaseCategory();
    db.insert('user_category', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getDataCategory() async {
    final db = await DBHelper.databaseCategory();
    return db.query('user_category');
  }

}
