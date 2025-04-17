// 领域关联层模型
class DomainRelations {
  final List<DomainGraphEntry>? domainGraph;            // 领域关联图谱
  final Map<String, double>? crossDomainScores;        // 跨领域适配度评分
  final BridgeRecommendations? bridgeRecommendations;   // 桥梁技能推荐

  const DomainRelations({
    this.domainGraph,
    this.crossDomainScores,
    this.bridgeRecommendations,
  });

  DomainRelations copyWith({
    List<DomainGraphEntry>? domainGraph,
    Map<String, double>? crossDomainScores,
    BridgeRecommendations? bridgeRecommendations,
  }) => DomainRelations(
    domainGraph: domainGraph ?? this.domainGraph,
    crossDomainScores: crossDomainScores ?? this.crossDomainScores,
    bridgeRecommendations: bridgeRecommendations ?? this.bridgeRecommendations,
  );

  factory DomainRelations.fromJson(Map<String, dynamic>? json) => DomainRelations(
    domainGraph: json?['domain_graph'] == null ? null
        : List<DomainGraphEntry>.from((json!['domain_graph'] as List)
            .map((x) => DomainGraphEntry.fromJson(x))),
    crossDomainScores: json?['cross_domain_scores'] == null ? null : Map<String, double>.from(
        Map.from(json!['cross_domain_scores']).map((k, v) => MapEntry(k, (v as num).toDouble()))),
    bridgeRecommendations: json?['bridge_recommendations'] == null ? null
        : BridgeRecommendations.fromJson(json!['bridge_recommendations']),
  );

  Map<String, dynamic> toJson() => {
    'domain_graph': domainGraph?.map((x) => x.toJson()).toList(),
    'cross_domain_scores': crossDomainScores,
    'bridge_recommendations': bridgeRecommendations?.toJson(),
  }..removeWhere((_, v) => v == null);
}

// 领域图谱条目
class DomainGraphEntry {
  final String? source;                                // 源领域
  final String? target;                                // 目标领域
  final List<String>? bridgeSkills;                    // 桥梁技能

  const DomainGraphEntry({this.source, this.target, this.bridgeSkills});

  factory DomainGraphEntry.fromJson(Map<String, dynamic>? json) => DomainGraphEntry(
    source: json?['source'],
    target: json?['target'],
    bridgeSkills: json?['bridge_skills'] == null ? null : List<String>.from(json!['bridge_skills']),
  );

  Map<String, dynamic> toJson() => {
    'source': source,
    'target': target,
    'bridge_skills': bridgeSkills,
  }..removeWhere((_, v) => v == null);
}

// 桥梁技能推荐
class BridgeRecommendations {
  final String? targetDomain;                          // 目标领域
  final List<String>? requiredSkills;                  // 必需技能

  const BridgeRecommendations({this.targetDomain, this.requiredSkills});

  factory BridgeRecommendations.fromJson(Map<String, dynamic>? json) => BridgeRecommendations(
    targetDomain: json?['target_domain'],
    requiredSkills: json?['required_skills'] == null ? null : List<String>.from(json!['required_skills']),
  );

  Map<String, dynamic> toJson() => {
    'target_domain': targetDomain,
    'required_skills': requiredSkills,
  }..removeWhere((_, v) => v == null);
} 