class WorkoutSessionModel {
  final int? id;
  final int userId;
  final String workoutName;
  final String date;
  final int durationSeconds;
  final int totalSets;
  final double totalVolume;

  const WorkoutSessionModel({
    this.id,
    required this.userId,
    required this.workoutName,
    required this.date,
    required this.durationSeconds,
    required this.totalSets,
    required this.totalVolume,
  });

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      workoutName: map['workoutName'] as String,
      date: map['date'] as String,
      durationSeconds: map['durationSeconds'] as int,
      totalSets: map['totalSets'] as int,
      totalVolume: (map['totalVolume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workoutName': workoutName,
      'date': date,
      'durationSeconds': durationSeconds,
      'totalSets': totalSets,
      'totalVolume': totalVolume,
    };
  }
}
