import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'user.dart';

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
        """CREATE TABLE IF NOT EXISTS users(
        
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        username TEXT,
        password TEXT,
        nickname TEXT,
        autoLogin INTEGER
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'travel_safe.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new user
  static Future<int> createUser(User user) async {
    final db = await DatabaseHelper.db();

    final data = {'username': user.username, 'password': user.password, 'nickname': user.nickname, 'autoLogin': user.autoLogin};
    final id = await db.insert('users', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await DatabaseHelper.db();
    //await db.execute("""
      //DELETE FROM users
    //""");
    return db.query('users', orderBy: "id");
  }

  // Read a user by id
  static Future<List<Map<String, dynamic>>> getUserById(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('users', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getUserByUsername(String username) async {
    final db = await DatabaseHelper.db();
    return db.query('users', where: "username = ?", whereArgs: [username], limit: 1);
  }

  // Update user details
  static Future<int> updateUser(String username, String password, String nickname, bool autoLogin) async {
    final db = await DatabaseHelper.db();

    final data = {
      'username': username,
      'password': password,
      'nickname': nickname,
      'autoLogin': autoLogin ? 1 : 0,
    };

    final result =
    await db.update('users', data, where: "username = ?", whereArgs: [username]);
    return result;
  }

  static Future<void> deleteUser(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("users", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting: $err");
    }
  }
}