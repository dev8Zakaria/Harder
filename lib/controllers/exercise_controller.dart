import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class ExerciseController {
  final ExerciseService _service = ExerciseService();
  final int userId;

  ExerciseController(this.userId);

  Future<List<ExerciseModel>> officialExercises() {
    return _service.getApiExercises();
  }

  Future<List<ExerciseModel>> searchOfficialExercises(String query) {
    return _service.searchApiExercises(query);
  }

  Future<List<ExerciseModel>> customExercises() {
    return _service.getCustomExercises(userId);
  }

  Future<void> addCustom({
    required String name,
    required String bodyPart,
    required String targetMuscle,
    required String equipment,
    String? imagePath,
  }) {
    return _service.addCustomExercise(
      ExerciseModel(
        userId: userId,
        name: name,
        bodyPart: bodyPart,
        targetMuscle: targetMuscle,
        equipment: equipment,
        imagePath: imagePath,
        source: 'custom',
      ),
    );
  }

  Future<void> deleteCustom(int id) {
    return _service.deleteCustomExercise(id, userId);
  }
}
