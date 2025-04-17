// 兴趣图谱层模型
class InterestGraph {
  final Map<String, double>? primaryInterests;           // 核心兴趣权重
  final Map<String, double>? crossDomainLinks;           // 跨领域兴趣关联
  final InterestConsistency? interestConsistency;        // 兴趣稳定性

  const InterestGraph({
    this.primaryInterests,
    this.crossDomainLinks,
    this.interestConsistency,
  });

  InterestGraph copyWith({
    Map<String, double>? primaryInterests,
    Map<String, double>? crossDomainLinks,
    InterestConsistency? interestConsistency,
  }) => InterestGraph(
      primaryInterests: primaryInterests ?? this.primaryInterests,
      crossDomainLinks: crossDomainLinks ?? this.crossDomainLinks,
      interestConsistency: interestConsistency ?? this.interestConsistency,
    );

  factory InterestGraph.fromJson(Map<String, dynamic>? json) => InterestGraph(
    primaryInterests: json?['primary_interests'] == null ? null : Map<String, double>.from(
        Map.from(json!['primary_interests']).map((k, v) => MapEntry(k, (v as num).toDouble()))),
    crossDomainLinks: json?['cross_domain_links'] == null ? null : Map<String, double>.from(
        Map.from(json!['cross_domain_links']).map((k, v) => MapEntry(k, (v as num).toDouble()))),
    interestConsistency: json?['interest_consistency'] == null ? null
        : InterestConsistency.fromJson(json!['interest_consistency']),
  );

  Map<String, dynamic> toJson() => {
    'primary_interests': primaryInterests,
    'cross_domain_links': crossDomainLinks,
    'interest_consistency': interestConsistency?.toJson(),
  }..removeWhere((_, v) => v == null);
}

// 兴趣稳定性
class InterestConsistency {
  final double? volatilityScore;                          // 波动评分 (0-1)
  final List<String>? topStableTags;                      // 稳定兴趣标签

  const InterestConsistency({this.volatilityScore, this.topStableTags});

  factory InterestConsistency.fromJson(Map<String, dynamic>? json) => InterestConsistency(
    volatilityScore: (json?['volatility_score'] as num?)?.toDouble(),
    topStableTags: json?['top_stable_tags'] == null ? null : List<String>.from(json!['top_stable_tags']),
  );

  Map<String, dynamic> toJson() => {
    'volatility_score': volatilityScore,
    'top_stable_tags': topStableTags,
  }..removeWhere((_, v) => v == null);
} 