import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_models.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/providers/profile_notifier.dart';

part 'survey_provider.g.dart';

@riverpod
class SurveyState extends _$SurveyState {
  bool _isSubmitting = false; // 添加实例变量用于并发控制

  @override
  Future<Survey> build(String surveyId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    // 获取问卷信息
    final survey = await supabase
        .from('surveys')
        .select()
        .eq('id', surveyId)
        .limit(1)
        .maybeSingle();
    
    if (survey == null) throw Exception('问卷不存在');
    if (survey is! Map<String, dynamic>) throw Exception('问卷数据格式无效');
    
    final id = survey['id']?.toString();
    final title = survey['title']?.toString();
    final description = survey['description']?.toString();
    
    if (id == null) throw Exception('问卷ID不能为空');
    if (title == null) throw Exception('问卷标题不能为空'); 
    if (description == null) throw Exception('问卷描述不能为空');
    
    // 获取问题列表
    final questionsData = await supabase
        .from('questions')
        .select()
        .eq('survey_id', surveyId)
        .order('question_order');
    
    if (questionsData == null) throw Exception('获取问题列表失败');
    
    // 获取所有问题的选项
    final questions = await Future.wait(
      (questionsData as List).map((question) async {
        if (question is! Map<String, dynamic>) throw Exception('问题数据格式无效');
        if (question['id'] == null) throw Exception('问题ID不能为空');
        
        final optionsData = await supabase
            .from('options')
            .select()
            .eq('question_id', question['id']!)
            .order('option_order');
            
        if (optionsData == null || optionsData is! List) throw Exception('获取选项列表失败');
            
        final qId = question['id']!.toString();
        final qSurveyId = question['survey_id']?.toString();
        final qType = question['question_type']?.toString();
        final qText = question['question_text']?.toString();
        final qOrder = question['question_order'] as int?;
        
        if (qId == null) throw Exception('问题ID不能为空');
        if (qSurveyId == null) throw Exception('问题所属问卷ID不能为空');
        if (qType == null) throw Exception('问题类型不能为空');
        if (qText == null) throw Exception('问题文本不能为空');
        if (qOrder == null) throw Exception('问题顺序不能为空');
        
        return Question(
          id: qId,
          surveyId: qSurveyId,
          section: question['section']?.toString() ?? '',
          questionType: qType,
          questionText: qText,
          questionOrder: qOrder,
          isRequired: question['is_required'] as bool? ?? false,
          maxChoices: question['max_choices'] as int?,
          options: optionsData.map((option) {
            if (option is! Map<String, dynamic>) throw Exception('选项数据格式无效');
            if (option['id'] == null) throw Exception('选项ID不能为空');
            
            final oId = option['id']!.toString();
            final oQuestionId = option['question_id']?.toString();
            final oText = option['option_text']?.toString();
            final oOrder = option['option_order'] as int?;
            
            if (oId == null) throw Exception('选项ID不能为空');
            if (oQuestionId == null) throw Exception('选项所属问题ID不能为空');
            if (oText == null) throw Exception('选项文本不能为空');
            if (oOrder == null) throw Exception('选项顺序不能为空');
            
            return Option(
              id: oId,
              questionId: oQuestionId,
              optionText: oText,
              optionValue: option['option_value']?.toString() ?? '',
              optionOrder: oOrder,
            );
          }).toList(),
        );
      }),
    );

    // 获取用户之前的答案
    List<ResponseDetail> previousAnswers = [];
    if (user != null) {
      final previousResponse = await supabase
          .from('responses')
          .select('id')
          .eq('survey_id', surveyId)
          .eq('user_id', user.id)
          .order('completed_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (previousResponse != null) {
        final answerDetails = await supabase
            .from('response_details')
            .select()
            .eq('response_id', previousResponse['id']);
        
        previousAnswers = answerDetails.map((detail) {
          // 获取对应的问题类型
          final question = questions.firstWhere(
            (q) => q.id == detail['question_id'],
            orElse: () => throw Exception('找不到对应的问题'),
          );

          switch (question.questionType) {
            case 'text':
              return ResponseDetail(
                questionId: detail['question_id'],
                answerText: detail['answer_text'],
              );
            case 'scale':
              final values = (detail['answer_values'] as List<dynamic>?)?.cast<String>();
              return ResponseDetail(
                questionId: detail['question_id'],
                answerValue: values?.firstOrNull,
              );
            case 'single_choice':
              final optionIds = (detail['option_ids'] as List<dynamic>?)?.cast<String>();
              return ResponseDetail(
                questionId: detail['question_id'],
                optionId: optionIds?.firstOrNull,
              );
            case 'multiple_choice':
              final optionIds = (detail['option_ids'] as List<dynamic>?)?.cast<String>();
              return ResponseDetail(
                questionId: detail['question_id'],
                optionIds: optionIds ?? [],
              );
            default:
              throw Exception('未知的问题类型: ${question.questionType}');
          }
        }).toList();
      }
    }
    
    return Survey(
      id: id,
      title: title,
      description: description,
      questions: questions,
      previousAnswers: previousAnswers,
    );
  }

  Future<void> submitResponse(List<ResponseDetail> details) async {
    if (_isSubmitting) {
      print('[Survey Submit Debug] Already submitting, ignoring concurrent call.');
      return;
    }
    _isSubmitting = true;
    print('[Survey Submit Debug] Started submission process.');

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('用户未登录');

      final surveyId = state.value?.id;
      if (surveyId == null) throw Exception('问卷ID不能为空');

      final previousResponse = await supabase
          .from('responses')
          .select('id')
          .eq('survey_id', surveyId)
          .eq('user_id', user.id)
          .maybeSingle();

      final ProfileService profileService = ref.read(profileServiceProvider);

      if (previousResponse != null) {
        final responseId = previousResponse['id'] as String;

        final detailsPayload = details.map((detail) {
           final List<String> answerValuesResult;
           final List<String> optionIdsResult;

           // Determine answer_values based on previous logic
           if (detail.answerValue != null) {
             answerValuesResult = [detail.answerValue!];
           } else if (detail.answerValues != null && detail.answerValues!.isNotEmpty) {
             answerValuesResult = detail.answerValues!;
           } else if (detail.optionId != null) {
              // For single choice stored in optionId, treat it as a single element list for answer_values
             answerValuesResult = [detail.optionId!]; 
           } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
             // For multiple choice stored in optionIds, use them directly for answer_values
             answerValuesResult = detail.optionIds!;
           } else {
             answerValuesResult = [];
           }

           // Determine option_ids based on previous logic
           if (detail.optionId != null) {
             optionIdsResult = [detail.optionId!];
           } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
             optionIdsResult = detail.optionIds!;
           } else {
             optionIdsResult = [];
           }

           return {
             'question_id': detail.questionId, // String UUID
             'answer_text': detail.answerText, // String or null
             // Use the determined lists directly
             'answer_values': answerValuesResult, 
             'option_ids': optionIdsResult, 
           };
         }).toList();

        print('[Survey Submit Debug] Calling RPC update_response_details for response_id: $responseId');
        await supabase.rpc(
          'update_response_details',
          params: {
            'target_response_id': responseId,
            'new_details': detailsPayload,
          },
        );
        print('[Survey Submit Debug] RPC update_response_details finished for response_id: $responseId');

        await supabase
            .from('responses')
            .update({'completed_at': DateTime.now().toIso8601String()})
            .eq('id', responseId);
        print('[Survey Submit Debug] Updated completed_at for response_id: $responseId');

        // --- END: Update profile ---

      } else {
        // ... (existing logic for first submission) ...
        final insertTime = DateTime.now();
        await supabase
            .from('responses')
            .insert({'survey_id': surveyId, 'user_id': user.id, 'completed_at': insertTime.toIso8601String()});

        final response = await supabase
            .from('responses')
            .select('id')
            .eq('survey_id', surveyId)
            .eq('user_id', user.id)
            .order('completed_at', ascending: false)
            .limit(1)
            .single();

        final responseId = response['id'] as String?; // 获取新创建的 responseId
        if (responseId == null) {
            throw Exception('未能获取新创建的问卷响应ID');
        }

        print('[Survey Submit Debug] Inserting initial details for new response_id: $responseId');
        await supabase.from('response_details').insert(
          details.map((detail) {
            // ... (existing mapping logic for initial insert) ...
             final Map<String, dynamic> data = {
              'response_id': responseId,
              'question_id': detail.questionId,
              'answer_text': detail.answerText,
            };
            // Determine answer_values based on previous logic
             final List<String> answerValuesResult;
             if (detail.answerValue != null) {
               answerValuesResult = [detail.answerValue!];
             } else if (detail.answerValues != null && detail.answerValues!.isNotEmpty) {
               answerValuesResult = detail.answerValues!;
             } else if (detail.optionId != null) {
               answerValuesResult = [detail.optionId!]; 
             } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
               answerValuesResult = detail.optionIds!;
             } else {
               answerValuesResult = [];
             }
             data['answer_values'] = answerValuesResult;

             // Determine option_ids based on previous logic
             final List<String> optionIdsResult;
             if (detail.optionId != null) {
               optionIdsResult = [detail.optionId!];
             } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
               optionIdsResult = detail.optionIds!;
             } else {
               optionIdsResult = [];
             }
             data['option_ids'] = optionIdsResult;


            return data;
          }).toList(),
        );
        print('[Survey Submit Debug] Finished inserting initial details for response_id: $responseId');

         // --- END: Update profile ---
      }
      print('[Survey Submit Debug] Submission process completed successfully.');

       // --- Get the actual responseId used (either existing or new) ---
       final finalResponseId = previousResponse?['id'] as String? ?? (await supabase
            .from('responses')
            .select('id')
            .eq('survey_id', surveyId)
            .eq('user_id', user.id)
            .order('completed_at', ascending: false)
            .limit(1)
            .single())['id'] as String?;

       if (finalResponseId != null) {
         print('[Survey Submit Debug] Triggering profile load for responseId: $finalResponseId');
         // Directly call ProfileNotifier's method to load using the specific ID
         await ref.read(profileProvider.notifier).loadProfileFromResponse(finalResponseId);

         // --- NEW STEP: Update profiles table with the latest structural data --- 
         print('[Survey Submit Debug] Attempting to update profiles table with latest structural data.');
         // Read the state AFTER loadProfileFromResponse has potentially updated it
         final currentCorrectProfileState = ref.read(profileProvider); 
         if (currentCorrectProfileState.profile != null && currentCorrectProfileState.error == null) {
             try {
                 // Get the ProfileService instance (already available via dependency)
                 // final profileService = ref.read(profileServiceProvider);
                 await profileService.updateProfile(currentCorrectProfileState.profile!); // Use the service passed in constructor or read via ref
                 print('[Survey Submit Debug] Successfully updated profiles table.');
             } catch (updateError) {
                 print('[Survey Submit Error] Failed to update profiles table: $updateError');
             }
         } else {
             print('[Survey Submit Debug] Skipping profiles table update due to invalid profile state (error: ${currentCorrectProfileState.error}).');
         }
         // --- END NEW STEP ---

       } else {
         print('[Survey Submit Error] Could not determine final responseId to trigger profile load.');
         // Fallback: invalidate in case we couldn't get the ID somehow
         ref.invalidate(profileProvider); 
       }

    } catch (e, stackTrace) {
       print('[Survey Submit Error] Submission failed: $e');
       print(stackTrace);
       rethrow; // Re-throw the error so the UI knows submission failed
    } finally {
      _isSubmitting = false;
      print('[Survey Submit Debug] Resetting isSubmitting flag.');
      ref.invalidateSelf(); // Invalidate the survey provider itself
      // --- REMOVED invalidate/refresh from finally block ---
      // await Future.delayed(const Duration(milliseconds: 500)); 
      // print('[Survey Submit Debug] Invalidating profileProvider after delay.');
      // ref.refresh(profileProvider); 
    }
  }
} 