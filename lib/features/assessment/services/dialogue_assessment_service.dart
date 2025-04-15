import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/deepseek_service.dart';

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
    required String message,
  }) async {
    try {
      print('发送消息到 Deepseek: $message');  // 添加调试日志
      
      // 获取AI回复
      final aiResponse = await DeepseekService.sendMessage(message);
      print('收到 AI 回复: $aiResponse');  // 添加调试日志

      // 保存对话记录
      final interaction = await _supabase.from('assessment_interactions').insert({
        'assessment_id': assessmentId,
        'user_message': message,
        'ai_response': aiResponse,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      print('保存对话记录成功: $interaction');  // 添加调试日志

      return {
        'interaction': {
          'id': interaction['id'],
          'userResponse': message,
          'aiResponse': aiResponse,
          'timestamp': interaction['created_at'],
        },
        'isComplete': false, // 根据AI回复判断是否完成评估
      };
    } catch (e) {
      print('发送消息失败: $e');  // 添加错误日志
      throw '发送消息失败：$e';
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
} 