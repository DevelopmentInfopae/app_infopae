import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL default ""
      )
    ''');
  }

  // Método para insertar usuarios masivamente
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Consultar si hay usuarios
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<UserModel?> getUser(String username, String password) async {
    final db = await instance.database;

    // Buscamos un usuario que coincida con ambos campos
    final List<Map<String, dynamic>> maps = await db.query(
      'users', // Asegúrate de que el nombre de la tabla sea 'users' o 'usuarios'
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      // Usamos .fromMap porque mencionaste que así se llama en tu modelo
      return UserModel.fromMap(maps.first);
    }

    return null; // Si no lo encuentra, devuelve null
  }


  Future<void> insertOrUpdateUser(UserModel user) async {
    final db = await instance.database;

    await db.insert(
      'users',
      user.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm: ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }
}