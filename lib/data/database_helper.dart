import 'package:app_infopae/data/models/beneficiario_model.dart';
import 'package:app_infopae/data/models/calendar_model.dart';
import 'package:app_infopae/data/models/priorizacion_model.dart';
import 'package:app_infopae/data/models/sedes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
      CREATE TABLE beneficiarios (
        id INTEGER PRIMARY KEY,
        tipo_doc TEXT NOT NULL,
        num_doc TEXT NOT NULL,
        nom1 TEXT NOT NULL,
        nom2 TEXT NOT NULL,
        ape1 TEXT NULL,
        ape2 TEXT NOT NULL,
        cod_inst TEXT NOT NULL,
        cod_sede TEXT NOT NULL,
        nom_sede TEXT NOT NULL,
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

    await db.execute('''
      CREATE TABLE calendar (
        id INTEGER PRIMARY KEY,
        mes TEXT NOT NULL,
        semana TEXT NOT NULL,
        dia TEXT NULL,
        nomDia TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE asistencia_det (
        id INTEGER PRIMARY KEY,
        tipo_doc TEXT NOT NULL,
        num_doc TEXT NOT NULL,
        dia TEXT NOT NULL,
        semana TEXT NOT NULL,
        mes TEXT NOT NULL,
        complemento TEXT NOT NULL,
        id_usuario INTEGER NOT NULL DEFAULT 0,
        asistencia INTEGER DEFAULT 0,
        repite INTEGER DEFAULT 0,
        consumio INTEGER DEFAULT 0,
        repitio INTEGER DEFAULT 0,
        confirmed INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_asistencia_doc_dia ON asistencia_det (num_doc, dia);');
  }

  // Método para insertar usuarios masivamente
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
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
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  // insertar o actualizar las sedes
  Future<void> insertOrUpdateSede(SedesModel sede) async {
    final db = await instance.database;

    await db.insert(
      'sedes',
      sede.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }


  Future<void> insertOrUpdateBeneficiario(
      BeneficiarioModel beneficiario) async {
    final db = await instance.database;

    await db.insert(
      'beneficiarios',
      beneficiario.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> insertOrUpdatePriorizacion(
      PriorizacionModel priorizacion) async {
    final db = await instance.database;

    await db.insert(
      'priorizacion',
      priorizacion.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> insertOrUpdateCalendar(CalendarModel calendar) async {
    final db = await instance.database;

    await db.insert(
      'calendar',
      calendar.toMap(), // Convertimos el objeto a Map para guardarlo
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Si el ID existe, lo actualiza
    );
  }

  Future<void> insertOrUpdateAsistenciaDet(CalendarModel calendar) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final db = await instance.database;
    final List<Map<String, dynamic>> beneficiarios =
        await db.query('beneficiarios');

    final String semana = calendar.semana;
    await prefs.setString('last_week', semana); // Guardar la ultima semana que se sincronizó

    if (beneficiarios.isEmpty) return;
    final batch = db.batch();

    for (var beneficiario in beneficiarios) {
      batch.insert(
        'asistencia_det',
        {
          'tipo_doc': beneficiario['tipo_doc'],
          'num_doc': beneficiario['num_doc'],
          'dia': calendar.dia,
          'semana': calendar.semana,
          'mes': calendar.mes,
          'complemento': beneficiario['tipo_complemento'],
          'id_usuario': userId,
          'asistencia': 0,
          'repite': 0,
          'consumio': 0,
          'repitio': 0,
          'confirmed': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }


  Future<void> cleanData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_week');
    final db = await instance.database;
    await db.delete('sedes');
    await db.delete('beneficiarios');
    await db.delete('priorizacion');
    await db.delete('calendar');
    await db.delete('asistencia_det');
  }
}
