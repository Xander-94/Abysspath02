import 'package:freezed_annotation/freezed_annotation.dart';

part 'assessment_profile.freezed.dart';
part 'assessment_profile.g.dart';

@freezed
class AssessmentProfile with _$AssessmentProfile {
  const factory AssessmentProfile({
    @JsonKey(name: 'core_analysis')
    CoreAnalysis? coreAnalysis,
    @JsonKey(name: 'behavioral_profile')
    BehavioralProfile? behavioralProfile,
  }) = _AssessmentProfile;

  factory AssessmentProfile.fromJson(Map<String, dynamic> json) =>
      _$AssessmentProfileFromJson(json);
}

@freezed
class CoreAnalysis with _$CoreAnalysis {
  const factory CoreAnalysis({
    @Default([]) List<Competency> competencies,
    @JsonKey(name: 'interest_layers')
    InterestLayers? interestLayers,
  }) = _CoreAnalysis;

  factory CoreAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CoreAnalysisFromJson(json);
}

@freezed
class Competency with _$Competency {
  const factory Competency({
    required String name,
    required String level,
    @Default([]) List<String> validation,
  }) = _Competency;

  factory Competency.fromJson(Map<String, dynamic> json) =>
      _$CompetencyFromJson(json);
}

@freezed
class InterestLayers with _$InterestLayers {
  const factory InterestLayers({
    @Default([]) List<String> explicit,
    @Default([]) List<String> implicit,
  }) = _InterestLayers;

  factory InterestLayers.fromJson(Map<String, dynamic> json) =>
      _$InterestLayersFromJson(json);
}

@freezed
class BehavioralProfile with _$BehavioralProfile {
  const factory BehavioralProfile({
    @Default([]) List<Hobby> hobbies,
    required Personality personality,
  }) = _BehavioralProfile;

  factory BehavioralProfile.fromJson(Map<String, dynamic> json) =>
      _$BehavioralProfileFromJson(json);
}

@freezed
class Hobby with _$Hobby {
  const factory Hobby({
    required String name,
    required Engagement engagement,
  }) = _Hobby;

  factory Hobby.fromJson(Map<String, dynamic> json) => _$HobbyFromJson(json);
}

@freezed
class Engagement with _$Engagement {
  const factory Engagement({
    @JsonKey(name: 'frequency')
    String? frequency,
    @JsonKey(name: 'social_impact')
    String? socialImpact,
  }) = _Engagement;

  factory Engagement.fromJson(Map<String, dynamic> json) =>
      _$EngagementFromJson(json);
}

@freezed
class Personality with _$Personality {
  const factory Personality({
    @Default([]) List<String> strengths,
    @Default([]) List<String> conflicts,
  }) = _Personality;

  factory Personality.fromJson(Map<String, dynamic> json) =>
      _$PersonalityFromJson(json);
} 