import '../models/calorie_entry_model.dart';
import 'database_service.dart';

class CaloriesService {
  Future<List<CalorieEntryModel>> getEntries(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'calorie_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(CalorieEntryModel.fromMap).toList();
  }

  Future<void> addEntry(CalorieEntryModel entry) async {
    final db = await DatabaseService.instance.database;
    await db.insert('calorie_entries', entry.toMap());
  }
}
