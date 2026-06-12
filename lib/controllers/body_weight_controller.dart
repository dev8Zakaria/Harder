import '../models/body_weight_model.dart';
import '../services/body_weight_service.dart';

class BodyWeightController {
  final BodyWeightService _service = BodyWeightService();
  final int userId;

  BodyWeightController(this.userId);

  Future<List<BodyWeightModel>> all() {
    return _service.getWeights(userId);
  }

  Future<void> add(double weight) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _service.addWeight(
      BodyWeightModel(userId: userId, date: today, weight: weight),
    );
  }
}
