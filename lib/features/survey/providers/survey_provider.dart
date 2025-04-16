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
      final insertTime = DateTime.now();
      await supabase
          .from('responses')
          .insert({
            'survey_id': surveyId,
            'user_id': user.id,
            'completed_at': insertTime.toIso8601String(),
          }); // 只执行插入，不立即 select

      // 单独查询刚刚插入的记录以获取 ID
      final response = await supabase
          .from('responses')
          .select('id')
          .eq('survey_id', surveyId)
          .eq('user_id', user.id)
          // .eq('completed_at', insertTime.toIso8601String()) // 可以选择加上时间戳精确匹配，但可能因精度问题不可靠
          .order('completed_at', ascending: false) // 按时间倒序
          .limit(1) // 取最新的一条
          .single(); // 确保只取到一条
          
      final responseId = response['id'];
      if (responseId == null) { // 添加额外的检查以防万一
          throw Exception('未能获取新创建的问卷响应ID');
      }

      // 创建答案明细
      await supabase.from('response_details').insert(
        details.map((detail) {
          final Map<String, dynamic> data = {
            'response_id': responseId,
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