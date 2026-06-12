import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class SeedService {
  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<void> seedIfNeeded(Database db) async {
    final demoUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['demo@harder.com'],
      limit: 1,
    );

    final int userId;
    if (demoUsers.isEmpty) {
      userId = await db.insert('users', {
        'email': 'demo@harder.com',
        'password': '1234',
      });

      await db.insert('user_profiles', {
        'userId': userId,
        'fullName': 'Alex Fit',
        'age': 25,
        'goal': 'Prise de masse',
        'level': 'Intermediaire',
        'sessionsPerWeek': 4,
        'height': 180.0,
        'initialWeight': 82.5,
      });
    } else {
      userId = demoUsers.first['id'] as int;
    }

    final now = DateTime.now();
    await _seedWeights(db, userId, now);
    await _seedCalories(db, userId, now);
    await _seedWorkouts(db, userId);
    await _seedSessions(db, userId, now);
    await _seedSetLogs(db, userId);
  }

  static Future<void> _seedWeights(
    Database db,
    int userId,
    DateTime now,
  ) async {
    final existing = await db.query(
      'body_weights',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final weightsData = [
      MapEntry(30, 82.5),
      MapEntry(27, 82.2),
      MapEntry(24, 81.8),
      MapEntry(20, 81.5),
      MapEntry(17, 81.0),
      MapEntry(13, 80.8),
      MapEntry(10, 80.5),
      MapEntry(7, 80.2),
      MapEntry(3, 79.9),
      MapEntry(0, 79.5),
    ];

    for (final entry in weightsData) {
      await db.insert('body_weights', {
        'userId': userId,
        'date': _formatDate(now.subtract(Duration(days: entry.key))),
        'weight': entry.value,
      });
    }
  }

  static Future<void> _seedCalories(
    Database db,
    int userId,
    DateTime now,
  ) async {
    final existing = await db.query(
      'calorie_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final calorieData = [
      MapEntry(6, [2700, 400, 2800]),
      MapEntry(5, [2850, 350, 2800]),
      MapEntry(4, [2600, 450, 2800]),
      MapEntry(3, [2900, 300, 2800]),
      MapEntry(2, [2750, 500, 2800]),
      MapEntry(1, [2800, 400, 2800]),
      MapEntry(0, [2400, 350, 2800]),
    ];

    for (final entry in calorieData) {
      await db.insert('calorie_entries', {
        'userId': userId,
        'date': _formatDate(now.subtract(Duration(days: entry.key))),
        'consumedCalories': entry.value[0],
        'burnedCalories': entry.value[1],
        'dailyGoal': entry.value[2],
      });
    }
  }

  static Future<void> _seedWorkouts(Database db, int userId) async {
    final existing = await db.query(
      'workouts',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    await db.insert('workouts', {
      'userId': userId,
      'name': 'Push',
      'description': 'Pectoraux, epaules et triceps.',
      'dayName': 'Lundi',
      'exercises': jsonEncode(['bench press', 'dips', 'lateral raise']),
    });

    await db.insert('workouts', {
      'userId': userId,
      'name': 'Pull',
      'description': 'Dos, biceps et trapezes.',
      'dayName': 'Mercredi',
      'exercises': jsonEncode(['pull-up', 'deadlift', 'biceps curl']),
    });

    await db.insert('workouts', {
      'userId': userId,
      'name': 'Legs',
      'description': 'Quadriceps, ischios et mollets.',
      'dayName': 'Vendredi',
      'exercises': jsonEncode(['squat', 'lunge', 'leg press']),
    });
  }

  static Future<void> _seedSessions(
    Database db,
    int userId,
    DateTime now,
  ) async {
    final existing = await db.query(
      'workout_sessions',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final sessionsData = [
      MapEntry(11, ['Push', 2700, 9, 2150.0]),
      MapEntry(9, ['Pull', 3000, 8, 1750.0]),
      MapEntry(7, ['Legs', 3600, 12, 2900.0]),
      MapEntry(4, ['Push', 2900, 9, 2280.0]),
      MapEntry(2, ['Pull', 3100, 8, 1850.0]),
    ];

    for (final entry in sessionsData) {
      await db.insert('workout_sessions', {
        'userId': userId,
        'workoutName': entry.value[0],
        'date': _formatDate(now.subtract(Duration(days: entry.key))),
        'durationSeconds': entry.value[1],
        'totalSets': entry.value[2],
        'totalVolume': entry.value[3],
      });
    }
  }

  static Future<void> _seedSetLogs(Database db, int userId) async {
    final existing = await db.query(
      'set_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final logs = [
      ['bench press', 1, 10, 60.0],
      ['bench press', 2, 8, 65.0],
      ['bench press', 3, 6, 70.0],
      ['bench press', 1, 10, 62.5],
      ['bench press', 2, 8, 67.5],
      ['bench press', 3, 6, 72.5],
      ['biceps curl', 1, 12, 12.0],
      ['biceps curl', 2, 10, 14.0],
    ];

    for (final log in logs) {
      await db.insert('set_logs', {
        'userId': userId,
        'exerciseName': log[0],
        'setNumber': log[1],
        'reps': log[2],
        'weight': log[3],
      });
    }
  }
}
