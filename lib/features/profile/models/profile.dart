import 'competency.dart';             // 能力
import 'interest_graph.dart';        // 兴趣
import 'behavior.dart';            // 行为
import 'constraints.dart';         // 约束
import 'dynamic_flags.dart';       // 动态标记
import 'domain_relations.dart';    // 领域关联

class Profile {
  final String? id;                                 // 用户ID
  final String? name;                               // 用户名
  final String? email;                              // 邮箱
  final String? avatar;                             // 头像URL
  final Competency? competency;                     // 能力维度
  final InterestGraph? interestGraph;                // 兴趣图谱
  final Behavior? behavior;                         // 行为特征
  final Constraints? constraints;                   // 约束条件
  final DynamicFlags? dynamicFlags;                 // 动态标记
  final DomainRelations? domainRelations;            // 领域关联
  final Map<String, dynamic>? surveyResponses;        // 问卷回复数据 (新增)
  // 注意: profile_version 和 data_source 字段暂未添加，按需添加

  const Profile({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.competency,
    this.interestGraph,
    this.behavior,
    this.constraints,
    this.dynamicFlags,
    this.domainRelations,
    this.surveyResponses,                             // 新增
  });                                               // 构造函数

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    Competency? competency,
    InterestGraph? interestGraph,
    Behavior? behavior,
    Constraints? constraints,
    DynamicFlags? dynamicFlags,
    DomainRelations? domainRelations,
    Map<String, dynamic>? surveyResponses,          // 新增
  }) => Profile(                                     // 复制方法
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    competency: competency ?? this.competency,
    interestGraph: interestGraph ?? this.interestGraph,
    behavior: behavior ?? this.behavior,
    constraints: constraints ?? this.constraints,
    dynamicFlags: dynamicFlags ?? this.dynamicFlags,
    domainRelations: domainRelations ?? this.domainRelations,
    surveyResponses: surveyResponses ?? this.surveyResponses, // 新增
  );

  factory Profile.fromJson(Map<String, dynamic> j) => Profile( // JSON解析
    id: j['id'], name: j['name'], email: j['email'], avatar: j['avatar_url'], // 注意数据库是 avatar_url
    competency: j['competency'] == null ? null : Competency.fromJson(j['competency']),
    interestGraph: j['interest_graph'] == null ? null : InterestGraph.fromJson(j['interest_graph']),
    behavior: j['behavior'] == null ? null : Behavior.fromJson(j['behavior']),
    constraints: j['constraints'] == null ? null : Constraints.fromJson(j['constraints']),
    dynamicFlags: j['dynamic_flags'] == null ? null : DynamicFlags.fromJson(j['dynamic_flags']),
    domainRelations: j['domain_relations'] == null ? null : DomainRelations.fromJson(j['domain_relations']),
    surveyResponses: j['survey_responses'] as Map<String, dynamic>?, // 新增
  );

  Map<String, dynamic> toJson() => {                 // JSON序列化
    'id': id, 'name': name, 'email': email, 'avatar_url': avatar, // 注意数据库是 avatar_url
    'competency': competency?.toJson(),
    'interest_graph': interestGraph?.toJson(),
    'behavior': behavior?.toJson(),
    'constraints': constraints?.toJson(),
    'dynamic_flags': dynamicFlags?.toJson(),
    'domain_relations': domainRelations?.toJson(),
    'survey_responses': surveyResponses,              // 新增
  }..removeWhere((_, v) => v == null);             // 移除空值

  bool get isValid => id != null && name != null && email != null; // 基础字段验证 (可按需扩展)

  @override
  String toString() => 'Profile(id: $id, name: $name, email: $email, surveyResponses: ${surveyResponses != null}, ...画像数据...)'; // 更新调试输出
} 