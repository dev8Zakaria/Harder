import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutController {
  final WorkoutService _service = WorkoutService();
  final int userId;

  WorkoutController(this.userId);

  Future<List<WorkoutModel>> all() {
    return _service.getWorkouts(userId);
  }

  Future<void> add(
    String name,
    String description,
    String dayName,
    List<String> exercises,
  ) {
    return _service.addWorkout(
      WorkoutModel(
        userId: userId,
        name: name,
        description: description,
        dayName: dayName,
        exercises: exercises,
      ),
    );
  }

  Future<void> update(WorkoutModel workout) {
    return _service.updateWorkout(workout);
  }

  Future<void> delete(int id) {
    return _service.deleteWorkout(id, userId);
  }
}
