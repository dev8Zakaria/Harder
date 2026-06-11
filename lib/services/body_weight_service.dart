import '../models/body_weight_model.dart';
import 'database_service.dart';

class BodyWeightService {
  Future<List<BodyWeightModel>> getWeights(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'body_weights',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(BodyWeightModel.fromMap).toList();
  }

  Future<void> addWeight(BodyWeightModel weight) async {
    final db = await DatabaseService.instance.database;
    await db.insert('body_weights', weight.toMap());
  }
}
