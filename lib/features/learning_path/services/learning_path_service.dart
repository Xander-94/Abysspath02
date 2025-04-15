import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 学习路径服务
class LearningPathService {
  final _supabase = Supabase.instance.client;
  final _baseUrl = 'http://10.0.2.2:8000';  // Android模拟器中访问本机服务需要使用10.0.2.2

  /// 获取历史学习路径列表
  Future<List<Map<String, dynamic>>> getHistoryPaths() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw '用户未登录';
      }

      final response = await _supabase.from('learning_path_history')
          .select()
          .eq('user_id', userId)
          .order('last_message_at', ascending: false)  // 按最后消息时间排序
          .limit(10);
      
      print('获取历史学习路径成功: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取历史学习路径失败: $e');
      throw '获取历史学习路径失败：$e';
    }
  }

  /// 创建新的学习路径
  Future<Map<String, dynamic>> createPath() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw '用户未登录';
      }

      final response = await _supabase.from('learning_path_history').insert({
        'user_id': userId,
        'title': '新的学习路径',
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
        'message_count': 0,  // 初始化消息计数
      }).select().single();
      
      print('创建新学习路径成功: $response');
      return response;
    } catch (e) {
      print('创建学习路径失败: $e');
      throw '创建学习路径失败：$e';
    }
  }

  /// 删除学习路径
  Future<void> deletePath(String pathId) async {
    try {
      // 由于设置了级联删除，只需要删除学习路径即可
      await _supabase.from('learning_path_history')
          .delete()
          .eq('id', pathId);
      
      print('删除学习路径成功: $pathId');
    } catch (e) {
      print('删除学习路径失败: $e');
      throw '删除学习路径失败：$e';
    }
  }

  /// 获取学习路径的消息历史
  Future<List<Map<String, dynamic>>> getPathMessages(String pathId) async {
    try {
      final response = await _supabase.from('learning_path_messages')
          .select()
          .eq('path_id', pathId)
          .order('created_at');
      
      print('获取消息历史成功: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取消息历史失败: $e');
      throw '获取消息历史失败：$e';
    }
  }

  /// 发送消息到Deepseek并保存到数据库
  Future<String> sendMessage(String pathId, String message) async {
    try {
      // 1. 保存用户消息到数据库
      await _supabase.from('learning_path_messages').insert({
        'path_id': pathId,
        'role': 'user',
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. 发送消息到Deepseek
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8'
        },
        body: utf8.encode(jsonEncode({
          'message': message,
          'conversation_id': pathId,
          'metadata': {'role': 'user'}
        })),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == false) {
          throw data['error'] ?? '请求失败';
        }
        final aiResponse = data['content'] as String;

        // 3. 保存AI响应到数据库
        await _supabase.from('learning_path_messages').insert({
          'path_id': pathId,
          'role': 'assistant',
          'content': aiResponse,
          'created_at': DateTime.now().toIso8601String(),
        });

        return aiResponse;
      }
      throw '请求失败：${response.statusCode} - ${utf8.decode(response.bodyBytes)}';
    } catch (e) {
      print('发送消息失败: $e');
      throw '发送消息失败：$e';
    }
  }
} 