// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AssessmentProfile _$AssessmentProfileFromJson(Map<String, dynamic> json) {
  return _AssessmentProfile.fromJson(json);
}

/// @nodoc
mixin _$AssessmentProfile {
  @JsonKey(name: 'core_analysis')
  CoreAnalysis? get coreAnalysis => throw _privateConstructorUsedError;
  @JsonKey(name: 'behavioral_profile')
  BehavioralProfile? get behavioralProfile =>
      throw _privateConstructorUsedError;

  /// Serializes this AssessmentProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssessmentProfileCopyWith<AssessmentProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentProfileCopyWith<$Res> {
  factory $AssessmentProfileCopyWith(
          AssessmentProfile value, $Res Function(AssessmentProfile) then) =
      _$AssessmentProfileCopyWithImpl<$Res, AssessmentProfile>;
  @useResult
  $Res call(
      {@JsonKey(name: 'core_analysis') CoreAnalysis? coreAnalysis,
      @JsonKey(name: 'behavioral_profile')
      BehavioralProfile? behavioralProfile});

  $CoreAnalysisCopyWith<$Res>? get coreAnalysis;
  $BehavioralProfileCopyWith<$Res>? get behavioralProfile;
}

/// @nodoc
class _$AssessmentProfileCopyWithImpl<$Res, $Val extends AssessmentProfile>
    implements $AssessmentProfileCopyWith<$Res> {
  _$AssessmentProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coreAnalysis = freezed,
    Object? behavioralProfile = freezed,
  }) {
    return _then(_value.copyWith(
      coreAnalysis: freezed == coreAnalysis
          ? _value.coreAnalysis
          : coreAnalysis // ignore: cast_nullable_to_non_nullable
              as CoreAnalysis?,
      behavioralProfile: freezed == behavioralProfile
          ? _value.behavioralProfile
          : behavioralProfile // ignore: cast_nullable_to_non_nullable
              as BehavioralProfile?,
    ) as $Val);
  }

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CoreAnalysisCopyWith<$Res>? get coreAnalysis {
    if (_value.coreAnalysis == null) {
      return null;
    }

    return $CoreAnalysisCopyWith<$Res>(_value.coreAnalysis!, (value) {
      return _then(_value.copyWith(coreAnalysis: value) as $Val);
    });
  }

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BehavioralProfileCopyWith<$Res>? get behavioralProfile {
    if (_value.behavioralProfile == null) {
      return null;
    }

    return $BehavioralProfileCopyWith<$Res>(_value.behavioralProfile!, (value) {
      return _then(_value.copyWith(behavioralProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssessmentProfileImplCopyWith<$Res>
    implements $AssessmentProfileCopyWith<$Res> {
  factory _$$AssessmentProfileImplCopyWith(_$AssessmentProfileImpl value,
          $Res Function(_$AssessmentProfileImpl) then) =
      __$$AssessmentProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'core_analysis') CoreAnalysis? coreAnalysis,
      @JsonKey(name: 'behavioral_profile')
      BehavioralProfile? behavioralProfile});

  @override
  $CoreAnalysisCopyWith<$Res>? get coreAnalysis;
  @override
  $BehavioralProfileCopyWith<$Res>? get behavioralProfile;
}

/// @nodoc
class __$$AssessmentProfileImplCopyWithImpl<$Res>
    extends _$AssessmentProfileCopyWithImpl<$Res, _$AssessmentProfileImpl>
    implements _$$AssessmentProfileImplCopyWith<$Res> {
  __$$AssessmentProfileImplCopyWithImpl(_$AssessmentProfileImpl _value,
      $Res Function(_$AssessmentProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coreAnalysis = freezed,
    Object? behavioralProfile = freezed,
  }) {
    return _then(_$AssessmentProfileImpl(
      coreAnalysis: freezed == coreAnalysis
          ? _value.coreAnalysis
          : coreAnalysis // ignore: cast_nullable_to_non_nullable
              as CoreAnalysis?,
      behavioralProfile: freezed == behavioralProfile
          ? _value.behavioralProfile
          : behavioralProfile // ignore: cast_nullable_to_non_nullable
              as BehavioralProfile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssessmentProfileImpl implements _AssessmentProfile {
  const _$AssessmentProfileImpl(
      {@JsonKey(name: 'core_analysis') this.coreAnalysis,
      @JsonKey(name: 'behavioral_profile') this.behavioralProfile});

  factory _$AssessmentProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssessmentProfileImplFromJson(json);

  @override
  @JsonKey(name: 'core_analysis')
  final CoreAnalysis? coreAnalysis;
  @override
  @JsonKey(name: 'behavioral_profile')
  final BehavioralProfile? behavioralProfile;

  @override
  String toString() {
    return 'AssessmentProfile(coreAnalysis: $coreAnalysis, behavioralProfile: $behavioralProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssessmentProfileImpl &&
            (identical(other.coreAnalysis, coreAnalysis) ||
                other.coreAnalysis == coreAnalysis) &&
            (identical(other.behavioralProfile, behavioralProfile) ||
                other.behavioralProfile == behavioralProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, coreAnalysis, behavioralProfile);

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssessmentProfileImplCopyWith<_$AssessmentProfileImpl> get copyWith =>
      __$$AssessmentProfileImplCopyWithImpl<_$AssessmentProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssessmentProfileImplToJson(
      this,
    );
  }
}

abstract class _AssessmentProfile implements AssessmentProfile {
  const factory _AssessmentProfile(
      {@JsonKey(name: 'core_analysis') final CoreAnalysis? coreAnalysis,
      @JsonKey(name: 'behavioral_profile')
      final BehavioralProfile? behavioralProfile}) = _$AssessmentProfileImpl;

  factory _AssessmentProfile.fromJson(Map<String, dynamic> json) =
      _$AssessmentProfileImpl.fromJson;

  @override
  @JsonKey(name: 'core_analysis')
  CoreAnalysis? get coreAnalysis;
  @override
  @JsonKey(name: 'behavioral_profile')
  BehavioralProfile? get behavioralProfile;

  /// Create a copy of AssessmentProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssessmentProfileImplCopyWith<_$AssessmentProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoreAnalysis _$CoreAnalysisFromJson(Map<String, dynamic> json) {
  return _CoreAnalysis.fromJson(json);
}

/// @nodoc
mixin _$CoreAnalysis {
  List<Competency> get competencies => throw _privateConstructorUsedError;
  @JsonKey(name: 'interest_layers')
  InterestLayers? get interestLayers => throw _privateConstructorUsedError;

  /// Serializes this CoreAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoreAnalysisCopyWith<CoreAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoreAnalysisCopyWith<$Res> {
  factory $CoreAnalysisCopyWith(
          CoreAnalysis value, $Res Function(CoreAnalysis) then) =
      _$CoreAnalysisCopyWithImpl<$Res, CoreAnalysis>;
  @useResult
  $Res call(
      {List<Competency> competencies,
      @JsonKey(name: 'interest_layers') InterestLayers? interestLayers});

  $InterestLayersCopyWith<$Res>? get interestLayers;
}

/// @nodoc
class _$CoreAnalysisCopyWithImpl<$Res, $Val extends CoreAnalysis>
    implements $CoreAnalysisCopyWith<$Res> {
  _$CoreAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competencies = null,
    Object? interestLayers = freezed,
  }) {
    return _then(_value.copyWith(
      competencies: null == competencies
          ? _value.competencies
          : competencies // ignore: cast_nullable_to_non_nullable
              as List<Competency>,
      interestLayers: freezed == interestLayers
          ? _value.interestLayers
          : interestLayers // ignore: cast_nullable_to_non_nullable
              as InterestLayers?,
    ) as $Val);
  }

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InterestLayersCopyWith<$Res>? get interestLayers {
    if (_value.interestLayers == null) {
      return null;
    }

    return $InterestLayersCopyWith<$Res>(_value.interestLayers!, (value) {
      return _then(_value.copyWith(interestLayers: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoreAnalysisImplCopyWith<$Res>
    implements $CoreAnalysisCopyWith<$Res> {
  factory _$$CoreAnalysisImplCopyWith(
          _$CoreAnalysisImpl value, $Res Function(_$CoreAnalysisImpl) then) =
      __$$CoreAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Competency> competencies,
      @JsonKey(name: 'interest_layers') InterestLayers? interestLayers});

  @override
  $InterestLayersCopyWith<$Res>? get interestLayers;
}

/// @nodoc
class __$$CoreAnalysisImplCopyWithImpl<$Res>
    extends _$CoreAnalysisCopyWithImpl<$Res, _$CoreAnalysisImpl>
    implements _$$CoreAnalysisImplCopyWith<$Res> {
  __$$CoreAnalysisImplCopyWithImpl(
      _$CoreAnalysisImpl _value, $Res Function(_$CoreAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competencies = null,
    Object? interestLayers = freezed,
  }) {
    return _then(_$CoreAnalysisImpl(
      competencies: null == competencies
          ? _value._competencies
          : competencies // ignore: cast_nullable_to_non_nullable
              as List<Competency>,
      interestLayers: freezed == interestLayers
          ? _value.interestLayers
          : interestLayers // ignore: cast_nullable_to_non_nullable
              as InterestLayers?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoreAnalysisImpl implements _CoreAnalysis {
  const _$CoreAnalysisImpl(
      {final List<Competency> competencies = const [],
      @JsonKey(name: 'interest_layers') this.interestLayers})
      : _competencies = competencies;

  factory _$CoreAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoreAnalysisImplFromJson(json);

  final List<Competency> _competencies;
  @override
  @JsonKey()
  List<Competency> get competencies {
    if (_competencies is EqualUnmodifiableListView) return _competencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_competencies);
  }

  @override
  @JsonKey(name: 'interest_layers')
  final InterestLayers? interestLayers;

  @override
  String toString() {
    return 'CoreAnalysis(competencies: $competencies, interestLayers: $interestLayers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoreAnalysisImpl &&
            const DeepCollectionEquality()
                .equals(other._competencies, _competencies) &&
            (identical(other.interestLayers, interestLayers) ||
                other.interestLayers == interestLayers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_competencies), interestLayers);

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoreAnalysisImplCopyWith<_$CoreAnalysisImpl> get copyWith =>
      __$$CoreAnalysisImplCopyWithImpl<_$CoreAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoreAnalysisImplToJson(
      this,
    );
  }
}

abstract class _CoreAnalysis implements CoreAnalysis {
  const factory _CoreAnalysis(
      {final List<Competency> competencies,
      @JsonKey(name: 'interest_layers')
      final InterestLayers? interestLayers}) = _$CoreAnalysisImpl;

  factory _CoreAnalysis.fromJson(Map<String, dynamic> json) =
      _$CoreAnalysisImpl.fromJson;

  @override
  List<Competency> get competencies;
  @override
  @JsonKey(name: 'interest_layers')
  InterestLayers? get interestLayers;

  /// Create a copy of CoreAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoreAnalysisImplCopyWith<_$CoreAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Competency _$CompetencyFromJson(Map<String, dynamic> json) {
  return _Competency.fromJson(json);
}

/// @nodoc
mixin _$Competency {
  String get name => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  List<String> get validation => throw _privateConstructorUsedError;

  /// Serializes this Competency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompetencyCopyWith<Competency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetencyCopyWith<$Res> {
  factory $CompetencyCopyWith(
          Competency value, $Res Function(Competency) then) =
      _$CompetencyCopyWithImpl<$Res, Competency>;
  @useResult
  $Res call({String name, String level, List<String> validation});
}

/// @nodoc
class _$CompetencyCopyWithImpl<$Res, $Val extends Competency>
    implements $CompetencyCopyWith<$Res> {
  _$CompetencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? level = null,
    Object? validation = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      validation: null == validation
          ? _value.validation
          : validation // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompetencyImplCopyWith<$Res>
    implements $CompetencyCopyWith<$Res> {
  factory _$$CompetencyImplCopyWith(
          _$CompetencyImpl value, $Res Function(_$CompetencyImpl) then) =
      __$$CompetencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String level, List<String> validation});
}

/// @nodoc
class __$$CompetencyImplCopyWithImpl<$Res>
    extends _$CompetencyCopyWithImpl<$Res, _$CompetencyImpl>
    implements _$$CompetencyImplCopyWith<$Res> {
  __$$CompetencyImplCopyWithImpl(
      _$CompetencyImpl _value, $Res Function(_$CompetencyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? level = null,
    Object? validation = null,
  }) {
    return _then(_$CompetencyImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      validation: null == validation
          ? _value._validation
          : validation // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetencyImpl implements _Competency {
  const _$CompetencyImpl(
      {required this.name,
      required this.level,
      final List<String> validation = const []})
      : _validation = validation;

  factory _$CompetencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetencyImplFromJson(json);

  @override
  final String name;
  @override
  final String level;
  final List<String> _validation;
  @override
  @JsonKey()
  List<String> get validation {
    if (_validation is EqualUnmodifiableListView) return _validation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_validation);
  }

  @override
  String toString() {
    return 'Competency(name: $name, level: $level, validation: $validation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetencyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._validation, _validation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, level,
      const DeepCollectionEquality().hash(_validation));

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetencyImplCopyWith<_$CompetencyImpl> get copyWith =>
      __$$CompetencyImplCopyWithImpl<_$CompetencyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetencyImplToJson(
      this,
    );
  }
}

abstract class _Competency implements Competency {
  const factory _Competency(
      {required final String name,
      required final String level,
      final List<String> validation}) = _$CompetencyImpl;

  factory _Competency.fromJson(Map<String, dynamic> json) =
      _$CompetencyImpl.fromJson;

  @override
  String get name;
  @override
  String get level;
  @override
  List<String> get validation;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompetencyImplCopyWith<_$CompetencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InterestLayers _$InterestLayersFromJson(Map<String, dynamic> json) {
  return _InterestLayers.fromJson(json);
}

/// @nodoc
mixin _$InterestLayers {
  List<String> get explicit => throw _privateConstructorUsedError;
  List<String> get implicit => throw _privateConstructorUsedError;

  /// Serializes this InterestLayers to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InterestLayers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InterestLayersCopyWith<InterestLayers> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InterestLayersCopyWith<$Res> {
  factory $InterestLayersCopyWith(
          InterestLayers value, $Res Function(InterestLayers) then) =
      _$InterestLayersCopyWithImpl<$Res, InterestLayers>;
  @useResult
  $Res call({List<String> explicit, List<String> implicit});
}

/// @nodoc
class _$InterestLayersCopyWithImpl<$Res, $Val extends InterestLayers>
    implements $InterestLayersCopyWith<$Res> {
  _$InterestLayersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InterestLayers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? explicit = null,
    Object? implicit = null,
  }) {
    return _then(_value.copyWith(
      explicit: null == explicit
          ? _value.explicit
          : explicit // ignore: cast_nullable_to_non_nullable
              as List<String>,
      implicit: null == implicit
          ? _value.implicit
          : implicit // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InterestLayersImplCopyWith<$Res>
    implements $InterestLayersCopyWith<$Res> {
  factory _$$InterestLayersImplCopyWith(_$InterestLayersImpl value,
          $Res Function(_$InterestLayersImpl) then) =
      __$$InterestLayersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> explicit, List<String> implicit});
}

/// @nodoc
class __$$InterestLayersImplCopyWithImpl<$Res>
    extends _$InterestLayersCopyWithImpl<$Res, _$InterestLayersImpl>
    implements _$$InterestLayersImplCopyWith<$Res> {
  __$$InterestLayersImplCopyWithImpl(
      _$InterestLayersImpl _value, $Res Function(_$InterestLayersImpl) _then)
      : super(_value, _then);

  /// Create a copy of InterestLayers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? explicit = null,
    Object? implicit = null,
  }) {
    return _then(_$InterestLayersImpl(
      explicit: null == explicit
          ? _value._explicit
          : explicit // ignore: cast_nullable_to_non_nullable
              as List<String>,
      implicit: null == implicit
          ? _value._implicit
          : implicit // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InterestLayersImpl implements _InterestLayers {
  const _$InterestLayersImpl(
      {final List<String> explicit = const [],
      final List<String> implicit = const []})
      : _explicit = explicit,
        _implicit = implicit;

  factory _$InterestLayersImpl.fromJson(Map<String, dynamic> json) =>
      _$$InterestLayersImplFromJson(json);

  final List<String> _explicit;
  @override
  @JsonKey()
  List<String> get explicit {
    if (_explicit is EqualUnmodifiableListView) return _explicit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_explicit);
  }

  final List<String> _implicit;
  @override
  @JsonKey()
  List<String> get implicit {
    if (_implicit is EqualUnmodifiableListView) return _implicit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_implicit);
  }

  @override
  String toString() {
    return 'InterestLayers(explicit: $explicit, implicit: $implicit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InterestLayersImpl &&
            const DeepCollectionEquality().equals(other._explicit, _explicit) &&
            const DeepCollectionEquality().equals(other._implicit, _implicit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_explicit),
      const DeepCollectionEquality().hash(_implicit));

  /// Create a copy of InterestLayers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InterestLayersImplCopyWith<_$InterestLayersImpl> get copyWith =>
      __$$InterestLayersImplCopyWithImpl<_$InterestLayersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InterestLayersImplToJson(
      this,
    );
  }
}

abstract class _InterestLayers implements InterestLayers {
  const factory _InterestLayers(
      {final List<String> explicit,
      final List<String> implicit}) = _$InterestLayersImpl;

  factory _InterestLayers.fromJson(Map<String, dynamic> json) =
      _$InterestLayersImpl.fromJson;

  @override
  List<String> get explicit;
  @override
  List<String> get implicit;

  /// Create a copy of InterestLayers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InterestLayersImplCopyWith<_$InterestLayersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BehavioralProfile _$BehavioralProfileFromJson(Map<String, dynamic> json) {
  return _BehavioralProfile.fromJson(json);
}

/// @nodoc
mixin _$BehavioralProfile {
  List<Hobby> get hobbies => throw _privateConstructorUsedError;
  Personality get personality => throw _privateConstructorUsedError;

  /// Serializes this BehavioralProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BehavioralProfileCopyWith<BehavioralProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BehavioralProfileCopyWith<$Res> {
  factory $BehavioralProfileCopyWith(
          BehavioralProfile value, $Res Function(BehavioralProfile) then) =
      _$BehavioralProfileCopyWithImpl<$Res, BehavioralProfile>;
  @useResult
  $Res call({List<Hobby> hobbies, Personality personality});

  $PersonalityCopyWith<$Res> get personality;
}

/// @nodoc
class _$BehavioralProfileCopyWithImpl<$Res, $Val extends BehavioralProfile>
    implements $BehavioralProfileCopyWith<$Res> {
  _$BehavioralProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbies = null,
    Object? personality = null,
  }) {
    return _then(_value.copyWith(
      hobbies: null == hobbies
          ? _value.hobbies
          : hobbies // ignore: cast_nullable_to_non_nullable
              as List<Hobby>,
      personality: null == personality
          ? _value.personality
          : personality // ignore: cast_nullable_to_non_nullable
              as Personality,
    ) as $Val);
  }

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonalityCopyWith<$Res> get personality {
    return $PersonalityCopyWith<$Res>(_value.personality, (value) {
      return _then(_value.copyWith(personality: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BehavioralProfileImplCopyWith<$Res>
    implements $BehavioralProfileCopyWith<$Res> {
  factory _$$BehavioralProfileImplCopyWith(_$BehavioralProfileImpl value,
          $Res Function(_$BehavioralProfileImpl) then) =
      __$$BehavioralProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Hobby> hobbies, Personality personality});

  @override
  $PersonalityCopyWith<$Res> get personality;
}

/// @nodoc
class __$$BehavioralProfileImplCopyWithImpl<$Res>
    extends _$BehavioralProfileCopyWithImpl<$Res, _$BehavioralProfileImpl>
    implements _$$BehavioralProfileImplCopyWith<$Res> {
  __$$BehavioralProfileImplCopyWithImpl(_$BehavioralProfileImpl _value,
      $Res Function(_$BehavioralProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbies = null,
    Object? personality = null,
  }) {
    return _then(_$BehavioralProfileImpl(
      hobbies: null == hobbies
          ? _value._hobbies
          : hobbies // ignore: cast_nullable_to_non_nullable
              as List<Hobby>,
      personality: null == personality
          ? _value.personality
          : personality // ignore: cast_nullable_to_non_nullable
              as Personality,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BehavioralProfileImpl implements _BehavioralProfile {
  const _$BehavioralProfileImpl(
      {final List<Hobby> hobbies = const [], required this.personality})
      : _hobbies = hobbies;

  factory _$BehavioralProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$BehavioralProfileImplFromJson(json);

  final List<Hobby> _hobbies;
  @override
  @JsonKey()
  List<Hobby> get hobbies {
    if (_hobbies is EqualUnmodifiableListView) return _hobbies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hobbies);
  }

  @override
  final Personality personality;

  @override
  String toString() {
    return 'BehavioralProfile(hobbies: $hobbies, personality: $personality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BehavioralProfileImpl &&
            const DeepCollectionEquality().equals(other._hobbies, _hobbies) &&
            (identical(other.personality, personality) ||
                other.personality == personality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_hobbies), personality);

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BehavioralProfileImplCopyWith<_$BehavioralProfileImpl> get copyWith =>
      __$$BehavioralProfileImplCopyWithImpl<_$BehavioralProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BehavioralProfileImplToJson(
      this,
    );
  }
}

abstract class _BehavioralProfile implements BehavioralProfile {
  const factory _BehavioralProfile(
      {final List<Hobby> hobbies,
      required final Personality personality}) = _$BehavioralProfileImpl;

  factory _BehavioralProfile.fromJson(Map<String, dynamic> json) =
      _$BehavioralProfileImpl.fromJson;

  @override
  List<Hobby> get hobbies;
  @override
  Personality get personality;

  /// Create a copy of BehavioralProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BehavioralProfileImplCopyWith<_$BehavioralProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Hobby _$HobbyFromJson(Map<String, dynamic> json) {
  return _Hobby.fromJson(json);
}

/// @nodoc
mixin _$Hobby {
  String get name => throw _privateConstructorUsedError;
  Engagement get engagement => throw _privateConstructorUsedError;

  /// Serializes this Hobby to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HobbyCopyWith<Hobby> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HobbyCopyWith<$Res> {
  factory $HobbyCopyWith(Hobby value, $Res Function(Hobby) then) =
      _$HobbyCopyWithImpl<$Res, Hobby>;
  @useResult
  $Res call({String name, Engagement engagement});

  $EngagementCopyWith<$Res> get engagement;
}

/// @nodoc
class _$HobbyCopyWithImpl<$Res, $Val extends Hobby>
    implements $HobbyCopyWith<$Res> {
  _$HobbyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? engagement = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      engagement: null == engagement
          ? _value.engagement
          : engagement // ignore: cast_nullable_to_non_nullable
              as Engagement,
    ) as $Val);
  }

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EngagementCopyWith<$Res> get engagement {
    return $EngagementCopyWith<$Res>(_value.engagement, (value) {
      return _then(_value.copyWith(engagement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HobbyImplCopyWith<$Res> implements $HobbyCopyWith<$Res> {
  factory _$$HobbyImplCopyWith(
          _$HobbyImpl value, $Res Function(_$HobbyImpl) then) =
      __$$HobbyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Engagement engagement});

  @override
  $EngagementCopyWith<$Res> get engagement;
}

/// @nodoc
class __$$HobbyImplCopyWithImpl<$Res>
    extends _$HobbyCopyWithImpl<$Res, _$HobbyImpl>
    implements _$$HobbyImplCopyWith<$Res> {
  __$$HobbyImplCopyWithImpl(
      _$HobbyImpl _value, $Res Function(_$HobbyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? engagement = null,
  }) {
    return _then(_$HobbyImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      engagement: null == engagement
          ? _value.engagement
          : engagement // ignore: cast_nullable_to_non_nullable
              as Engagement,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HobbyImpl implements _Hobby {
  const _$HobbyImpl({required this.name, required this.engagement});

  factory _$HobbyImpl.fromJson(Map<String, dynamic> json) =>
      _$$HobbyImplFromJson(json);

  @override
  final String name;
  @override
  final Engagement engagement;

  @override
  String toString() {
    return 'Hobby(name: $name, engagement: $engagement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HobbyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.engagement, engagement) ||
                other.engagement == engagement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, engagement);

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HobbyImplCopyWith<_$HobbyImpl> get copyWith =>
      __$$HobbyImplCopyWithImpl<_$HobbyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HobbyImplToJson(
      this,
    );
  }
}

abstract class _Hobby implements Hobby {
  const factory _Hobby(
      {required final String name,
      required final Engagement engagement}) = _$HobbyImpl;

  factory _Hobby.fromJson(Map<String, dynamic> json) = _$HobbyImpl.fromJson;

  @override
  String get name;
  @override
  Engagement get engagement;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HobbyImplCopyWith<_$HobbyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Engagement _$EngagementFromJson(Map<String, dynamic> json) {
  return _Engagement.fromJson(json);
}

/// @nodoc
mixin _$Engagement {
  @JsonKey(name: 'frequency')
  String? get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'social_impact')
  String? get socialImpact => throw _privateConstructorUsedError;

  /// Serializes this Engagement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Engagement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EngagementCopyWith<Engagement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngagementCopyWith<$Res> {
  factory $EngagementCopyWith(
          Engagement value, $Res Function(Engagement) then) =
      _$EngagementCopyWithImpl<$Res, Engagement>;
  @useResult
  $Res call(
      {@JsonKey(name: 'frequency') String? frequency,
      @JsonKey(name: 'social_impact') String? socialImpact});
}

/// @nodoc
class _$EngagementCopyWithImpl<$Res, $Val extends Engagement>
    implements $EngagementCopyWith<$Res> {
  _$EngagementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Engagement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = freezed,
    Object? socialImpact = freezed,
  }) {
    return _then(_value.copyWith(
      frequency: freezed == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String?,
      socialImpact: freezed == socialImpact
          ? _value.socialImpact
          : socialImpact // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EngagementImplCopyWith<$Res>
    implements $EngagementCopyWith<$Res> {
  factory _$$EngagementImplCopyWith(
          _$EngagementImpl value, $Res Function(_$EngagementImpl) then) =
      __$$EngagementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'frequency') String? frequency,
      @JsonKey(name: 'social_impact') String? socialImpact});
}

/// @nodoc
class __$$EngagementImplCopyWithImpl<$Res>
    extends _$EngagementCopyWithImpl<$Res, _$EngagementImpl>
    implements _$$EngagementImplCopyWith<$Res> {
  __$$EngagementImplCopyWithImpl(
      _$EngagementImpl _value, $Res Function(_$EngagementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Engagement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = freezed,
    Object? socialImpact = freezed,
  }) {
    return _then(_$EngagementImpl(
      frequency: freezed == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String?,
      socialImpact: freezed == socialImpact
          ? _value.socialImpact
          : socialImpact // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EngagementImpl implements _Engagement {
  const _$EngagementImpl(
      {@JsonKey(name: 'frequency') this.frequency,
      @JsonKey(name: 'social_impact') this.socialImpact});

  factory _$EngagementImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngagementImplFromJson(json);

  @override
  @JsonKey(name: 'frequency')
  final String? frequency;
  @override
  @JsonKey(name: 'social_impact')
  final String? socialImpact;

  @override
  String toString() {
    return 'Engagement(frequency: $frequency, socialImpact: $socialImpact)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngagementImpl &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.socialImpact, socialImpact) ||
                other.socialImpact == socialImpact));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, frequency, socialImpact);

  /// Create a copy of Engagement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EngagementImplCopyWith<_$EngagementImpl> get copyWith =>
      __$$EngagementImplCopyWithImpl<_$EngagementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngagementImplToJson(
      this,
    );
  }
}

abstract class _Engagement implements Engagement {
  const factory _Engagement(
          {@JsonKey(name: 'frequency') final String? frequency,
          @JsonKey(name: 'social_impact') final String? socialImpact}) =
      _$EngagementImpl;

  factory _Engagement.fromJson(Map<String, dynamic> json) =
      _$EngagementImpl.fromJson;

  @override
  @JsonKey(name: 'frequency')
  String? get frequency;
  @override
  @JsonKey(name: 'social_impact')
  String? get socialImpact;

  /// Create a copy of Engagement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EngagementImplCopyWith<_$EngagementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Personality _$PersonalityFromJson(Map<String, dynamic> json) {
  return _Personality.fromJson(json);
}

/// @nodoc
mixin _$Personality {
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get conflicts => throw _privateConstructorUsedError;

  /// Serializes this Personality to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Personality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalityCopyWith<Personality> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalityCopyWith<$Res> {
  factory $PersonalityCopyWith(
          Personality value, $Res Function(Personality) then) =
      _$PersonalityCopyWithImpl<$Res, Personality>;
  @useResult
  $Res call({List<String> strengths, List<String> conflicts});
}

/// @nodoc
class _$PersonalityCopyWithImpl<$Res, $Val extends Personality>
    implements $PersonalityCopyWith<$Res> {
  _$PersonalityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Personality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strengths = null,
    Object? conflicts = null,
  }) {
    return _then(_value.copyWith(
      strengths: null == strengths
          ? _value.strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conflicts: null == conflicts
          ? _value.conflicts
          : conflicts // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalityImplCopyWith<$Res>
    implements $PersonalityCopyWith<$Res> {
  factory _$$PersonalityImplCopyWith(
          _$PersonalityImpl value, $Res Function(_$PersonalityImpl) then) =
      __$$PersonalityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> strengths, List<String> conflicts});
}

/// @nodoc
class __$$PersonalityImplCopyWithImpl<$Res>
    extends _$PersonalityCopyWithImpl<$Res, _$PersonalityImpl>
    implements _$$PersonalityImplCopyWith<$Res> {
  __$$PersonalityImplCopyWithImpl(
      _$PersonalityImpl _value, $Res Function(_$PersonalityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Personality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? strengths = null,
    Object? conflicts = null,
  }) {
    return _then(_$PersonalityImpl(
      strengths: null == strengths
          ? _value._strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conflicts: null == conflicts
          ? _value._conflicts
          : conflicts // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalityImpl implements _Personality {
  const _$PersonalityImpl(
      {final List<String> strengths = const [],
      final List<String> conflicts = const []})
      : _strengths = strengths,
        _conflicts = conflicts;

  factory _$PersonalityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalityImplFromJson(json);

  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _conflicts;
  @override
  @JsonKey()
  List<String> get conflicts {
    if (_conflicts is EqualUnmodifiableListView) return _conflicts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conflicts);
  }

  @override
  String toString() {
    return 'Personality(strengths: $strengths, conflicts: $conflicts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalityImpl &&
            const DeepCollectionEquality()
                .equals(other._strengths, _strengths) &&
            const DeepCollectionEquality()
                .equals(other._conflicts, _conflicts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_strengths),
      const DeepCollectionEquality().hash(_conflicts));

  /// Create a copy of Personality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalityImplCopyWith<_$PersonalityImpl> get copyWith =>
      __$$PersonalityImplCopyWithImpl<_$PersonalityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalityImplToJson(
      this,
    );
  }
}

abstract class _Personality implements Personality {
  const factory _Personality(
      {final List<String> strengths,
      final List<String> conflicts}) = _$PersonalityImpl;

  factory _Personality.fromJson(Map<String, dynamic> json) =
      _$PersonalityImpl.fromJson;

  @override
  List<String> get strengths;
  @override
  List<String> get conflicts;

  /// Create a copy of Personality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalityImplCopyWith<_$PersonalityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
