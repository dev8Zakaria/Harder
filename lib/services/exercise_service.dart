import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exercise_model.dart';
import '../utils/exercise_api_config.dart';
import 'database_service.dart';

class ExerciseService {
  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com';

  Future<List<ExerciseModel>> getApiExercises() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/exercises?limit=1300'),
            headers: ExerciseApiConfig.headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Sans clé RapidAPI ou sans Internet, l'application garde une liste locale.
    }
    return fallbackExercises;
  }

  Future<List<ExerciseModel>> searchApiExercises(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) {
      return getApiExercises();
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/exercises/name/${Uri.encodeComponent(cleanQuery)}',
            ),
            headers: ExerciseApiConfig.headers,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback local si l'API ne repond pas.
    }

    final lower = cleanQuery.toLowerCase();
    return fallbackExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lower) ||
          exercise.bodyPart.toLowerCase().contains(lower) ||
          exercise.targetMuscle.toLowerCase().contains(lower) ||
          exercise.equipment.toLowerCase().contains(lower);
    }).toList();
  }

  Future<List<ExerciseModel>> getCustomExercises(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'custom_exercises',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(ExerciseModel.fromMap).toList();
  }

  Future<void> addCustomExercise(ExerciseModel exercise) async {
    final db = await DatabaseService.instance.database;
    await db.insert('custom_exercises', exercise.toMap());
  }

  Future<void> deleteCustomExercise(int id, int userId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'custom_exercises',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  List<ExerciseModel> get fallbackExercises {
    return const [
      ExerciseModel(
        id: 1,
        name: 'bench press',
        bodyPart: 'chest',
        targetMuscle: 'pectorals',
        equipment: 'barbell',
        imageUrl: 'https://d205bpvrqc9yn1.cloudfront.net/0025.gif',
        source: 'api',
      ),
      ExerciseModel(
        id: 2,
        name: 'squat',
        bodyPart: 'upper legs',
        targetMuscle: 'quads',
        equipment: 'barbell',
        imageUrl: 'https://d205bpvrqc9yn1.cloudfront.net/0047.gif',
        source: 'api',
      ),
      ExerciseModel(
        id: 3,
        name: 'deadlift',
        bodyPart: 'back',
        targetMuscle: 'spine',
        equipment: 'barbell',
        imageUrl: 'https://d205bpvrqc9yn1.cloudfront.net/0032.gif',
        source: 'api',
      ),
      ExerciseModel(
        id: 4,
        name: 'pull-up',
        bodyPart: 'back',
        targetMuscle: 'lats',
        equipment: 'body weight',
        imageUrl: 'https://d205bpvrqc9yn1.cloudfront.net/0652.gif',
        source: 'api',
      ),
    ];
  }
}
