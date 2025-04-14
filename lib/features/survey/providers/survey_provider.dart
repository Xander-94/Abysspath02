import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_models.dart';

part 'survey_provider.g.dart';

@riverpod
class SurveyState extends _$SurveyState {
  @override
  Future<Survey> build(String surveyId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    // 获取问卷信息
    final surveyData = await supabase
        .from('surveys')
        .select()
        .eq('id', surveyId)
        .single();
    
    // 获取问题列表
    final questionsData = await supabase
        .from('questions')
        .select()
        .eq('survey_id', surveyId)
        .order('question_order');
    
    // 获取所有问题的选项
    final questions = await Future.wait(
      questionsData.map((question) async {
        final optionsData = await supabase
            .from('options')
            .select()
            .eq('question_id', question['id'])
            .order('option_order');
            
        return Question(
          id: question['id'],
          surveyId: question['survey_id'],
          section: question['section'],
          questionType: question['question_type'],
          questionText: question['question_text'],
          questionOrder: question['question_order'],
          isRequired: question['is_required'],
          maxChoices: question['max_choices'],
          options: optionsData.map((option) => Option(
            id: option['id'],
            questionId: option['question_id'],
            optionText: option['option_text'],
            optionValue: option['option_value'],
            optionOrder: option['option_order'],
          )).toList(),
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
      id: surveyData['id'],
      title: surveyData['title'],
      description: surveyData['description'],
      questions: questions,
      previousAnswers: previousAnswers,
    );
  }

  Future<void> submitResponse(List<ResponseDetail> details) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');
    
    final surveyId = state.value?.id;
    if (surveyId == null) throw Exception('问卷ID不能为空');
    
    // 检查是否存在之前的回答
    final previousResponse = await supabase
        .from('responses')
        .select('id')
        .eq('survey_id', surveyId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (previousResponse != null) {
      // 如果存在之前的回答，先删除旧的答案明细
      await supabase
          .from('response_details')
          .delete()
          .eq('response_id', previousResponse['id']);
      
      // 更新完成时间
      await supabase
          .from('responses')
          .update({'completed_at': DateTime.now().toIso8601String()})
          .eq('id', previousResponse['id']);
      
      // 插入新的答案明细
      await supabase.from('response_details').insert(
        details.map((detail) {
          final Map<String, dynamic> data = {
            'response_id': previousResponse['id'],
            'question_id': detail.questionId,
            'answer_text': detail.answerText,
          };

          // 处理答案值，确保 answer_values 不为空
          if (detail.answerValue != null) {
            data['answer_values'] = [detail.answerValue];
          } else if (detail.answerValues != null && detail.answerValues!.isNotEmpty) {
            data['answer_values'] = detail.answerValues;
          } else if (detail.optionId != null) {
            data['answer_values'] = [detail.optionId];
          } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
            data['answer_values'] = detail.optionIds;
          } else {
            data['answer_values'] = [''];
          }

          // 处理选项ID
          if (detail.optionId != null) {
            data['option_ids'] = [detail.optionId];
          } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
            data['option_ids'] = detail.optionIds;
          } else {
            data['option_ids'] = [];
          }

          return data;
        }).toList(),
      );
    } else {
      // 如果是首次提交
      final response = await supabase
          .from('responses')
          .insert({
            'survey_id': surveyId,
            'user_id': user.id,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      // 创建答案明细
      await supabase.from('response_details').insert(
        details.map((detail) {
          final Map<String, dynamic> data = {
            'response_id': response['id'],
            'question_id': detail.questionId,
            'answer_text': detail.answerText,
          };

          // 处理答案值，确保 answer_values 不为空
          if (detail.answerValue != null) {
            data['answer_values'] = [detail.answerValue];
          } else if (detail.answerValues != null && detail.answerValues!.isNotEmpty) {
            data['answer_values'] = detail.answerValues;
          } else if (detail.optionId != null) {
            data['answer_values'] = [detail.optionId];
          } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
            data['answer_values'] = detail.optionIds;
          } else {
            data['answer_values'] = [''];
          }

          // 处理选项ID
          if (detail.optionId != null) {
            data['option_ids'] = [detail.optionId];
          } else if (detail.optionIds != null && detail.optionIds!.isNotEmpty) {
            data['option_ids'] = detail.optionIds;
          } else {
            data['option_ids'] = [];
          }

          return data;
        }).toList(),
      );
    }

    // 刷新状态以获取最新答案
    ref.invalidateSelf();
  }
} 