class CalorieEntryModel {
  final int? id;
  final int userId;
  final String date;
  final int consumedCalories;
  final int burnedCalories;
  final int dailyGoal;

  const CalorieEntryModel({
    this.id,
    required this.userId,
    required this.date,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.dailyGoal,
  });

  int get balance => consumedCalories - burnedCalories;
  int get remaining => dailyGoal - balance;

  factory CalorieEntryModel.fromMap(Map<String, dynamic> map) {
    return CalorieEntryModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      date: map['date'] as String,
      consumedCalories: map['consumedCalories'] as int,
      burnedCalories: map['burnedCalories'] as int,
      dailyGoal: map['dailyGoal'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'consumedCalories': consumedCalories,
      'burnedCalories': burnedCalories,
      'dailyGoal': dailyGoal,
    };
  }
}
