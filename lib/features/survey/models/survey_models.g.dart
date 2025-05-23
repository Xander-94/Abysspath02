// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SurveyImpl _$$SurveyImplFromJson(Map<String, dynamic> json) => _$SurveyImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      previousAnswers: (json['previousAnswers'] as List<dynamic>?)
              ?.map((e) => ResponseDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SurveyImplToJson(_$SurveyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'questions': instance.questions,
      'previousAnswers': instance.previousAnswers,
    };

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      section: json['section'] as String,
      questionType: json['questionType'] as String,
      questionText: json['questionText'] as String,
      questionOrder: (json['questionOrder'] as num).toInt(),
      isRequired: json['isRequired'] as bool,
      maxChoices: (json['maxChoices'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surveyId': instance.surveyId,
      'section': instance.section,
      'questionType': instance.questionType,
      'questionText': instance.questionText,
      'questionOrder': instance.questionOrder,
      'isRequired': instance.isRequired,
      'maxChoices': instance.maxChoices,
      'options': instance.options,
    };

_$OptionImpl _$$OptionImplFromJson(Map<String, dynamic> json) => _$OptionImpl(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      optionText: json['optionText'] as String,
      optionValue: json['optionValue'] as String,
      optionOrder: (json['optionOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$OptionImplToJson(_$OptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'optionText': instance.optionText,
      'optionValue': instance.optionValue,
      'optionOrder': instance.optionOrder,
    };

_$SurveyResponseImpl _$$SurveyResponseImplFromJson(Map<String, dynamic> json) =>
    _$SurveyResponseImpl(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      userId: json['userId'] as String,
      details: (json['details'] as List<dynamic>)
          .map((e) => ResponseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$SurveyResponseImplToJson(
        _$SurveyResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surveyId': instance.surveyId,
      'userId': instance.userId,
      'details': instance.details,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$ResponseDetailImpl _$$ResponseDetailImplFromJson(Map<String, dynamic> json) =>
    _$ResponseDetailImpl(
      questionId: json['questionId'] as String,
      optionId: json['optionId'] as String?,
      optionIds: (json['optionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      answerText: json['answerText'] as String?,
      answerValue: json['answerValue'] as String?,
      answerValues: (json['answerValues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ResponseDetailImplToJson(
        _$ResponseDetailImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'optionId': instance.optionId,
      'optionIds': instance.optionIds,
      'answerText': instance.answerText,
      'answerValue': instance.answerValue,
      'answerValues': instance.answerValues,
    };
