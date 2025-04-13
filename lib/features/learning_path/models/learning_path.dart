 class LearningPath {
  final String id;
  final String title;
  final String description;
  final List<Stage> stages;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    this.stages = const [],
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    stages: (json['stages'] as List<dynamic>?)
        ?.map((e) => Stage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'stages': stages.map((e) => e.toJson()).toList(),
  };
}

class Stage {
  final String id;
  final String title;
  final String description;

  const Stage({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
  };
}