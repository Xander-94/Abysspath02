// 动态标记层模型
class DynamicFlags {
  final String? currentGoal;                          // 当前目标 (已有)
  final bool? isActiveLearner;                        // 是否活跃学习者 (已有)
  final String? lastActivityType;                     // 最后活动类型 (已有)
  final String? currentStage;                         // 当前所处阶段 (新增)

  const DynamicFlags({
    this.currentGoal,
    this.isActiveLearner,
    this.lastActivityType,
    this.currentStage,                               // 新增
  });

  DynamicFlags copyWith({
    String? currentGoal,
    bool? isActiveLearner,
    String? lastActivityType,
    String? currentStage,                           // 新增
  }) => DynamicFlags(
    currentGoal: currentGoal ?? this.currentGoal,
    isActiveLearner: isActiveLearner ?? this.isActiveLearner,
    lastActivityType: lastActivityType ?? this.lastActivityType,
    currentStage: currentStage ?? this.currentStage,       // 新增
  );

  factory DynamicFlags.fromJson(Map<String, dynamic>? json) => DynamicFlags(
    currentGoal: json?['current_goal'],
    isActiveLearner: json?['is_active_learner'],
    lastActivityType: json?['last_activity_type'],
    currentStage: json?['current_stage'],              // 新增
  );

  Map<String, dynamic> toJson() => {
    'current_goal': currentGoal,
    'is_active_learner': isActiveLearner,
    'last_activity_type': lastActivityType,
    'current_stage': currentStage,                   // 新增
  }..removeWhere((_, v) => v == null);
}


// 学习瓶颈
class LearningBlocks {
  final List<String>? blockedSkills;                   // 受困技能列表
  final String? detectedAt;                            // 检测时间 (ISO)

  const LearningBlocks({this.blockedSkills, this.detectedAt});

  factory LearningBlocks.fromJson(Map<String, dynamic>? json) => LearningBlocks(
    blockedSkills: json?['blocked_skills'] == null ? null : List<String>.from(json!['blocked_skills']),
    detectedAt: json?['detected_at'],
  );

  Map<String, dynamic> toJson() => {
    'blocked_skills': blockedSkills,
    'detected_at': detectedAt,
  }..removeWhere((_, v) => v == null);
}

// 成就
class Achievements {
  final List<String>? badges;                          // 成就徽章列表

  const Achievements({this.badges});

  factory Achievements.fromJson(Map<String, dynamic>? json) => Achievements(
    badges: json?['badges'] == null ? null : List<String>.from(json!['badges']),
  );

  Map<String, dynamic> toJson() => {
    'badges': badges,
  }..removeWhere((_, v) => v == null);
}

// 自适应标记
class AdaptiveFlags {
  final bool? needsReassessment;                      // 是否需要重新评估
  final String? reason;                               // 原因

  const AdaptiveFlags({this.needsReassessment, this.reason});

  factory AdaptiveFlags.fromJson(Map<String, dynamic>? json) => AdaptiveFlags(
    needsReassessment: json?['needs_reassessment'],
    reason: json?['reason'],
  );

  Map<String, dynamic> toJson() => {
    'needs_reassessment': needsReassessment,
    'reason': reason,
  }..removeWhere((_, v) => v == null);
} 