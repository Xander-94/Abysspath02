import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'learning_path_models.freezed.dart';
part 'learning_path_models.g.dart';

// --- LearningPath ---
@freezed
class LearningPath with _$LearningPath {
  const LearningPath._();
  
  @JsonSerializable(explicitToJson: true)
  const factory LearningPath({
    required String id,
    String? userId,
    String? title,
    String? description,
    String? targetGoal,
    String? estimatedDuration,
    @JsonKey(name: 'assessment_session_id') String? assessmentSessionId,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LearningPath;

  factory LearningPath.fromJson(Map<String, dynamic> json) => _$LearningPathFromJson(json);
}

// --- PathNode ---
@freezed
class PathNode with _$PathNode {
  const PathNode._();
  
  @JsonSerializable(explicitToJson: true)
  const factory PathNode({
    required String id,
    @JsonKey(name: 'path_id') required String pathId,
    String? label,
    String? type,
    String? details,
    double? positionX,
    double? positionY,
    @JsonKey(name: 'estimated_time') String? estimatedTime,
    @JsonKey(name: 'ui_position') Map<String, dynamic>? uiPosition,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PathNode;

  factory PathNode.fromJson(Map<String, dynamic> json) => _$PathNodeFromJson(json);
}

// --- PathEdge ---
@freezed
class PathEdge with _$PathEdge {
  const PathEdge._();
  
  @JsonSerializable(explicitToJson: true)
  const factory PathEdge({
    String? id,
    String? pathId,
    @JsonKey(name: 'source_node_id') String? sourceNodeId,
    @JsonKey(name: 'target_node_id') String? targetNodeId,
    String? relationshipType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PathEdge;

  factory PathEdge.fromJson(Map<String, dynamic> json) => _$PathEdgeFromJson(json);
}

// --- NodeResource ---
@freezed
class NodeResource with _$NodeResource {
  const NodeResource._();
  
  @JsonSerializable(explicitToJson: true)
  const factory NodeResource({
    required String id,
    @JsonKey(name: 'node_id') required String nodeId,
    String? title,
    String? type,
    String? url,
    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _NodeResource;

  factory NodeResource.fromJson(Map<String, dynamic> json) => _$NodeResourceFromJson(json);
}

// --- FullLearningPathResponse --- (对应后端的同名模型)
@freezed
class FullLearningPathResponse with _$FullLearningPathResponse {
  const FullLearningPathResponse._();
  
  @JsonSerializable(explicitToJson: true)
  const factory FullLearningPathResponse({
    required LearningPath path,
    required List<PathNode> nodes,
    required List<PathEdge> edges,
    required List<NodeResource> resources,
  }) = _FullLearningPathResponse;

  factory FullLearningPathResponse.fromJson(Map<String, dynamic> json) => _$FullLearningPathResponseFromJson(json);
}

// --- LearningPathCreateRequest --- (对应后端的同名模型)
@freezed
class LearningPathCreateRequest with _$LearningPathCreateRequest {
  const LearningPathCreateRequest._();
  
  @JsonSerializable(explicitToJson: true)
  const factory LearningPathCreateRequest({
    required String userGoal,
    String? assessmentSessionId,
    String? userProfileJson,
  }) = _LearningPathCreateRequest;

  factory LearningPathCreateRequest.fromJson(Map<String, dynamic> json) => _$LearningPathCreateRequestFromJson(json);
} 