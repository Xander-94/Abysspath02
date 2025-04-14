// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Survey _$SurveyFromJson(Map<String, dynamic> json) {
  return _Survey.fromJson(json);
}

/// @nodoc
mixin _$Survey {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<Question> get questions => throw _privateConstructorUsedError;
  List<ResponseDetail> get previousAnswers =>
      throw _privateConstructorUsedError;

  /// Serializes this Survey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Survey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurveyCopyWith<Survey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurveyCopyWith<$Res> {
  factory $SurveyCopyWith(Survey value, $Res Function(Survey) then) =
      _$SurveyCopyWithImpl<$Res, Survey>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      List<Question> questions,
      List<ResponseDetail> previousAnswers});
}

/// @nodoc
class _$SurveyCopyWithImpl<$Res, $Val extends Survey>
    implements $SurveyCopyWith<$Res> {
  _$SurveyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Survey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? questions = null,
    Object? previousAnswers = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<Question>,
      previousAnswers: null == previousAnswers
          ? _value.previousAnswers
          : previousAnswers // ignore: cast_nullable_to_non_nullable
              as List<ResponseDetail>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SurveyImplCopyWith<$Res> implements $SurveyCopyWith<$Res> {
  factory _$$SurveyImplCopyWith(
          _$SurveyImpl value, $Res Function(_$SurveyImpl) then) =
      __$$SurveyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      List<Question> questions,
      List<ResponseDetail> previousAnswers});
}

/// @nodoc
class __$$SurveyImplCopyWithImpl<$Res>
    extends _$SurveyCopyWithImpl<$Res, _$SurveyImpl>
    implements _$$SurveyImplCopyWith<$Res> {
  __$$SurveyImplCopyWithImpl(
      _$SurveyImpl _value, $Res Function(_$SurveyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Survey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? questions = null,
    Object? previousAnswers = null,
  }) {
    return _then(_$SurveyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<Question>,
      previousAnswers: null == previousAnswers
          ? _value._previousAnswers
          : previousAnswers // ignore: cast_nullable_to_non_nullable
              as List<ResponseDetail>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SurveyImpl implements _Survey {
  const _$SurveyImpl(
      {required this.id,
      required this.title,
      this.description,
      required final List<Question> questions,
      final List<ResponseDetail> previousAnswers = const []})
      : _questions = questions,
        _previousAnswers = previousAnswers;

  factory _$SurveyImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurveyImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  final List<Question> _questions;
  @override
  List<Question> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  final List<ResponseDetail> _previousAnswers;
  @override
  @JsonKey()
  List<ResponseDetail> get previousAnswers {
    if (_previousAnswers is EqualUnmodifiableListView) return _previousAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_previousAnswers);
  }

  @override
  String toString() {
    return 'Survey(id: $id, title: $title, description: $description, questions: $questions, previousAnswers: $previousAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurveyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality()
                .equals(other._previousAnswers, _previousAnswers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_previousAnswers));

  /// Create a copy of Survey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurveyImplCopyWith<_$SurveyImpl> get copyWith =>
      __$$SurveyImplCopyWithImpl<_$SurveyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SurveyImplToJson(
      this,
    );
  }
}

abstract class _Survey implements Survey {
  const factory _Survey(
      {required final String id,
      required final String title,
      final String? description,
      required final List<Question> questions,
      final List<ResponseDetail> previousAnswers}) = _$SurveyImpl;

  factory _Survey.fromJson(Map<String, dynamic> json) = _$SurveyImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  List<Question> get questions;
  @override
  List<ResponseDetail> get previousAnswers;

  /// Create a copy of Survey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurveyImplCopyWith<_$SurveyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  String get id => throw _privateConstructorUsedError;
  String get surveyId => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get questionType => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  int get questionOrder => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  int? get maxChoices => throw _privateConstructorUsedError;
  List<Option> get options => throw _privateConstructorUsedError;

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call(
      {String id,
      String surveyId,
      String section,
      String questionType,
      String questionText,
      int questionOrder,
      bool isRequired,
      int? maxChoices,
      List<Option> options});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surveyId = null,
    Object? section = null,
    Object? questionType = null,
    Object? questionText = null,
    Object? questionOrder = null,
    Object? isRequired = null,
    Object? maxChoices = freezed,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      surveyId: null == surveyId
          ? _value.surveyId
          : surveyId // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      questionType: null == questionType
          ? _value.questionType
          : questionType // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      questionOrder: null == questionOrder
          ? _value.questionOrder
          : questionOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      maxChoices: freezed == maxChoices
          ? _value.maxChoices
          : maxChoices // ignore: cast_nullable_to_non_nullable
              as int?,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<Option>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
          _$QuestionImpl value, $Res Function(_$QuestionImpl) then) =
      __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String surveyId,
      String section,
      String questionType,
      String questionText,
      int questionOrder,
      bool isRequired,
      int? maxChoices,
      List<Option> options});
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
      _$QuestionImpl _value, $Res Function(_$QuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surveyId = null,
    Object? section = null,
    Object? questionType = null,
    Object? questionText = null,
    Object? questionOrder = null,
    Object? isRequired = null,
    Object? maxChoices = freezed,
    Object? options = null,
  }) {
    return _then(_$QuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      surveyId: null == surveyId
          ? _value.surveyId
          : surveyId // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      questionType: null == questionType
          ? _value.questionType
          : questionType // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      questionOrder: null == questionOrder
          ? _value.questionOrder
          : questionOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      maxChoices: freezed == maxChoices
          ? _value.maxChoices
          : maxChoices // ignore: cast_nullable_to_non_nullable
              as int?,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<Option>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionImpl implements _Question {
  const _$QuestionImpl(
      {required this.id,
      required this.surveyId,
      required this.section,
      required this.questionType,
      required this.questionText,
      required this.questionOrder,
      required this.isRequired,
      this.maxChoices,
      required final List<Option> options})
      : _options = options;

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String surveyId;
  @override
  final String section;
  @override
  final String questionType;
  @override
  final String questionText;
  @override
  final int questionOrder;
  @override
  final bool isRequired;
  @override
  final int? maxChoices;
  final List<Option> _options;
  @override
  List<Option> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'Question(id: $id, surveyId: $surveyId, section: $section, questionType: $questionType, questionText: $questionText, questionOrder: $questionOrder, isRequired: $isRequired, maxChoices: $maxChoices, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.surveyId, surveyId) ||
                other.surveyId == surveyId) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionOrder, questionOrder) ||
                other.questionOrder == questionOrder) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.maxChoices, maxChoices) ||
                other.maxChoices == maxChoices) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      surveyId,
      section,
      questionType,
      questionText,
      questionOrder,
      isRequired,
      maxChoices,
      const DeepCollectionEquality().hash(_options));

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(
      this,
    );
  }
}

abstract class _Question implements Question {
  const factory _Question(
      {required final String id,
      required final String surveyId,
      required final String section,
      required final String questionType,
      required final String questionText,
      required final int questionOrder,
      required final bool isRequired,
      final int? maxChoices,
      required final List<Option> options}) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get surveyId;
  @override
  String get section;
  @override
  String get questionType;
  @override
  String get questionText;
  @override
  int get questionOrder;
  @override
  bool get isRequired;
  @override
  int? get maxChoices;
  @override
  List<Option> get options;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Option _$OptionFromJson(Map<String, dynamic> json) {
  return _Option.fromJson(json);
}

/// @nodoc
mixin _$Option {
  String get id => throw _privateConstructorUsedError;
  String get questionId => throw _privateConstructorUsedError;
  String get optionText => throw _privateConstructorUsedError;
  String get optionValue => throw _privateConstructorUsedError;
  int get optionOrder => throw _privateConstructorUsedError;

  /// Serializes this Option to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptionCopyWith<Option> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionCopyWith<$Res> {
  factory $OptionCopyWith(Option value, $Res Function(Option) then) =
      _$OptionCopyWithImpl<$Res, Option>;
  @useResult
  $Res call(
      {String id,
      String questionId,
      String optionText,
      String optionValue,
      int optionOrder});
}

/// @nodoc
class _$OptionCopyWithImpl<$Res, $Val extends Option>
    implements $OptionCopyWith<$Res> {
  _$OptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? optionText = null,
    Object? optionValue = null,
    Object? optionOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      optionText: null == optionText
          ? _value.optionText
          : optionText // ignore: cast_nullable_to_non_nullable
              as String,
      optionValue: null == optionValue
          ? _value.optionValue
          : optionValue // ignore: cast_nullable_to_non_nullable
              as String,
      optionOrder: null == optionOrder
          ? _value.optionOrder
          : optionOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OptionImplCopyWith<$Res> implements $OptionCopyWith<$Res> {
  factory _$$OptionImplCopyWith(
          _$OptionImpl value, $Res Function(_$OptionImpl) then) =
      __$$OptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String questionId,
      String optionText,
      String optionValue,
      int optionOrder});
}

/// @nodoc
class __$$OptionImplCopyWithImpl<$Res>
    extends _$OptionCopyWithImpl<$Res, _$OptionImpl>
    implements _$$OptionImplCopyWith<$Res> {
  __$$OptionImplCopyWithImpl(
      _$OptionImpl _value, $Res Function(_$OptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? optionText = null,
    Object? optionValue = null,
    Object? optionOrder = null,
  }) {
    return _then(_$OptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      optionText: null == optionText
          ? _value.optionText
          : optionText // ignore: cast_nullable_to_non_nullable
              as String,
      optionValue: null == optionValue
          ? _value.optionValue
          : optionValue // ignore: cast_nullable_to_non_nullable
              as String,
      optionOrder: null == optionOrder
          ? _value.optionOrder
          : optionOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OptionImpl implements _Option {
  const _$OptionImpl(
      {required this.id,
      required this.questionId,
      required this.optionText,
      required this.optionValue,
      required this.optionOrder});

  factory _$OptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionImplFromJson(json);

  @override
  final String id;
  @override
  final String questionId;
  @override
  final String optionText;
  @override
  final String optionValue;
  @override
  final int optionOrder;

  @override
  String toString() {
    return 'Option(id: $id, questionId: $questionId, optionText: $optionText, optionValue: $optionValue, optionOrder: $optionOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.optionText, optionText) ||
                other.optionText == optionText) &&
            (identical(other.optionValue, optionValue) ||
                other.optionValue == optionValue) &&
            (identical(other.optionOrder, optionOrder) ||
                other.optionOrder == optionOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, questionId, optionText, optionValue, optionOrder);

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionImplCopyWith<_$OptionImpl> get copyWith =>
      __$$OptionImplCopyWithImpl<_$OptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionImplToJson(
      this,
    );
  }
}

abstract class _Option implements Option {
  const factory _Option(
      {required final String id,
      required final String questionId,
      required final String optionText,
      required final String optionValue,
      required final int optionOrder}) = _$OptionImpl;

  factory _Option.fromJson(Map<String, dynamic> json) = _$OptionImpl.fromJson;

  @override
  String get id;
  @override
  String get questionId;
  @override
  String get optionText;
  @override
  String get optionValue;
  @override
  int get optionOrder;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptionImplCopyWith<_$OptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SurveyResponse _$SurveyResponseFromJson(Map<String, dynamic> json) {
  return _SurveyResponse.fromJson(json);
}

/// @nodoc
mixin _$SurveyResponse {
  String get id => throw _privateConstructorUsedError;
  String get surveyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  List<ResponseDetail> get details => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this SurveyResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurveyResponseCopyWith<SurveyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurveyResponseCopyWith<$Res> {
  factory $SurveyResponseCopyWith(
          SurveyResponse value, $Res Function(SurveyResponse) then) =
      _$SurveyResponseCopyWithImpl<$Res, SurveyResponse>;
  @useResult
  $Res call(
      {String id,
      String surveyId,
      String userId,
      List<ResponseDetail> details,
      DateTime? completedAt});
}

/// @nodoc
class _$SurveyResponseCopyWithImpl<$Res, $Val extends SurveyResponse>
    implements $SurveyResponseCopyWith<$Res> {
  _$SurveyResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surveyId = null,
    Object? userId = null,
    Object? details = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      surveyId: null == surveyId
          ? _value.surveyId
          : surveyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as List<ResponseDetail>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SurveyResponseImplCopyWith<$Res>
    implements $SurveyResponseCopyWith<$Res> {
  factory _$$SurveyResponseImplCopyWith(_$SurveyResponseImpl value,
          $Res Function(_$SurveyResponseImpl) then) =
      __$$SurveyResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String surveyId,
      String userId,
      List<ResponseDetail> details,
      DateTime? completedAt});
}

/// @nodoc
class __$$SurveyResponseImplCopyWithImpl<$Res>
    extends _$SurveyResponseCopyWithImpl<$Res, _$SurveyResponseImpl>
    implements _$$SurveyResponseImplCopyWith<$Res> {
  __$$SurveyResponseImplCopyWithImpl(
      _$SurveyResponseImpl _value, $Res Function(_$SurveyResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surveyId = null,
    Object? userId = null,
    Object? details = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$SurveyResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      surveyId: null == surveyId
          ? _value.surveyId
          : surveyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<ResponseDetail>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SurveyResponseImpl implements _SurveyResponse {
  const _$SurveyResponseImpl(
      {required this.id,
      required this.surveyId,
      required this.userId,
      required final List<ResponseDetail> details,
      this.completedAt})
      : _details = details;

  factory _$SurveyResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurveyResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String surveyId;
  @override
  final String userId;
  final List<ResponseDetail> _details;
  @override
  List<ResponseDetail> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'SurveyResponse(id: $id, surveyId: $surveyId, userId: $userId, details: $details, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurveyResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.surveyId, surveyId) ||
                other.surveyId == surveyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, surveyId, userId,
      const DeepCollectionEquality().hash(_details), completedAt);

  /// Create a copy of SurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurveyResponseImplCopyWith<_$SurveyResponseImpl> get copyWith =>
      __$$SurveyResponseImplCopyWithImpl<_$SurveyResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SurveyResponseImplToJson(
      this,
    );
  }
}

abstract class _SurveyResponse implements SurveyResponse {
  const factory _SurveyResponse(
      {required final String id,
      required final String surveyId,
      required final String userId,
      required final List<ResponseDetail> details,
      final DateTime? completedAt}) = _$SurveyResponseImpl;

  factory _SurveyResponse.fromJson(Map<String, dynamic> json) =
      _$SurveyResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get surveyId;
  @override
  String get userId;
  @override
  List<ResponseDetail> get details;
  @override
  DateTime? get completedAt;

  /// Create a copy of SurveyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurveyResponseImplCopyWith<_$SurveyResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResponseDetail _$ResponseDetailFromJson(Map<String, dynamic> json) {
  return _ResponseDetail.fromJson(json);
}

/// @nodoc
mixin _$ResponseDetail {
  String get questionId => throw _privateConstructorUsedError;
  String? get optionId => throw _privateConstructorUsedError;
  List<String>? get optionIds => throw _privateConstructorUsedError;
  String? get answerText => throw _privateConstructorUsedError;
  String? get answerValue => throw _privateConstructorUsedError;
  List<String>? get answerValues => throw _privateConstructorUsedError;

  /// Serializes this ResponseDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResponseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResponseDetailCopyWith<ResponseDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResponseDetailCopyWith<$Res> {
  factory $ResponseDetailCopyWith(
          ResponseDetail value, $Res Function(ResponseDetail) then) =
      _$ResponseDetailCopyWithImpl<$Res, ResponseDetail>;
  @useResult
  $Res call(
      {String questionId,
      String? optionId,
      List<String>? optionIds,
      String? answerText,
      String? answerValue,
      List<String>? answerValues});
}

/// @nodoc
class _$ResponseDetailCopyWithImpl<$Res, $Val extends ResponseDetail>
    implements $ResponseDetailCopyWith<$Res> {
  _$ResponseDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResponseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? optionId = freezed,
    Object? optionIds = freezed,
    Object? answerText = freezed,
    Object? answerValue = freezed,
    Object? answerValues = freezed,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      optionId: freezed == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String?,
      optionIds: freezed == optionIds
          ? _value.optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerText: freezed == answerText
          ? _value.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      answerValue: freezed == answerValue
          ? _value.answerValue
          : answerValue // ignore: cast_nullable_to_non_nullable
              as String?,
      answerValues: freezed == answerValues
          ? _value.answerValues
          : answerValues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResponseDetailImplCopyWith<$Res>
    implements $ResponseDetailCopyWith<$Res> {
  factory _$$ResponseDetailImplCopyWith(_$ResponseDetailImpl value,
          $Res Function(_$ResponseDetailImpl) then) =
      __$$ResponseDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String questionId,
      String? optionId,
      List<String>? optionIds,
      String? answerText,
      String? answerValue,
      List<String>? answerValues});
}

/// @nodoc
class __$$ResponseDetailImplCopyWithImpl<$Res>
    extends _$ResponseDetailCopyWithImpl<$Res, _$ResponseDetailImpl>
    implements _$$ResponseDetailImplCopyWith<$Res> {
  __$$ResponseDetailImplCopyWithImpl(
      _$ResponseDetailImpl _value, $Res Function(_$ResponseDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResponseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? optionId = freezed,
    Object? optionIds = freezed,
    Object? answerText = freezed,
    Object? answerValue = freezed,
    Object? answerValues = freezed,
  }) {
    return _then(_$ResponseDetailImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      optionId: freezed == optionId
          ? _value.optionId
          : optionId // ignore: cast_nullable_to_non_nullable
              as String?,
      optionIds: freezed == optionIds
          ? _value._optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerText: freezed == answerText
          ? _value.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      answerValue: freezed == answerValue
          ? _value.answerValue
          : answerValue // ignore: cast_nullable_to_non_nullable
              as String?,
      answerValues: freezed == answerValues
          ? _value._answerValues
          : answerValues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResponseDetailImpl implements _ResponseDetail {
  const _$ResponseDetailImpl(
      {required this.questionId,
      this.optionId,
      final List<String>? optionIds,
      this.answerText,
      this.answerValue,
      final List<String>? answerValues})
      : _optionIds = optionIds,
        _answerValues = answerValues;

  factory _$ResponseDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResponseDetailImplFromJson(json);

  @override
  final String questionId;
  @override
  final String? optionId;
  final List<String>? _optionIds;
  @override
  List<String>? get optionIds {
    final value = _optionIds;
    if (value == null) return null;
    if (_optionIds is EqualUnmodifiableListView) return _optionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? answerText;
  @override
  final String? answerValue;
  final List<String>? _answerValues;
  @override
  List<String>? get answerValues {
    final value = _answerValues;
    if (value == null) return null;
    if (_answerValues is EqualUnmodifiableListView) return _answerValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ResponseDetail(questionId: $questionId, optionId: $optionId, optionIds: $optionIds, answerText: $answerText, answerValue: $answerValue, answerValues: $answerValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResponseDetailImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.optionId, optionId) ||
                other.optionId == optionId) &&
            const DeepCollectionEquality()
                .equals(other._optionIds, _optionIds) &&
            (identical(other.answerText, answerText) ||
                other.answerText == answerText) &&
            (identical(other.answerValue, answerValue) ||
                other.answerValue == answerValue) &&
            const DeepCollectionEquality()
                .equals(other._answerValues, _answerValues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      optionId,
      const DeepCollectionEquality().hash(_optionIds),
      answerText,
      answerValue,
      const DeepCollectionEquality().hash(_answerValues));

  /// Create a copy of ResponseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResponseDetailImplCopyWith<_$ResponseDetailImpl> get copyWith =>
      __$$ResponseDetailImplCopyWithImpl<_$ResponseDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResponseDetailImplToJson(
      this,
    );
  }
}

abstract class _ResponseDetail implements ResponseDetail {
  const factory _ResponseDetail(
      {required final String questionId,
      final String? optionId,
      final List<String>? optionIds,
      final String? answerText,
      final String? answerValue,
      final List<String>? answerValues}) = _$ResponseDetailImpl;

  factory _ResponseDetail.fromJson(Map<String, dynamic> json) =
      _$ResponseDetailImpl.fromJson;

  @override
  String get questionId;
  @override
  String? get optionId;
  @override
  List<String>? get optionIds;
  @override
  String? get answerText;
  @override
  String? get answerValue;
  @override
  List<String>? get answerValues;

  /// Create a copy of ResponseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResponseDetailImplCopyWith<_$ResponseDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
