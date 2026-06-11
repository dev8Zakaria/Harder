import '../models/set_log_model.dart';
import '../models/workout_session_model.dart';
import 'database_service.dart';

class SessionService {
  Future<List<SetLogModel>> getLogs(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'set_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(SetLogModel.fromMap).toList();
  }

  Future<void> addLog(SetLogModel log) async {
    final db = await DatabaseService.instance.database;
    await db.insert('set_logs', log.toMap());
  }

  Future<List<WorkoutSessionModel>> getSessions(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'workout_sessions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(WorkoutSessionModel.fromMap).toList();
  }

  Future<void> addSession(WorkoutSessionModel session) async {
    final db = await DatabaseService.instance.database;
    await db.insert('workout_sessions', session.toMap());
  }
}
