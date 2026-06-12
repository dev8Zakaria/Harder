import 'dart:convert';

class WorkoutModel {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final String dayName;
  final List<String> exercises;

  const WorkoutModel({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.dayName,
    this.exercises = const [],
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedExercises = [];
    if (map['exercises'] != null && map['exercises'].toString().isNotEmpty) {
      try {
        final List<dynamic> decoded =
            jsonDecode(map['exercises'] as String) as List<dynamic>;
        parsedExercises = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return WorkoutModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      dayName: map['dayName'] as String,
      exercises: parsedExercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'dayName': dayName,
      'exercises': jsonEncode(exercises),
    };
  }
}
