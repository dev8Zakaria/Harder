import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'seed_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = join(await getDatabasesPath(), 'fitness_tracker.db');
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS user_profiles');
        await db.execute('DROP TABLE IF EXISTS workouts');
        await db.execute('DROP TABLE IF EXISTS custom_exercises');
        await db.execute('DROP TABLE IF EXISTS set_logs');
        await db.execute('DROP TABLE IF EXISTS body_weights');
        await db.execute('DROP TABLE IF EXISTS calorie_entries');
        await db.execute('DROP TABLE IF EXISTS workout_sessions');
        await _onCreate(db, newVersion);
      },
    );
    await SeedService.seedIfNeeded(_database!);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        fullName TEXT NOT NULL,
        age INTEGER NOT NULL,
        goal TEXT NOT NULL,
        level TEXT NOT NULL,
        sessionsPerWeek INTEGER NOT NULL,
        height REAL NOT NULL,
        initialWeight REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        dayName TEXT NOT NULL,
        exercises TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        bodyPart TEXT NOT NULL,
        targetMuscle TEXT NOT NULL,
        equipment TEXT NOT NULL,
        imageUrl TEXT,
        imagePath TEXT,
        source TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE set_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE body_weights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE calorie_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        consumedCalories INTEGER NOT NULL,
        burnedCalories INTEGER NOT NULL,
        dailyGoal INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        workoutName TEXT NOT NULL,
        date TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        totalSets INTEGER NOT NULL,
        totalVolume REAL NOT NULL
      )
    ''');
  }
}
