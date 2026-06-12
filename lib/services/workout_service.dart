import '../models/workout_model.dart';
import 'database_service.dart';

class WorkoutService {
  Future<List<WorkoutModel>> getWorkouts(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'workouts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    final db = await DatabaseService.instance.database;
    await db.insert('workouts', workout.toMap());
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    if (workout.id == null) {
      return;
    }
    final db = await DatabaseService.instance.database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [workout.id, workout.userId],
    );
  }

  Future<void> deleteWorkout(int id, int userId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'workouts',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}
