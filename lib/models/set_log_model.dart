class SetLogModel {
  final int? id;
  final int userId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weight;

  const SetLogModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory SetLogModel.fromMap(Map<String, dynamic> map) {
    return SetLogModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      exerciseName: map['exerciseName'] as String,
      setNumber: map['setNumber'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
    };
  }
}
