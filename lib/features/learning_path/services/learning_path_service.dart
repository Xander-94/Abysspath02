import 'package:supabase_flutter/supabase_flutter.dart';

/// 学习路径服务
class LearningPathService {
  final _supabase = Supabase.instance.client;

  /// 获取历史学习路径列表
  Future<List<Map<String, dynamic>>> getHistoryPaths() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw '用户未登录';
      }

      final response = await _supabase.from('learning_paths')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      
      print('获取历史学习路径成功: $response');  // 添加调试日志
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取历史学习路径失败: $e');  // 添加错误日志
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

      final response = await _supabase.from('learning_paths').insert({
        'user_id': userId,
        'title': '新的学习路径',
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      print('创建新学习路径成功: $response');  // 添加调试日志
      return response;
    } catch (e) {
      print('创建学习路径失败: $e');  // 添加错误日志
      throw '创建学习路径失败：$e';
    }
  }

  /// 删除学习路径
  Future<void> deletePath(String pathId) async {
    try {
      // 删除相关的学习任务
      await _supabase.from('learning_tasks')
          .delete()
          .eq('path_id', pathId);
      
      // 删除学习路径
      await _supabase.from('learning_paths')
          .delete()
          .eq('id', pathId);
      
      print('删除学习路径成功: $pathId');  // 添加调试日志
    } catch (e) {
      print('删除学习路径失败: $e');  // 添加错误日志
      throw '删除学习路径失败：$e';
    }
  }
} 