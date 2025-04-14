import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_models.freezed.dart';
part 'survey_models.g.dart';

@freezed
class Survey with _$Survey {
  const factory Survey({
    required String id,
    required String title,
    String? description,
    required List<Question> questions,
    @Default([]) List<ResponseDetail> previousAnswers,
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
}

@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    required String surveyId,
    required String section,
    required String questionType,
    required String questionText,
    required int questionOrder,
    required bool isRequired,
    int? maxChoices,
    required List<Option> options,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}

@freezed
class Option with _$Option {
  const factory Option({
    required String id,
    required String questionId,
    required String optionText,
    required String optionValue,
    required int optionOrder,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@freezed
class SurveyResponse with _$SurveyResponse {
  const factory SurveyResponse({
    required String id,
    required String surveyId,
    required String userId,
    required List<ResponseDetail> details,
    DateTime? completedAt,
  }) = _SurveyResponse;

  factory SurveyResponse.fromJson(Map<String, dynamic> json) => _$SurveyResponseFromJson(json);
}

@freezed
class ResponseDetail with _$ResponseDetail {
  const factory ResponseDetail({
    required String questionId,
    String? optionId,
    List<String>? optionIds,
    String? answerText,
    String? answerValue,
    List<String>? answerValues,
  }) = _ResponseDetail;

  factory ResponseDetail.fromJson(Map<String, dynamic> json) => _$ResponseDetailFromJson(json);
} 