// 行为特征层模型
class Behavior {
  final List<String>? learningStyles;                    // 学习风格 (已有)
  final List<String>? motivationFactors;               // 驱动因素 (已有)
  final String? engagementLevel;                       // 参与度 (已有)
  final List<String>? preferredResourceTypes;            // 偏好的资源类型 (新增)
  final List<String>? preferredPracticeForms;            // 偏好的实践形式 (新增)
  final List<String>? motivations;                       // 学习动机 (新增)
  final String? learningPersonality;                   // 学习人格 (新增)

  const Behavior({
    this.learningStyles,
    this.motivationFactors,
    this.engagementLevel,
    this.preferredResourceTypes,                       // 新增
    this.preferredPracticeForms,                       // 新增
    this.motivations,                                  // 新增
    this.learningPersonality,                          // 新增
  });

  Behavior copyWith({
    List<String>? learningStyles,
    List<String>? motivationFactors,
    String? engagementLevel,
    List<String>? preferredResourceTypes,              // 新增
    List<String>? preferredPracticeForms,              // 新增
    List<String>? motivations,                         // 新增
    String? learningPersonality,                       // 新增
  }) => Behavior(
    learningStyles: learningStyles ?? this.learningStyles,
    motivationFactors: motivationFactors ?? this.motivationFactors,
    engagementLevel: engagementLevel ?? this.engagementLevel,
    preferredResourceTypes: preferredResourceTypes ?? this.preferredResourceTypes, // 新增
    preferredPracticeForms: preferredPracticeForms ?? this.preferredPracticeForms, // 新增
    motivations: motivations ?? this.motivations,                               // 新增
    learningPersonality: learningPersonality ?? this.learningPersonality,           // 新增
  );

  factory Behavior.fromJson(Map<String, dynamic>? json) => Behavior(
    learningStyles: json?['learning_styles'] == null ? null : List<String>.from(json!['learning_styles']),
    motivationFactors: json?['motivation_factors'] == null ? null : List<String>.from(json!['motivation_factors']),
    engagementLevel: json?['engagement_level'],
    // 新增
    preferredResourceTypes: json?['preferred_resource_types'] == null ? null : List<String>.from(json!['preferred_resource_types']),
    preferredPracticeForms: json?['preferred_practice_forms'] == null ? null : List<String>.from(json!['preferred_practice_forms']),
    motivations: json?['motivations'] == null ? null : List<String>.from(json!['motivations']),
    learningPersonality: json?['learning_personality'],
  );

  Map<String, dynamic> toJson() => {
    'learning_styles': learningStyles,
    'motivation_factors': motivationFactors,
    'engagement_level': engagementLevel,
    'preferred_resource_types': preferredResourceTypes,      // 新增
    'preferred_practice_forms': preferredPracticeForms,      // 新增
    'motivations': motivations,                           // 新增
    'learning_personality': learningPersonality,            // 新增
  }..removeWhere((_, v) => v == null);
}


// 活跃周期
class ActivityCycle {
  final List<int>? peakHours;                           // 活跃小时 (0-23)
  final List<int>? weeklyPattern;                       // 活跃星期 (0-6, 0=周日)

  const ActivityCycle({this.peakHours, this.weeklyPattern});

  factory ActivityCycle.fromJson(Map<String, dynamic>? json) => ActivityCycle(
    peakHours: json?['peak_hours'] == null ? null : List<int>.from(json!['peak_hours']),
    weeklyPattern: json?['weekly_pattern'] == null ? null : List<int>.from(json!['weekly_pattern']),
  );

  Map<String, dynamic> toJson() => {
    'peak_hours': peakHours,
    'weekly_pattern': weeklyPattern,
  }..removeWhere((_, v) => v == null);
}

// 内容偏好
class ContentPreference {
  final Map<String, double>? formatWeights;               // 格式权重
  final String? difficultyBias;                         // 难度偏好 (+-百分比)

  const ContentPreference({this.formatWeights, this.difficultyBias});

  factory ContentPreference.fromJson(Map<String, dynamic>? json) => ContentPreference(
    formatWeights: json?['format_weights'] == null ? null : Map<String, double>.from(
        Map.from(json!['format_weights']).map((k, v) => MapEntry(k, (v as num).toDouble()))),
    difficultyBias: json?['difficulty_bias'],
  );

  Map<String, dynamic> toJson() => {
    'format_weights': formatWeights,
    'difficulty_bias': difficultyBias,
  }..removeWhere((_, v) => v == null);
}

// 参与度指标
class EngagementMetrics {
  final int? avgSessionMinutes;                        // 平均会话分钟数
  final int? completionRate;                           // 完成率 (0-100)

  const EngagementMetrics({this.avgSessionMinutes, this.completionRate});

  factory EngagementMetrics.fromJson(Map<String, dynamic>? json) => EngagementMetrics(
    avgSessionMinutes: json?['avg_session_minutes'],
    completionRate: json?['completion_rate'],
  );

  Map<String, dynamic> toJson() => {
    'avg_session_minutes': avgSessionMinutes,
    'completion_rate': completionRate,
  }..removeWhere((_, v) => v == null);
} 