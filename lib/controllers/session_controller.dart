import '../models/set_log_model.dart';
import '../models/workout_session_model.dart';
import '../services/session_service.dart';

class SessionController {
  final SessionService _service = SessionService();
  final int userId;

  SessionController(this.userId);

  Future<List<SetLogModel>> logs() {
    return _service.getLogs(userId);
  }

  Future<void> addLog({
    required String exerciseName,
    required int setNumber,
    required int reps,
    required double weight,
  }) {
    return _service.addLog(
      SetLogModel(
        userId: userId,
        exerciseName: exerciseName,
        setNumber: setNumber,
        reps: reps,
        weight: weight,
      ),
    );
  }

  Future<List<WorkoutSessionModel>> sessions() {
    return _service.getSessions(userId);
  }

  Future<void> addSession({
    required String workoutName,
    required String date,
    required int durationSeconds,
    required int totalSets,
    required double totalVolume,
  }) {
    return _service.addSession(
      WorkoutSessionModel(
        userId: userId,
        workoutName: workoutName,
        date: date,
        durationSeconds: durationSeconds,
        totalSets: totalSets,
        totalVolume: totalVolume,
      ),
    );
  }
}
