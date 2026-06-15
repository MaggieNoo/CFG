import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'camalig_gym.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_session(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        user_data_json TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP
      )
    ''');
  }

  // Save session
  Future<void> saveSession(UserModel user) async {
    final db = await database;
    
    // Clear existing sessions first to maintain only one active user
    await db.delete('user_session');

    // Set expiration to 30 days from now (or any preferred duration)
    final expiresAt = DateTime.now().add(const Duration(days: 30));

    await db.insert(
      'user_session',
      {
        'user_id': user.id,
        'token': user.token,
        'user_data_json': json.encode(user.toJson()),
        'expires_at': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get current active session
  Future<UserModel?> getSession() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_session',
      limit: 1,
      orderBy: 'id DESC',
    );

    if (maps.isNotEmpty) {
      final session = maps.first;
      final expiresAtStr = session['expires_at'] as String?;
      
      // Check if session is expired
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          // Session expired, clear it
          await clearSession();
          return null;
        }
      }

      final userDataStr = session['user_data_json'] as String;
      return UserModel.fromJson(json.decode(userDataStr));
    }
    return null;
  }

  // Clear session
  Future<void> clearSession() async {
    final db = await database;
    await db.delete('user_session');
  }
}
