class BodyWeightModel {
  final int? id;
  final int userId;
  final String date;
  final double weight;

  const BodyWeightModel({
    this.id,
    required this.userId,
    required this.date,
    required this.weight,
  });

  factory BodyWeightModel.fromMap(Map<String, dynamic> map) {
    return BodyWeightModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      date: map['date'] as String,
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'weight': weight,
    };
  }
}
