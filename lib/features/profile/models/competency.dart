// 能力维度层模型
class Competency {
  final Map<String, SkillEntry>? skillTree;                 // 技能树
  final KnowledgeGaps? knowledgeGaps;                     // 知识盲点
  final double? skillTransferScore;                      // 技能迁移评分
  final LearningVelocity? learningVelocity;                // 学习速度
  final List<String>? targetMilestones;                  // 目标里程碑 (新增)
  final List<String>? generalSkills;                     // 通用能力 (新增)

  const Competency({
    this.skillTree,
    this.knowledgeGaps,
    this.skillTransferScore,
    this.learningVelocity,
    this.targetMilestones,                               // 新增
    this.generalSkills,                                  // 新增
  });

  Competency copyWith({
    Map<String, SkillEntry>? skillTree,
    KnowledgeGaps? knowledgeGaps,
    double? skillTransferScore,
    LearningVelocity? learningVelocity,
    List<String>? targetMilestones,                      // 新增
    List<String>? generalSkills,                         // 新增
  }) => Competency(
      skillTree: skillTree ?? this.skillTree,
      knowledgeGaps: knowledgeGaps ?? this.knowledgeGaps,
      skillTransferScore: skillTransferScore ?? this.skillTransferScore,
      learningVelocity: learningVelocity ?? this.learningVelocity,
      targetMilestones: targetMilestones ?? this.targetMilestones, // 新增
      generalSkills: generalSkills ?? this.generalSkills,         // 新增
  );

  factory Competency.fromJson(Map<String, dynamic>? json) => Competency(
    skillTree: json?['skill_tree'] == null ? null : Map.from(json!['skill_tree']).map(
      (k, v) => MapEntry(k, SkillEntry.fromJson(v))),
    knowledgeGaps: json?['knowledge_gaps'] == null ? null : KnowledgeGaps.fromJson(json!['knowledge_gaps']),
    skillTransferScore: (json?['skill_transfer_score'] as num?)?.toDouble(),
    learningVelocity: json?['learning_velocity'] == null ? null : LearningVelocity.fromJson(json!['learning_velocity']),
    // 新增: 从 JSON 解析 List<String>
    targetMilestones: json?['target_milestones'] == null ? null : List<String>.from(json!['target_milestones']),
    generalSkills: json?['general_skills'] == null ? null : List<String>.from(json!['general_skills']),
  );

  Map<String, dynamic> toJson() => {
    'skill_tree': skillTree?.map((k, v) => MapEntry(k, v.toJson())),
    'knowledge_gaps': knowledgeGaps?.toJson(),
    'skill_transfer_score': skillTransferScore,
    'learning_velocity': learningVelocity?.toJson(),
    'target_milestones': targetMilestones,               // 新增
    'general_skills': generalSkills,                   // 新增
  }..removeWhere((_, v) => v == null); // 移除空值
}

// 技能条目
class SkillEntry {
  final int? level;                                         // 等级 (1-5)
  final String? certification;                               // 证书

  const SkillEntry({this.level, this.certification});

  factory SkillEntry.fromJson(Map<String, dynamic>? json) => SkillEntry(
    level: json?['level'],
    certification: json?['certification'],
  );

  Map<String, dynamic> toJson() => {
    'level': level,
    'certification': certification,
  }..removeWhere((_, v) => v == null);
}

// 知识盲点
class KnowledgeGaps {
  final List<String>? weaknesses;                           // 弱项列表
  final String? lastUpdated;                                // 最后更新日期 (ISO)

  const KnowledgeGaps({this.weaknesses, this.lastUpdated});

  factory KnowledgeGaps.fromJson(Map<String, dynamic>? json) => KnowledgeGaps(
    weaknesses: json?['weaknesses'] == null ? null : List<String>.from(json!['weaknesses']),
    lastUpdated: json?['last_updated'],
  );

  Map<String, dynamic> toJson() => {
    'weaknesses': weaknesses,
    'last_updated': lastUpdated,
  }..removeWhere((_, v) => v == null);
}

// 学习速度
class LearningVelocity {
  final double? avgHoursPerSkill;                          // 平均每技能耗时
  final String? recentTrend;                               // 近期趋势

  const LearningVelocity({this.avgHoursPerSkill, this.recentTrend});

  factory LearningVelocity.fromJson(Map<String, dynamic>? json) => LearningVelocity(
    avgHoursPerSkill: (json?['avg_hours_per_skill'] as num?)?.toDouble(),
    recentTrend: json?['recent_trend'],
  );

  Map<String, dynamic> toJson() => {
    'avg_hours_per_skill': avgHoursPerSkill,
    'recent_trend': recentTrend,
  }..removeWhere((_, v) => v == null);
} 