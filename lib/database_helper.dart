import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'game_database.db');
    print("Database path: $path");

    try {
      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
      );
      print("Database initialized successfully.");
      return db;
    } catch (e) {
      print("Error initializing database: $e");
      throw Exception("Database initialization failed.");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print("Creating games table...");
      await db.execute('''
        CREATE TABLE games (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          code TEXT
        )
      ''');

      print("Creating questions table...");
      await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER,
          text TEXT,
          options TEXT,
          correct_answer TEXT,
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
        )
      ''');
      print("Tables created successfully.");
    } catch (e) {
      print("Error creating tables: $e");
      throw Exception("Table creation failed.");
    }
  }

  Future<int> insertGame(String title, String code, List<Map<String, dynamic>> questions) async {
    try {
      final db = await database;
      int gameId = await db.insert('games', {'title': title, 'code': code});
      print("Game inserted with ID: $gameId");

      for (var question in questions) {
        await db.insert('questions', {
          'game_id': gameId,
          'text': question['text'],
          'options': question['options'],
          'correct_answer': question['correctAnswer'],
        });
      }
      print("Questions inserted successfully.");
      return gameId;
    } catch (e) {
      print("Error inserting game or questions: $e");
      throw Exception("Failed to insert game.");
    }
  }

  Future<List<Map<String, dynamic>>> fetchGames() async {
    try {
      final db = await database;
      final games = await db.query('games');
      print("Fetched games: $games");
      return games;
    } catch (e) {
      print("Error fetching games: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(int gameId) async {
    final db = await database;
    final questions = await db.query(
      'questions',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return questions;
  }

  Future<void> deleteGame(int gameId) async {
    final db = await database;
    try {
      await db.delete(
        'games',
        where: 'id = ?',
        whereArgs: [gameId],
      );
      print('Deleted game with ID: $gameId');
    } catch (e) {
      print('Error deleting game: $e');
    }
  }

  Future<void> updateGame(int gameId, String title, String code) async {
    final db = await database;
    await db.update(
      'games',
      {'title': title, 'code': code},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }
  Future<void> deleteQuestion(int questionId) async {
    final db = await database;
    await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<void> insertQuestion(int gameId, String text, String options, String correctAnswer) async {
    final db = await database;
    await db.insert('questions', {
      'game_id': gameId,
      'text': text,
      'options': options,
      'correct_answer': correctAnswer,
    });
  }

  Future<void> updateQuestion(int questionId, String text, String options, String correctAnswer) async {
    final db = await database;
    await db.update(
      'questions',
      {
        'text': text,
        'options': options,
        'correct_answer': correctAnswer,
      },
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

}

