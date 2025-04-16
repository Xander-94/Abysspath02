import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/deepseek_service.dart';
import 'dart:convert';
import 'dart:developer';

/// 对话评估服务
class DialogueAssessmentService {
  final _supabase = Supabase.instance.client;

  /// 开始新的评估会话
  Future<Map<String, dynamic>> startAssessment() async {
    try {
      // 获取当前用户ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw '用户未登录';
      }

      final response = await _supabase.from('assessment_history').insert({
        'user_id': userId,  // 添加用户ID
        'type': 'dialogue',
        'status': 'in_progress',
        'title': '对话评估',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      print('创建新对话成功: $response');  // 添加调试日志
      return response;
    } catch (e) {
      print('开始评估失败: $e');  // 添加错误日志
      throw '开始评估失败：$e';
    }
  }

  /// 提交对话内容并获取AI回复
  Future<Map<String, dynamic>> submitDialogue({
    required String assessmentId,
    required List<Map<String, String>> messages,
  }) async {
    try {
      // 获取最新的用户消息用于保存，因为messages现在是整个历史
      final currentUserMessage = messages.isNotEmpty && messages.last['role'] == 'user' 
                                 ? messages.last['content'] ?? '' 
                                 : ''; // 如果最后一条不是用户消息，则为空

      print('发送消息列表到 Deepseek (in DialogueAssessmentService): $messages'); 
      
      // 调用更新后的 sendMessage，传递整个消息列表
      final response = await DeepseekService.sendMessage(
        messages, 
        conversationId: 'assessment' // 保持 assessment conversationId
      );

      if (!response.success) throw response.error ?? '未收到有效的AI回复';
      
      print('收到 AI 回复: ${response.content}');

      // 保存交互记录时，仍然只保存最新的用户消息和AI回复
      final interaction = await _supabase.from('assessment_interactions').insert({
        'assessment_id': assessmentId,
        'user_message': currentUserMessage, 
        'ai_response': response.content,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      await _supabase.from('assessment_history').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assessmentId);

      print('保存对话记录成功: $interaction');

      // 返回结果中也只包含最新的交互信息
      return {
        'interaction': {
          'id': interaction['id'],
          'userResponse': currentUserMessage, 
          'aiResponse': response.content,
          'timestamp': interaction['created_at'],
        },
        'isComplete': false,
        'success': true,
        'error': null,
      };
    } catch (e) {
      print('发送消息失败: $e');
      return {
        'interaction': null,
        'isComplete': false,
        'success': false,
        'error': e.toString(),
      };
    }
  }
  /// 获取评估结果
  Future<Map<String, dynamic>> getAssessmentResult(String assessmentId) async {
    try {
      final assessment = await _supabase.from('assessment_history')
          .select('*, assessment_interactions(*)')
          .eq('id', assessmentId)
          .single();
      
      final interactions = List<Map<String, dynamic>>.from(
        assessment['assessment_interactions'] ?? []
      );

      print('获取评估结果成功: $assessment');  // 添加调试日志

      return {
        ...assessment,
        'interactions': interactions,
      };
    } catch (e) {
      print('获取评估结果失败: $e');  // 添加错误日志
      throw '获取评估结果失败：$e';
    }
  }

  /// 获取历史对话列表
  Future<List<Map<String, dynamic>>> getHistoryConversations() async {
    try {
      final response = await _supabase.from('assessment_history')
          .select()
          .eq('type', 'dialogue')
          .order('created_at', ascending: false)
          .limit(10);
      
      print('获取历史对话成功: $response');  // 添加调试日志
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取历史对话失败: $e');  // 添加错误日志
      throw '获取历史对话失败：$e';
    }
  }

  /// 删除历史对话
  Future<void> deleteConversation(String assessmentId) async {
    try {
      // 删除相关的对话记录
      await _supabase.from('assessment_interactions')
          .delete()
          .eq('assessment_id', assessmentId);
      
      // 删除评估记录
      await _supabase.from('assessment_history')
          .delete()
          .eq('id', assessmentId);
      
      print('删除对话成功: $assessmentId');  // 添加调试日志
    } catch (e) {
      print('删除对话失败: $e');  // 添加错误日志
      throw '删除对话失败：$e';
    }
  }

  /// 生成追问问题
  Future<Map<String, dynamic>> generateFollowUpQuestions({
    required String assessmentId,
    required List<Map<String, dynamic>> uiMessages, 
  }) async {
    try {
      // 获取评估详情包含问卷数据
      final assessmentDetail = await getAssessmentDetail(assessmentId);
      final interactions = List<Map<String, dynamic>>.from(assessmentDetail['assessment_interactions'] ?? []);
      
      // 提取最新的问卷数据
      final latestProfileData = interactions.isNotEmpty 
          ? interactions.last['profile_data'] 
          : null;
      
      // 构建对话历史文本 (仅用于 prompt)
      final historyText = uiMessages.map((msg) => 
        '${msg['isUser'] ? "用户" : "AI"}: ${msg['content']}'
      ).join('\n');
      
      // 构建系统提示词 (prompt 保持不变)
      final prompt = '''
请仔细分析以下信息，生成3个非常具体的追问。这些问题必须直接基于用户的回答和问卷数据。

===最新问卷数据===
${latestProfileData != null ? jsonEncode(latestProfileData) : '暂无问卷数据'}

===对话历史===
$historyText

追问要求：
1. 每个问题必须直接关联用户已提到的具体内容
2. 针对用户提到的模糊或不完整的点展开提问
3. 基于问卷数据中的具体指标深入询问
4. 重点关注用户提到的实际案例和经历

问题要求：
1. 问题要具体，不能泛泛而谈
2. 一次只问一个重点
3. 用户能通过具体例子回答
4. 问题要简短，避免复杂的多重提问

示例：
❌ "你平时是怎么学习的？"（太宽泛）
✅ "你提到用PyTorch学习GNN时遇到困难，具体是在哪一步卡住的？"（具体、有针对性）

❌ "你觉得自己的学习方法效果如何？"（太模糊）
✅ "上周你尝试的图解法学习算法，帮你解决了哪些具体的理解难点？"（基于实际经历）

请直接列出问题，确保每个问题都紧密关联用户已提供的信息。''';

      // 修改: 构建传递给 Deepseek 的消息列表
      final deepseekMessages = [
        {'role': 'user', 'content': prompt}
      ];

      log('[Service] 发送追问生成请求: $deepseekMessages');
      // 修改: 调用更新后的 sendMessage，传递构建好的消息列表
      final response = await DeepseekService.sendMessage(deepseekMessages);
      log('[Service] 收到追问原始响应: success=${response.success}, content="${response.content.replaceAll('\n', '\\n')}"'); 
      
      if (!response.success) throw response.error ?? '生成追问失败';

      final rawContent = response.content;
      log('[Service] 原始 content: "$rawContent"');
      
      final lines = rawContent.split('\n');
      log('[Service] 按 \\n 分割后的行数: ${lines.length}');
      
      final filteredLines = lines.where((line) {
        final trimmedLine = line.trim();
        final isNotEmpty = trimmedLine.isNotEmpty;
        // 修改: 同时检查半角和全角问号
        final containsQuestionMark = trimmedLine.contains('?') || trimmedLine.contains('？'); 
        log('[Service]     过滤行 "$line": trim="$trimmedLine", notEmpty=$isNotEmpty, contains?= $containsQuestionMark');
        return isNotEmpty && containsQuestionMark;
      }).toList();
      log('[Service] 过滤后的行数: ${filteredLines.length}');
      log('[Service] 最终解析出的问题列表: $filteredLines');

      return {
        'followUpQuestions': filteredLines, 
        'profileData': latestProfileData,
        'success': true, 
        'error': null,   
      };
    } catch (e, stackTrace) { 
      log('[Service] 生成追问失败', error: e, stackTrace: stackTrace); 
      return {
        'followUpQuestions': null,
        'profileData': null,
        'success': false, 
        'error': e.toString(), 
      };
    }
  }

  Future<Map<String, dynamic>> getAssessmentDetail(String assessmentId) async {
    try {
      final response = await _supabase.from('assessment_history')
          .select('*, assessment_interactions(id, user_message, ai_response, profile_data, created_at)')
          .eq('id', assessmentId);
      
      if (response == null || response.isEmpty) {
        throw '获取评估详情失败: 记录不存在';
      }
      
      // 处理返回的数据
      final data = response[0];
      data['assessment_interactions'] = List<Map<String, dynamic>>.from(
        data['assessment_interactions'] ?? []
      );
      
      return data;
    } catch (e) {
      print('获取评估详情失败: $e');
      rethrow;
    }
  }
} 