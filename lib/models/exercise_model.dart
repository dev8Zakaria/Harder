class ExerciseModel {
  final int? id;
  final int? userId;
  final String name;
  final String bodyPart;
  final String targetMuscle;
  final String equipment;
  final String? imageUrl;
  final String? imagePath;
  final String source;

  const ExerciseModel({
    this.id,
    this.userId,
    required this.name,
    required this.bodyPart,
    required this.targetMuscle,
    required this.equipment,
    this.imageUrl,
    this.imagePath,
    required this.source,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final parsedId = int.tryParse(json['id'].toString());
    String? rawUrl = json['gifUrl']?.toString() ?? json['imageUrl']?.toString();
    if (rawUrl != null && rawUrl.startsWith('http://')) {
      rawUrl = rawUrl.replaceFirst('http://', 'https://');
    }
    rawUrl ??= parsedId == null
        ? null
        : 'https://exercisedb.p.rapidapi.com/image?exerciseId=$parsedId&resolution=180';
    return ExerciseModel(
      id: parsedId,
      userId: json['userId'] is int ? json['userId'] as int : null,
      name: json['name']?.toString() ?? '',
      bodyPart: json['bodyPart']?.toString() ?? '',
      targetMuscle:
          json['target']?.toString() ?? json['targetMuscle']?.toString() ?? '',
      equipment: json['equipment']?.toString() ?? '',
      imageUrl: rawUrl,
      imagePath: json['imagePath']?.toString(),
      source: json['source']?.toString() ?? 'api',
    );
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      name: map['name'] as String,
      bodyPart: map['bodyPart'] as String,
      targetMuscle: map['targetMuscle'] as String,
      equipment: map['equipment'] as String,
      imageUrl: map['imageUrl'] as String?,
      imagePath: map['imagePath'] as String?,
      source: map['source'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'bodyPart': bodyPart,
      'targetMuscle': targetMuscle,
      'equipment': equipment,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'source': source,
    };
  }
}
