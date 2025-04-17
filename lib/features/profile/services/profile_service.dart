import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/competency.dart';
import '../models/interest_graph.dart';
import '../models/behavior.dart';
import '../models/constraints.dart';
import '../models/dynamic_flags.dart';

/// 个人中心服务
class ProfileService {
  final _supabase = Supabase.instance.client;

   /// 获取用户信息及指定（或最新）问卷回复，并将问卷数据映射到 Profile 结构化字段
  Future<Profile?> getProfile({String? targetResponseId}) async { // 添加可选参数
    print('[ProfileService] getProfile started. targetResponseId: $targetResponseId');
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
         print('[ProfileService] User is null, returning null');
         return null;
      }

      // 1. 获取基础 Profile 数据
      final profileResponse = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

      if (profileResponse == null) {
        print('[ProfileService] Base profile not found, returning null');
        return null;
      }
      print('[ProfileService] Base profile fetched: ${profileResponse}');
      Profile baseProfile = Profile.fromJson(profileResponse);

      // 2. 确定要使用的 response_id
      String? responseId;
      if (targetResponseId != null) {
        // 如果提供了目标 ID，直接使用
        print('[ProfileService] Using provided targetResponseId: $targetResponseId');
        responseId = targetResponseId;
      } else {
        // 否则，查找最新的问卷 ID
        print('[ProfileService] No targetResponseId provided, finding latest response...');
        final latestResponse = await _supabase
            .from('responses')
            .select('id')
            .eq('user_id', user.id)
            .order('created_at', ascending: false) // 确保按时间降序
            .limit(1)
            .maybeSingle();
        print('[ProfileService] Latest response fetched: ${latestResponse}');
        if (latestResponse != null) {
           responseId = latestResponse['id'];
        } else {
           print('[ProfileService] No latest response found.');
        }
      }

      Map<String, String>? readableSurveyData;
      List<Map<String, dynamic>> responseDetails = [];
      // 3. 如果有 responseId（无论是传入的还是找到的），则获取问卷详情
      if (responseId != null) {
         print('[ProfileService] Fetching response details for response_id: $responseId');
         responseDetails = await _supabase
            .from('response_details')
            .select('*, questions(question_text)') // 包含问题文本
            .eq('response_id', responseId);
         print('[ProfileService] Response details fetched: ${responseDetails}');

        // 4. 查询并映射 Option 文本
        readableSurveyData = {};
        for (var detail in responseDetails) {
          final questionData = detail['questions']; // questions 表的数据现在在这里
          final questionText = questionData?['question_text'] as String? ?? '未知问题';
          String displayAnswer;

          if (detail['answer_text'] != null) {
            displayAnswer = detail['answer_text'];
          } else if (detail['answer_value'] != null) {
            displayAnswer = detail['answer_value'];
          } else if (detail['option_id'] != null) {
            // 对于单选，也可能需要查询选项文本
            final optionResponse = await _supabase.from('options').select('option_text').eq('id', detail['option_id']).maybeSingle();
            displayAnswer = optionResponse?['option_text'] ?? '选项未找到';
          } else if (detail['option_ids'] != null && detail['option_ids'] is List) {
            // 对于多选，查询每个选项的文本
            final ids = List<String>.from(detail['option_ids']);
            final optionTexts = <String>[];
            for (String id in ids) {
               final optionResponse = await _supabase.from('options').select('option_text').eq('id', id).maybeSingle();
               if (optionResponse != null) {
                 optionTexts.add(optionResponse['option_text']);
               }
            }
            displayAnswer = optionTexts.join(', ');
          } else if (detail['answer_values'] != null && detail['answer_values'] is List) {
             // 假设 answer_values 存储的是选项 ID (需要根据实际情况调整)
             // 或者如果 answer_values 直接存的是文本值，则可以直接 join
            final values = List<String>.from(detail['answer_values']);
             // 如果 answer_values 存的是 ID
            final optionTexts = <String>[];
            for (String id in values) {
               final optionResponse = await _supabase.from('options').select('option_text').eq('id', id).maybeSingle();
               if (optionResponse != null) {
                 optionTexts.add(optionResponse['option_text']);
               } else {
                 optionTexts.add('值($id)未找到对应选项'); // 或者直接用 id
               }
            }
             displayAnswer = optionTexts.join(', ');
             // 如果 answer_values 直接存的是文本值:
             // displayAnswer = values.join(', ');
          } else {
            displayAnswer = '未回答';
          }
          readableSurveyData[questionText] = displayAnswer;
        }
         print('[ProfileService] Built readableSurveyData: ${readableSurveyData}');
      } else {
        // 如果没有 responseId (无论是没提供还是没找到最新的)
        print('[ProfileService] No responseId available, skipping survey data mapping.');
        readableSurveyData = null; // 确保后面映射时知道没有数据
      }

      // 5. 将问卷数据（如果有）映射到 Profile 的结构化字段
      Competency updatedCompetency = baseProfile.competency ?? const Competency();
      InterestGraph updatedInterestGraph = baseProfile.interestGraph ?? const InterestGraph();
      Behavior updatedBehavior = baseProfile.behavior ?? const Behavior();
      Constraints updatedConstraints = baseProfile.constraints ?? const Constraints();
      DynamicFlags updatedDynamicFlags = baseProfile.dynamicFlags ?? const DynamicFlags();

      if (readableSurveyData != null) {
        // --- Competency 映射 ---
        List<String>? milestones = readableSurveyData['您希望达成的里程碑']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        List<String>? generalSkills = readableSurveyData['请选择您已掌握的通用能力']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        updatedCompetency = updatedCompetency.copyWith(targetMilestones: milestones, generalSkills: generalSkills);

        // --- InterestGraph 映射 ---
        Map<String, double> crossDomainMap = Map.from(updatedInterestGraph.crossDomainLinks ?? {});
        String? customCrossDomain = readableSurveyData['请用"领域A × 领域B"的形式描述您想探索的任意组合'];
        if (customCrossDomain != null && customCrossDomain.isNotEmpty) crossDomainMap[customCrossDomain] = 1.0;
        String? selectedCrossDomainsString = readableSurveyData['您感兴趣的跨领域组合是？'];
        if (selectedCrossDomainsString != null && selectedCrossDomainsString.isNotEmpty && selectedCrossDomainsString != '未回答') {
            List<String> selectedCrossDomainsList = selectedCrossDomainsString.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
            for (var selectedDomain in selectedCrossDomainsList) { crossDomainMap[selectedDomain] = 1.0; }
        }
        List<String>? primaryInterestsList = readableSurveyData['选择您最感兴趣的3个主领域']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        Map<String, double> primaryInterestsMap = Map.from(updatedInterestGraph.primaryInterests ?? {});
        if (primaryInterestsList != null) {
          primaryInterestsMap.clear();
          for (var interest in primaryInterestsList) { primaryInterestsMap[interest] = 1.0; }
        }
        updatedInterestGraph = updatedInterestGraph.copyWith(crossDomainLinks: crossDomainMap.isEmpty ? null : crossDomainMap, primaryInterests: primaryInterestsMap.isEmpty ? null : primaryInterestsMap);

        // --- Behavior 映射 ---
        List<String>? resources = readableSurveyData['您偏好的学习资源类型']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        List<String>? practices = readableSurveyData['您擅长的实践形式是？']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        List<String>? motivationsList = readableSurveyData['您的学习主要动机是？']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();

        const String personalityQuestionKey = '用一句话定义您的学习人格';
        String? personality = readableSurveyData[personalityQuestionKey];
        print('[ProfileService] Personality from readableSurveyData["$personalityQuestionKey"]: $personality');

        updatedBehavior = updatedBehavior.copyWith(
          preferredResourceTypes: resources,
          preferredPracticeForms: practices,
          motivations: motivationsList,
          learningPersonality: personality,
        );

        // --- Constraints 映射 ---
        List<String>? devices = readableSurveyData['您的主要学习设备是？']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        List<String>? investment = readableSurveyData['您能接受的学习投入方式']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        List<String>? times = readableSurveyData['您的最佳学习时段是？']?.split(', ').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
        updatedConstraints = updatedConstraints.copyWith(
           preferredDevices: devices,
           acceptedInvestment: investment,
           preferredLearningTimes: times
        );

        // --- DynamicFlags 映射 ---
        String? stageText;
        // 修正：从 responseDetails 获取选项文本，而不是依赖 readableSurveyData (它可能已被处理)
         if (responseDetails.any((d) => d['questions']?['question_text'] == '您当前所处阶段？')) {
             var detailEntry = responseDetails.firstWhere(
                 (d) => d['questions']?['question_text'] == '您当前所处阶段？',
                 orElse: () => <String, dynamic>{} // 返回空 Map 以防万一
             );

             if (detailEntry.isNotEmpty) { // 确保找到了对应的 detail
                 if (detailEntry['option_id'] != null) {
                     final optionResponse = await _supabase.from('options').select('option_text').eq('id', detailEntry['option_id']).maybeSingle();
                     stageText = optionResponse?['option_text'];
                 } else if (detailEntry['option_ids'] != null && detailEntry['option_ids'] is List && detailEntry['option_ids'].isNotEmpty) {
                     // 如果允许多选，取第一个或按需处理
                     final firstOptionId = detailEntry['option_ids'][0].toString();
                     final optionResponse = await _supabase.from('options').select('option_text').eq('id', firstOptionId).maybeSingle();
                     stageText = optionResponse?['option_text'];
                 } else {
                      // 如果答案在 answer_text 或 answer_value
                      stageText = detailEntry['answer_text'] ?? detailEntry['answer_value'] ?? readableSurveyData['您当前所处阶段？']; // Fallback
                 }
             }
         }

        if (stageText == '未回答' || stageText == '选项未找到') stageText = null;
        updatedDynamicFlags = updatedDynamicFlags.copyWith(currentStage: stageText);

      } else {
          print('[ProfileService] No readableSurveyData to map from.');
      }

      // 6. 构建最终 Profile
       final finalProfile = baseProfile.copyWith(
        competency: updatedCompetency,
        interestGraph: updatedInterestGraph,
        behavior: updatedBehavior,
        constraints: updatedConstraints,
        dynamicFlags: updatedDynamicFlags,
        surveyResponses: readableSurveyData, // 存储处理后的问卷数据
      );
      print('[ProfileService] Final profile to return. Learning Personality: ${finalProfile.behavior?.learningPersonality}');
      return finalProfile;

    } catch (e, stacktrace) {
      print('[ProfileService] Error getting profile: $e');
      print('[ProfileService] Stacktrace: $stacktrace');
      // 尝试返回基础 Profile
      try {
         final user = _supabase.auth.currentUser;
         if (user == null) return null;
         final profileResponse = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
         print('[ProfileService] Returning base profile due to error.');
         return profileResponse == null ? null : Profile.fromJson(profileResponse);
      } catch (profileError) {
        print('[ProfileService] Failed to get even base profile: $profileError');
        return null;
      }
    }
  }

  /// 更新用户信息 (现在会保存包含结构化映射的画像数据)
  Future<bool> updateProfile(Profile profile) async {
    try {
      if (profile.id == null) return false;
      // toJson 现在应该能序列化包含新字段的 Competency, Behavior 等对象
      // 需要确保 toJson 能正确处理所有新增字段
      final json = profile.toJson(); 
      print('[ProfileService] Updating profile with JSON: $json'); // 调试输出
      await _supabase
        .from('profiles')
        .update(json) 
        .eq('id', profile.id!);
      return true;
    } catch (e) {
      print('[ProfileService] 更新用户信息失败: $e');
      return false;
    }
  }

  /// 修改密码
  Future<bool> changePassword(String password) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      return true;
    } catch (e) {
      print('[ProfileService] 修改密码失败: $e');
      return false;
    }
  }

  /// 退出登录
  Future<bool> signOut() async {
    try {
    await _supabase.auth.signOut();
      return true;
    } catch (e) {
      print('[ProfileService] 退出登录失败: $e');
      return false;
    }
  }
} 