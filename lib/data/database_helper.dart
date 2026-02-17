import 'package:app_infopae/data/models/beneficiario_model.dart';
import 'package:app_infopae/data/models/priorizacion_model.dart';
import 'package:app_infopae/data/models/sedes_model.dart';
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
        nombre TEXT NOT NULL,
        clave TEXT NOT NULL,
        foto TEXT NULL,
        email TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sedes (
        id INTEGER PRIMARY KEY,
        cod_inst TEXT NOT NULL,
        nom_inst TEXT NOT NULL,
        cod_sede TEXT NULL,
        nom_sede TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE benefiarios (
        id INTEGER PRIMARY KEY,
        nom1 TEXT NOT NULL,
        nom2 TEXT NOT NULL,
        ape1 TEXT NULL,
        ape2 TEXT NOT NULL,
        cod_sede TEXT NOT NULL,
        cod_grado TEXT NOT NULL,
        nom_grupo TEXT NOT NULL,
        tipo_complemento TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE priorizacion (
        id INTEGER PRIMARY KEY,
        cod_sede TEXT NOT NULL,
        aps TEXT NOT NULL,
        cajmps TEXT NULL,
        cajtps TEXT NOT NULL,
        cajmri TEXT NOT NULL,
        cajtri TEXT NOT NULL
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
    final List<Map<String, dynamic>> maps = await db.query(
      'users', // Asegúrate de que el nombre de la tabla sea 'users' o 'usuarios'
      where: 'email = ? AND clave = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null; 
  }

  Future<void> insertOrUpdateUser(UserModel user) async {
    final db = await instance.database;

    await db.insert(
      'users',
      user.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm: ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  // insertar o actualizar las sedes 
  Future<void> insertOrUpdateSede(SedesModel sede) async {
    final db = await instance.database;

    await db.insert(
      'sedes',
      sede.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm: ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> allSedes() async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT * FROM sedes');
  }

  Future<void> insertOrUpdateBeneficiario(BeneficiarioModel beneficiario) async {
    final db = await instance.database;

    await db.insert(
      'benefiarios',
      beneficiario.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm: ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> allBeneficiarios() async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT * FROM benefiarios');
  }

  Future<void> insertOrUpdatePriorizacion(PriorizacionModel priorizacion) async {
    final db = await instance.database;

    await db.insert(
      'priorizacion',
      priorizacion.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm: ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> allPriorizacion() async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT * FROM priorizacion');

  }


}