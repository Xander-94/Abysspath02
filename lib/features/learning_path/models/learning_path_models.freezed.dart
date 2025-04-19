// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_path_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LearningPath _$LearningPathFromJson(Map<String, dynamic> json) {
  return _LearningPath.fromJson(json);
}

/// @nodoc
mixin _$LearningPath {
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get targetGoal => throw _privateConstructorUsedError;
  String? get estimatedDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'assessment_session_id')
  String? get assessmentSessionId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LearningPath to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningPathCopyWith<LearningPath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningPathCopyWith<$Res> {
  factory $LearningPathCopyWith(
          LearningPath value, $Res Function(LearningPath) then) =
      _$LearningPathCopyWithImpl<$Res, LearningPath>;
  @useResult
  $Res call(
      {String id,
      String? userId,
      String? title,
      String? description,
      String? targetGoal,
      String? estimatedDuration,
      @JsonKey(name: 'assessment_session_id') String? assessmentSessionId,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$LearningPathCopyWithImpl<$Res, $Val extends LearningPath>
    implements $LearningPathCopyWith<$Res> {
  _$LearningPathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? targetGoal = freezed,
    Object? estimatedDuration = freezed,
    Object? assessmentSessionId = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      targetGoal: freezed == targetGoal
          ? _value.targetGoal
          : targetGoal // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as String?,
      assessmentSessionId: freezed == assessmentSessionId
          ? _value.assessmentSessionId
          : assessmentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningPathImplCopyWith<$Res>
    implements $LearningPathCopyWith<$Res> {
  factory _$$LearningPathImplCopyWith(
          _$LearningPathImpl value, $Res Function(_$LearningPathImpl) then) =
      __$$LearningPathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? userId,
      String? title,
      String? description,
      String? targetGoal,
      String? estimatedDuration,
      @JsonKey(name: 'assessment_session_id') String? assessmentSessionId,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$LearningPathImplCopyWithImpl<$Res>
    extends _$LearningPathCopyWithImpl<$Res, _$LearningPathImpl>
    implements _$$LearningPathImplCopyWith<$Res> {
  __$$LearningPathImplCopyWithImpl(
      _$LearningPathImpl _value, $Res Function(_$LearningPathImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? targetGoal = freezed,
    Object? estimatedDuration = freezed,
    Object? assessmentSessionId = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LearningPathImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      targetGoal: freezed == targetGoal
          ? _value.targetGoal
          : targetGoal // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as String?,
      assessmentSessionId: freezed == assessmentSessionId
          ? _value.assessmentSessionId
          : assessmentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LearningPathImpl extends _LearningPath with DiagnosticableTreeMixin {
  const _$LearningPathImpl(
      {required this.id,
      this.userId,
      this.title,
      this.description,
      this.targetGoal,
      this.estimatedDuration,
      @JsonKey(name: 'assessment_session_id') this.assessmentSessionId,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _metadata = metadata,
        super._();

  factory _$LearningPathImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningPathImplFromJson(json);

  @override
  final String id;
  @override
  final String? userId;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? targetGoal;
  @override
  final String? estimatedDuration;
  @override
  @JsonKey(name: 'assessment_session_id')
  final String? assessmentSessionId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LearningPath(id: $id, userId: $userId, title: $title, description: $description, targetGoal: $targetGoal, estimatedDuration: $estimatedDuration, assessmentSessionId: $assessmentSessionId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LearningPath'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('targetGoal', targetGoal))
      ..add(DiagnosticsProperty('estimatedDuration', estimatedDuration))
      ..add(DiagnosticsProperty('assessmentSessionId', assessmentSessionId))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningPathImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetGoal, targetGoal) ||
                other.targetGoal == targetGoal) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.assessmentSessionId, assessmentSessionId) ||
                other.assessmentSessionId == assessmentSessionId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      description,
      targetGoal,
      estimatedDuration,
      assessmentSessionId,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningPathImplCopyWith<_$LearningPathImpl> get copyWith =>
      __$$LearningPathImplCopyWithImpl<_$LearningPathImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningPathImplToJson(
      this,
    );
  }
}

abstract class _LearningPath extends LearningPath {
  const factory _LearningPath(
      {required final String id,
      final String? userId,
      final String? title,
      final String? description,
      final String? targetGoal,
      final String? estimatedDuration,
      @JsonKey(name: 'assessment_session_id') final String? assessmentSessionId,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$LearningPathImpl;
  const _LearningPath._() : super._();

  factory _LearningPath.fromJson(Map<String, dynamic> json) =
      _$LearningPathImpl.fromJson;

  @override
  String get id;
  @override
  String? get userId;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get targetGoal;
  @override
  String? get estimatedDuration;
  @override
  @JsonKey(name: 'assessment_session_id')
  String? get assessmentSessionId;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningPathImplCopyWith<_$LearningPathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PathNode _$PathNodeFromJson(Map<String, dynamic> json) {
  return _PathNode.fromJson(json);
}

/// @nodoc
mixin _$PathNode {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'path_id')
  String get pathId => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  double? get positionX => throw _privateConstructorUsedError;
  double? get positionY => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_time')
  String? get estimatedTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'ui_position')
  Map<String, dynamic>? get uiPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PathNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PathNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PathNodeCopyWith<PathNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathNodeCopyWith<$Res> {
  factory $PathNodeCopyWith(PathNode value, $Res Function(PathNode) then) =
      _$PathNodeCopyWithImpl<$Res, PathNode>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'path_id') String pathId,
      String? label,
      String? type,
      String? details,
      double? positionX,
      double? positionY,
      @JsonKey(name: 'estimated_time') String? estimatedTime,
      @JsonKey(name: 'ui_position') Map<String, dynamic>? uiPosition,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PathNodeCopyWithImpl<$Res, $Val extends PathNode>
    implements $PathNodeCopyWith<$Res> {
  _$PathNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PathNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pathId = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? details = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
    Object? estimatedTime = freezed,
    Object? uiPosition = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pathId: null == pathId
          ? _value.pathId
          : pathId // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      positionX: freezed == positionX
          ? _value.positionX
          : positionX // ignore: cast_nullable_to_non_nullable
              as double?,
      positionY: freezed == positionY
          ? _value.positionY
          : positionY // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      uiPosition: freezed == uiPosition
          ? _value.uiPosition
          : uiPosition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathNodeImplCopyWith<$Res>
    implements $PathNodeCopyWith<$Res> {
  factory _$$PathNodeImplCopyWith(
          _$PathNodeImpl value, $Res Function(_$PathNodeImpl) then) =
      __$$PathNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'path_id') String pathId,
      String? label,
      String? type,
      String? details,
      double? positionX,
      double? positionY,
      @JsonKey(name: 'estimated_time') String? estimatedTime,
      @JsonKey(name: 'ui_position') Map<String, dynamic>? uiPosition,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PathNodeImplCopyWithImpl<$Res>
    extends _$PathNodeCopyWithImpl<$Res, _$PathNodeImpl>
    implements _$$PathNodeImplCopyWith<$Res> {
  __$$PathNodeImplCopyWithImpl(
      _$PathNodeImpl _value, $Res Function(_$PathNodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PathNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pathId = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? details = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
    Object? estimatedTime = freezed,
    Object? uiPosition = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PathNodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pathId: null == pathId
          ? _value.pathId
          : pathId // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      positionX: freezed == positionX
          ? _value.positionX
          : positionX // ignore: cast_nullable_to_non_nullable
              as double?,
      positionY: freezed == positionY
          ? _value.positionY
          : positionY // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedTime: freezed == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      uiPosition: freezed == uiPosition
          ? _value._uiPosition
          : uiPosition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$PathNodeImpl extends _PathNode with DiagnosticableTreeMixin {
  const _$PathNodeImpl(
      {required this.id,
      @JsonKey(name: 'path_id') required this.pathId,
      this.label,
      this.type,
      this.details,
      this.positionX,
      this.positionY,
      @JsonKey(name: 'estimated_time') this.estimatedTime,
      @JsonKey(name: 'ui_position') final Map<String, dynamic>? uiPosition,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _uiPosition = uiPosition,
        super._();

  factory _$PathNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathNodeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'path_id')
  final String pathId;
  @override
  final String? label;
  @override
  final String? type;
  @override
  final String? details;
  @override
  final double? positionX;
  @override
  final double? positionY;
  @override
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;
  final Map<String, dynamic>? _uiPosition;
  @override
  @JsonKey(name: 'ui_position')
  Map<String, dynamic>? get uiPosition {
    final value = _uiPosition;
    if (value == null) return null;
    if (_uiPosition is EqualUnmodifiableMapView) return _uiPosition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PathNode(id: $id, pathId: $pathId, label: $label, type: $type, details: $details, positionX: $positionX, positionY: $positionY, estimatedTime: $estimatedTime, uiPosition: $uiPosition, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PathNode'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('pathId', pathId))
      ..add(DiagnosticsProperty('label', label))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('details', details))
      ..add(DiagnosticsProperty('positionX', positionX))
      ..add(DiagnosticsProperty('positionY', positionY))
      ..add(DiagnosticsProperty('estimatedTime', estimatedTime))
      ..add(DiagnosticsProperty('uiPosition', uiPosition))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PathNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pathId, pathId) || other.pathId == pathId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.positionX, positionX) ||
                other.positionX == positionX) &&
            (identical(other.positionY, positionY) ||
                other.positionY == positionY) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            const DeepCollectionEquality()
                .equals(other._uiPosition, _uiPosition) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      pathId,
      label,
      type,
      details,
      positionX,
      positionY,
      estimatedTime,
      const DeepCollectionEquality().hash(_uiPosition),
      createdAt,
      updatedAt);

  /// Create a copy of PathNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PathNodeImplCopyWith<_$PathNodeImpl> get copyWith =>
      __$$PathNodeImplCopyWithImpl<_$PathNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathNodeImplToJson(
      this,
    );
  }
}

abstract class _PathNode extends PathNode {
  const factory _PathNode(
      {required final String id,
      @JsonKey(name: 'path_id') required final String pathId,
      final String? label,
      final String? type,
      final String? details,
      final double? positionX,
      final double? positionY,
      @JsonKey(name: 'estimated_time') final String? estimatedTime,
      @JsonKey(name: 'ui_position') final Map<String, dynamic>? uiPosition,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$PathNodeImpl;
  const _PathNode._() : super._();

  factory _PathNode.fromJson(Map<String, dynamic> json) =
      _$PathNodeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'path_id')
  String get pathId;
  @override
  String? get label;
  @override
  String? get type;
  @override
  String? get details;
  @override
  double? get positionX;
  @override
  double? get positionY;
  @override
  @JsonKey(name: 'estimated_time')
  String? get estimatedTime;
  @override
  @JsonKey(name: 'ui_position')
  Map<String, dynamic>? get uiPosition;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PathNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PathNodeImplCopyWith<_$PathNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PathEdge _$PathEdgeFromJson(Map<String, dynamic> json) {
  return _PathEdge.fromJson(json);
}

/// @nodoc
mixin _$PathEdge {
  String? get id => throw _privateConstructorUsedError;
  String? get pathId => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_node_id')
  String? get sourceNodeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_node_id')
  String? get targetNodeId => throw _privateConstructorUsedError;
  String? get relationshipType => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PathEdge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PathEdge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PathEdgeCopyWith<PathEdge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathEdgeCopyWith<$Res> {
  factory $PathEdgeCopyWith(PathEdge value, $Res Function(PathEdge) then) =
      _$PathEdgeCopyWithImpl<$Res, PathEdge>;
  @useResult
  $Res call(
      {String? id,
      String? pathId,
      @JsonKey(name: 'source_node_id') String? sourceNodeId,
      @JsonKey(name: 'target_node_id') String? targetNodeId,
      String? relationshipType,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PathEdgeCopyWithImpl<$Res, $Val extends PathEdge>
    implements $PathEdgeCopyWith<$Res> {
  _$PathEdgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PathEdge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? pathId = freezed,
    Object? sourceNodeId = freezed,
    Object? targetNodeId = freezed,
    Object? relationshipType = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      pathId: freezed == pathId
          ? _value.pathId
          : pathId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceNodeId: freezed == sourceNodeId
          ? _value.sourceNodeId
          : sourceNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetNodeId: freezed == targetNodeId
          ? _value.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      relationshipType: freezed == relationshipType
          ? _value.relationshipType
          : relationshipType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathEdgeImplCopyWith<$Res>
    implements $PathEdgeCopyWith<$Res> {
  factory _$$PathEdgeImplCopyWith(
          _$PathEdgeImpl value, $Res Function(_$PathEdgeImpl) then) =
      __$$PathEdgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? pathId,
      @JsonKey(name: 'source_node_id') String? sourceNodeId,
      @JsonKey(name: 'target_node_id') String? targetNodeId,
      String? relationshipType,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PathEdgeImplCopyWithImpl<$Res>
    extends _$PathEdgeCopyWithImpl<$Res, _$PathEdgeImpl>
    implements _$$PathEdgeImplCopyWith<$Res> {
  __$$PathEdgeImplCopyWithImpl(
      _$PathEdgeImpl _value, $Res Function(_$PathEdgeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PathEdge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? pathId = freezed,
    Object? sourceNodeId = freezed,
    Object? targetNodeId = freezed,
    Object? relationshipType = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PathEdgeImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      pathId: freezed == pathId
          ? _value.pathId
          : pathId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceNodeId: freezed == sourceNodeId
          ? _value.sourceNodeId
          : sourceNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetNodeId: freezed == targetNodeId
          ? _value.targetNodeId
          : targetNodeId // ignore: cast_nullable_to_non_nullable
              as String?,
      relationshipType: freezed == relationshipType
          ? _value.relationshipType
          : relationshipType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$PathEdgeImpl extends _PathEdge with DiagnosticableTreeMixin {
  const _$PathEdgeImpl(
      {this.id,
      this.pathId,
      @JsonKey(name: 'source_node_id') this.sourceNodeId,
      @JsonKey(name: 'target_node_id') this.targetNodeId,
      this.relationshipType,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$PathEdgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathEdgeImplFromJson(json);

  @override
  final String? id;
  @override
  final String? pathId;
  @override
  @JsonKey(name: 'source_node_id')
  final String? sourceNodeId;
  @override
  @JsonKey(name: 'target_node_id')
  final String? targetNodeId;
  @override
  final String? relationshipType;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PathEdge(id: $id, pathId: $pathId, sourceNodeId: $sourceNodeId, targetNodeId: $targetNodeId, relationshipType: $relationshipType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PathEdge'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('pathId', pathId))
      ..add(DiagnosticsProperty('sourceNodeId', sourceNodeId))
      ..add(DiagnosticsProperty('targetNodeId', targetNodeId))
      ..add(DiagnosticsProperty('relationshipType', relationshipType))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PathEdgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pathId, pathId) || other.pathId == pathId) &&
            (identical(other.sourceNodeId, sourceNodeId) ||
                other.sourceNodeId == sourceNodeId) &&
            (identical(other.targetNodeId, targetNodeId) ||
                other.targetNodeId == targetNodeId) &&
            (identical(other.relationshipType, relationshipType) ||
                other.relationshipType == relationshipType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, pathId, sourceNodeId,
      targetNodeId, relationshipType, createdAt, updatedAt);

  /// Create a copy of PathEdge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PathEdgeImplCopyWith<_$PathEdgeImpl> get copyWith =>
      __$$PathEdgeImplCopyWithImpl<_$PathEdgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathEdgeImplToJson(
      this,
    );
  }
}

abstract class _PathEdge extends PathEdge {
  const factory _PathEdge(
      {final String? id,
      final String? pathId,
      @JsonKey(name: 'source_node_id') final String? sourceNodeId,
      @JsonKey(name: 'target_node_id') final String? targetNodeId,
      final String? relationshipType,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$PathEdgeImpl;
  const _PathEdge._() : super._();

  factory _PathEdge.fromJson(Map<String, dynamic> json) =
      _$PathEdgeImpl.fromJson;

  @override
  String? get id;
  @override
  String? get pathId;
  @override
  @JsonKey(name: 'source_node_id')
  String? get sourceNodeId;
  @override
  @JsonKey(name: 'target_node_id')
  String? get targetNodeId;
  @override
  String? get relationshipType;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PathEdge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PathEdgeImplCopyWith<_$PathEdgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NodeResource _$NodeResourceFromJson(Map<String, dynamic> json) {
  return _NodeResource.fromJson(json);
}

/// @nodoc
mixin _$NodeResource {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'node_id')
  String get nodeId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NodeResource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NodeResource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NodeResourceCopyWith<NodeResource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NodeResourceCopyWith<$Res> {
  factory $NodeResourceCopyWith(
          NodeResource value, $Res Function(NodeResource) then) =
      _$NodeResourceCopyWithImpl<$Res, NodeResource>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'node_id') String nodeId,
      String? title,
      String? type,
      String? url,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$NodeResourceCopyWithImpl<$Res, $Val extends NodeResource>
    implements $NodeResourceCopyWith<$Res> {
  _$NodeResourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NodeResource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nodeId = null,
    Object? title = freezed,
    Object? type = freezed,
    Object? url = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nodeId: null == nodeId
          ? _value.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NodeResourceImplCopyWith<$Res>
    implements $NodeResourceCopyWith<$Res> {
  factory _$$NodeResourceImplCopyWith(
          _$NodeResourceImpl value, $Res Function(_$NodeResourceImpl) then) =
      __$$NodeResourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'node_id') String nodeId,
      String? title,
      String? type,
      String? url,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$NodeResourceImplCopyWithImpl<$Res>
    extends _$NodeResourceCopyWithImpl<$Res, _$NodeResourceImpl>
    implements _$$NodeResourceImplCopyWith<$Res> {
  __$$NodeResourceImplCopyWithImpl(
      _$NodeResourceImpl _value, $Res Function(_$NodeResourceImpl) _then)
      : super(_value, _then);

  /// Create a copy of NodeResource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nodeId = null,
    Object? title = freezed,
    Object? type = freezed,
    Object? url = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$NodeResourceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nodeId: null == nodeId
          ? _value.nodeId
          : nodeId // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$NodeResourceImpl extends _NodeResource with DiagnosticableTreeMixin {
  const _$NodeResourceImpl(
      {required this.id,
      @JsonKey(name: 'node_id') required this.nodeId,
      this.title,
      this.type,
      this.url,
      this.description,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$NodeResourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$NodeResourceImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'node_id')
  final String nodeId;
  @override
  final String? title;
  @override
  final String? type;
  @override
  final String? url;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NodeResource(id: $id, nodeId: $nodeId, title: $title, type: $type, url: $url, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NodeResource'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('nodeId', nodeId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NodeResourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nodeId, nodeId) || other.nodeId == nodeId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nodeId, title, type, url,
      description, createdAt, updatedAt);

  /// Create a copy of NodeResource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NodeResourceImplCopyWith<_$NodeResourceImpl> get copyWith =>
      __$$NodeResourceImplCopyWithImpl<_$NodeResourceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NodeResourceImplToJson(
      this,
    );
  }
}

abstract class _NodeResource extends NodeResource {
  const factory _NodeResource(
          {required final String id,
          @JsonKey(name: 'node_id') required final String nodeId,
          final String? title,
          final String? type,
          final String? url,
          final String? description,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$NodeResourceImpl;
  const _NodeResource._() : super._();

  factory _NodeResource.fromJson(Map<String, dynamic> json) =
      _$NodeResourceImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'node_id')
  String get nodeId;
  @override
  String? get title;
  @override
  String? get type;
  @override
  String? get url;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of NodeResource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NodeResourceImplCopyWith<_$NodeResourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FullLearningPathResponse _$FullLearningPathResponseFromJson(
    Map<String, dynamic> json) {
  return _FullLearningPathResponse.fromJson(json);
}

/// @nodoc
mixin _$FullLearningPathResponse {
  LearningPath get path => throw _privateConstructorUsedError;
  List<PathNode> get nodes => throw _privateConstructorUsedError;
  List<PathEdge> get edges => throw _privateConstructorUsedError;
  List<NodeResource> get resources => throw _privateConstructorUsedError;

  /// Serializes this FullLearningPathResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FullLearningPathResponseCopyWith<FullLearningPathResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FullLearningPathResponseCopyWith<$Res> {
  factory $FullLearningPathResponseCopyWith(FullLearningPathResponse value,
          $Res Function(FullLearningPathResponse) then) =
      _$FullLearningPathResponseCopyWithImpl<$Res, FullLearningPathResponse>;
  @useResult
  $Res call(
      {LearningPath path,
      List<PathNode> nodes,
      List<PathEdge> edges,
      List<NodeResource> resources});

  $LearningPathCopyWith<$Res> get path;
}

/// @nodoc
class _$FullLearningPathResponseCopyWithImpl<$Res,
        $Val extends FullLearningPathResponse>
    implements $FullLearningPathResponseCopyWith<$Res> {
  _$FullLearningPathResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? nodes = null,
    Object? edges = null,
    Object? resources = null,
  }) {
    return _then(_value.copyWith(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as LearningPath,
      nodes: null == nodes
          ? _value.nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as List<PathNode>,
      edges: null == edges
          ? _value.edges
          : edges // ignore: cast_nullable_to_non_nullable
              as List<PathEdge>,
      resources: null == resources
          ? _value.resources
          : resources // ignore: cast_nullable_to_non_nullable
              as List<NodeResource>,
    ) as $Val);
  }

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LearningPathCopyWith<$Res> get path {
    return $LearningPathCopyWith<$Res>(_value.path, (value) {
      return _then(_value.copyWith(path: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FullLearningPathResponseImplCopyWith<$Res>
    implements $FullLearningPathResponseCopyWith<$Res> {
  factory _$$FullLearningPathResponseImplCopyWith(
          _$FullLearningPathResponseImpl value,
          $Res Function(_$FullLearningPathResponseImpl) then) =
      __$$FullLearningPathResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LearningPath path,
      List<PathNode> nodes,
      List<PathEdge> edges,
      List<NodeResource> resources});

  @override
  $LearningPathCopyWith<$Res> get path;
}

/// @nodoc
class __$$FullLearningPathResponseImplCopyWithImpl<$Res>
    extends _$FullLearningPathResponseCopyWithImpl<$Res,
        _$FullLearningPathResponseImpl>
    implements _$$FullLearningPathResponseImplCopyWith<$Res> {
  __$$FullLearningPathResponseImplCopyWithImpl(
      _$FullLearningPathResponseImpl _value,
      $Res Function(_$FullLearningPathResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? nodes = null,
    Object? edges = null,
    Object? resources = null,
  }) {
    return _then(_$FullLearningPathResponseImpl(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as LearningPath,
      nodes: null == nodes
          ? _value._nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as List<PathNode>,
      edges: null == edges
          ? _value._edges
          : edges // ignore: cast_nullable_to_non_nullable
              as List<PathEdge>,
      resources: null == resources
          ? _value._resources
          : resources // ignore: cast_nullable_to_non_nullable
              as List<NodeResource>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$FullLearningPathResponseImpl extends _FullLearningPathResponse
    with DiagnosticableTreeMixin {
  const _$FullLearningPathResponseImpl(
      {required this.path,
      required final List<PathNode> nodes,
      required final List<PathEdge> edges,
      required final List<NodeResource> resources})
      : _nodes = nodes,
        _edges = edges,
        _resources = resources,
        super._();

  factory _$FullLearningPathResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FullLearningPathResponseImplFromJson(json);

  @override
  final LearningPath path;
  final List<PathNode> _nodes;
  @override
  List<PathNode> get nodes {
    if (_nodes is EqualUnmodifiableListView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nodes);
  }

  final List<PathEdge> _edges;
  @override
  List<PathEdge> get edges {
    if (_edges is EqualUnmodifiableListView) return _edges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_edges);
  }

  final List<NodeResource> _resources;
  @override
  List<NodeResource> get resources {
    if (_resources is EqualUnmodifiableListView) return _resources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resources);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FullLearningPathResponse(path: $path, nodes: $nodes, edges: $edges, resources: $resources)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FullLearningPathResponse'))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('nodes', nodes))
      ..add(DiagnosticsProperty('edges', edges))
      ..add(DiagnosticsProperty('resources', resources));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FullLearningPathResponseImpl &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._nodes, _nodes) &&
            const DeepCollectionEquality().equals(other._edges, _edges) &&
            const DeepCollectionEquality()
                .equals(other._resources, _resources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      path,
      const DeepCollectionEquality().hash(_nodes),
      const DeepCollectionEquality().hash(_edges),
      const DeepCollectionEquality().hash(_resources));

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FullLearningPathResponseImplCopyWith<_$FullLearningPathResponseImpl>
      get copyWith => __$$FullLearningPathResponseImplCopyWithImpl<
          _$FullLearningPathResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FullLearningPathResponseImplToJson(
      this,
    );
  }
}

abstract class _FullLearningPathResponse extends FullLearningPathResponse {
  const factory _FullLearningPathResponse(
          {required final LearningPath path,
          required final List<PathNode> nodes,
          required final List<PathEdge> edges,
          required final List<NodeResource> resources}) =
      _$FullLearningPathResponseImpl;
  const _FullLearningPathResponse._() : super._();

  factory _FullLearningPathResponse.fromJson(Map<String, dynamic> json) =
      _$FullLearningPathResponseImpl.fromJson;

  @override
  LearningPath get path;
  @override
  List<PathNode> get nodes;
  @override
  List<PathEdge> get edges;
  @override
  List<NodeResource> get resources;

  /// Create a copy of FullLearningPathResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FullLearningPathResponseImplCopyWith<_$FullLearningPathResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LearningPathCreateRequest _$LearningPathCreateRequestFromJson(
    Map<String, dynamic> json) {
  return _LearningPathCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$LearningPathCreateRequest {
  String get userGoal => throw _privateConstructorUsedError;
  String? get assessmentSessionId => throw _privateConstructorUsedError;
  String? get userProfileJson => throw _privateConstructorUsedError;

  /// Serializes this LearningPathCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LearningPathCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningPathCreateRequestCopyWith<LearningPathCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningPathCreateRequestCopyWith<$Res> {
  factory $LearningPathCreateRequestCopyWith(LearningPathCreateRequest value,
          $Res Function(LearningPathCreateRequest) then) =
      _$LearningPathCreateRequestCopyWithImpl<$Res, LearningPathCreateRequest>;
  @useResult
  $Res call(
      {String userGoal, String? assessmentSessionId, String? userProfileJson});
}

/// @nodoc
class _$LearningPathCreateRequestCopyWithImpl<$Res,
        $Val extends LearningPathCreateRequest>
    implements $LearningPathCreateRequestCopyWith<$Res> {
  _$LearningPathCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningPathCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userGoal = null,
    Object? assessmentSessionId = freezed,
    Object? userProfileJson = freezed,
  }) {
    return _then(_value.copyWith(
      userGoal: null == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentSessionId: freezed == assessmentSessionId
          ? _value.assessmentSessionId
          : assessmentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileJson: freezed == userProfileJson
          ? _value.userProfileJson
          : userProfileJson // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningPathCreateRequestImplCopyWith<$Res>
    implements $LearningPathCreateRequestCopyWith<$Res> {
  factory _$$LearningPathCreateRequestImplCopyWith(
          _$LearningPathCreateRequestImpl value,
          $Res Function(_$LearningPathCreateRequestImpl) then) =
      __$$LearningPathCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userGoal, String? assessmentSessionId, String? userProfileJson});
}

/// @nodoc
class __$$LearningPathCreateRequestImplCopyWithImpl<$Res>
    extends _$LearningPathCreateRequestCopyWithImpl<$Res,
        _$LearningPathCreateRequestImpl>
    implements _$$LearningPathCreateRequestImplCopyWith<$Res> {
  __$$LearningPathCreateRequestImplCopyWithImpl(
      _$LearningPathCreateRequestImpl _value,
      $Res Function(_$LearningPathCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningPathCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userGoal = null,
    Object? assessmentSessionId = freezed,
    Object? userProfileJson = freezed,
  }) {
    return _then(_$LearningPathCreateRequestImpl(
      userGoal: null == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentSessionId: freezed == assessmentSessionId
          ? _value.assessmentSessionId
          : assessmentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileJson: freezed == userProfileJson
          ? _value.userProfileJson
          : userProfileJson // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LearningPathCreateRequestImpl extends _LearningPathCreateRequest
    with DiagnosticableTreeMixin {
  const _$LearningPathCreateRequestImpl(
      {required this.userGoal, this.assessmentSessionId, this.userProfileJson})
      : super._();

  factory _$LearningPathCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningPathCreateRequestImplFromJson(json);

  @override
  final String userGoal;
  @override
  final String? assessmentSessionId;
  @override
  final String? userProfileJson;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LearningPathCreateRequest(userGoal: $userGoal, assessmentSessionId: $assessmentSessionId, userProfileJson: $userProfileJson)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LearningPathCreateRequest'))
      ..add(DiagnosticsProperty('userGoal', userGoal))
      ..add(DiagnosticsProperty('assessmentSessionId', assessmentSessionId))
      ..add(DiagnosticsProperty('userProfileJson', userProfileJson));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningPathCreateRequestImpl &&
            (identical(other.userGoal, userGoal) ||
                other.userGoal == userGoal) &&
            (identical(other.assessmentSessionId, assessmentSessionId) ||
                other.assessmentSessionId == assessmentSessionId) &&
            (identical(other.userProfileJson, userProfileJson) ||
                other.userProfileJson == userProfileJson));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userGoal, assessmentSessionId, userProfileJson);

  /// Create a copy of LearningPathCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningPathCreateRequestImplCopyWith<_$LearningPathCreateRequestImpl>
      get copyWith => __$$LearningPathCreateRequestImplCopyWithImpl<
          _$LearningPathCreateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningPathCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _LearningPathCreateRequest extends LearningPathCreateRequest {
  const factory _LearningPathCreateRequest(
      {required final String userGoal,
      final String? assessmentSessionId,
      final String? userProfileJson}) = _$LearningPathCreateRequestImpl;
  const _LearningPathCreateRequest._() : super._();

  factory _LearningPathCreateRequest.fromJson(Map<String, dynamic> json) =
      _$LearningPathCreateRequestImpl.fromJson;

  @override
  String get userGoal;
  @override
  String? get assessmentSessionId;
  @override
  String? get userProfileJson;

  /// Create a copy of LearningPathCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningPathCreateRequestImplCopyWith<_$LearningPathCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
