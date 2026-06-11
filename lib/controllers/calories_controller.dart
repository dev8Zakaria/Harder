import '../models/calorie_entry_model.dart';
import '../services/calories_service.dart';

class CaloriesController {
  final CaloriesService _service = CaloriesService();
  final int userId;

  CaloriesController(this.userId);

  Future<List<CalorieEntryModel>> all() {
    return _service.getEntries(userId);
  }

  Future<void> add({
    required int consumed,
    required int burned,
    required int goal,
  }) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _service.addEntry(
      CalorieEntryModel(
        userId: userId,
        date: today,
        consumedCalories: consumed,
        burnedCalories: burned,
        dailyGoal: goal,
      ),
    );
  }
}
