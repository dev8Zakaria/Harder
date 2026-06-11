class UserProfileModel {
  final int? id;
  final int userId;
  final String fullName;
  final int age;
  final String goal;
  final String level;
  final int sessionsPerWeek;
  final double height;
  final double initialWeight;

  const UserProfileModel({
    this.id,
    required this.userId,
    required this.fullName,
    required this.age,
    required this.goal,
    required this.level,
    required this.sessionsPerWeek,
    required this.height,
    required this.initialWeight,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      fullName: map['fullName'] as String,
      age: map['age'] as int,
      goal: map['goal'] as String,
      level: map['level'] as String,
      sessionsPerWeek: map['sessionsPerWeek'] as int,
      height: (map['height'] as num).toDouble(),
      initialWeight: (map['initialWeight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'age': age,
      'goal': goal,
      'level': level,
      'sessionsPerWeek': sessionsPerWeek,
      'height': height,
      'initialWeight': initialWeight,
    };
  }
}
