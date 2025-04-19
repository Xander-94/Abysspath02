import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart'; // *** 导入 Dio ***
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 导入Provider，虽然这里不用，但可能需要
import '../models/learning_path_models.dart';
import 'learning_path_api_service.dart'; // 导入API服务

/// 学习路径服务 (现在包含与后端API交互的逻辑)
class LearningPathService {
  final _supabase = Supabase.instance.client;
  final _baseUrl = 'http://10.0.2.2:8000';  // Android模拟器中访问本机服务需要使用10.0.2.2
  final LearningPathApiService _apiService; // *** 接收 API 服务实例 ***

  // *** 修改构造函数以接收 API 服务 ***
  LearningPathService(this._apiService);

  /// 获取历史学习路径列表
  Future<List<Map<String, dynamic>>> getHistoryPaths() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw '用户未登录';
      }

      // *** 修改：从正确的 'learning_paths' 表读取列表信息 ***
      final response = await _supabase.from('learning_paths') 
          .select('id, title, description, created_at, updated_at') // 只选择列表需要展示的字段
          .eq('user_id', userId)
          .order('updated_at', ascending: false) // 按更新时间排序，新的在前
          .limit(20); // 限制返回数量，比如最多20条
      
      print('获取历史学习路径成功 (从 learning_paths): $response');
      // 确保 response 是 List<Map<String, dynamic>> 类型
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        print('警告：获取历史学习路径的响应不是列表: $response');
        return []; // 返回空列表以避免错误
      }
      
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

      // 生成唯一标题，例如：新的学习路径 - 1681823456789
      final uniqueTitle = '新的学习路径 - ${DateTime.now().millisecondsSinceEpoch}';

      final response = await _supabase.from('learning_path_history').insert({
        'user_id': userId,
        'title': uniqueTitle, // 使用唯一标题
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
          .select('*, is_creation_confirmation')
          .eq('path_id', pathId)
          .order('created_at');
      
      print('获取消息历史成功: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取消息历史失败: $e');
      throw '获取消息历史失败：$e';
    }
  }

  /// 生成并保存学习路径 (调用后端 POST /learning-paths/)
  Future<String> generateAndSaveLearningPath(LearningPathCreateRequest request) async {
    print('[LearningPathService] generateAndSaveLearningPath called with goal: ${request.userGoal}');
    try {
      // *** 使用注入的 _apiService，它现在返回 String (pathId) ***
      final String createdPathId = await _apiService.createLearningPath(request);
      print('[LearningPathService] Backend API returned created path ID: $createdPathId');
      // !! 直接返回获取到的 pathId !!
      return createdPathId;
    } catch (e) {
      print('[LearningPathService] Error generating learning path via API: $e');
      // 重新抛出更具体的异常或包装后的异常
      if (e is LearningPathApiException) { 
        throw Exception('通过API生成学习路径失败: ${e.message}');
      } else {
        throw Exception('通过API生成学习路径时发生未知错误: $e'); 
      }
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

  /// 获取完整的学习路径数据（节点、边和资源）
  Future<FullLearningPathResponse> getFullLearningPath(String pathId) async {
    // *** 这里也应该使用注入的 _apiService 来调用后端的 GET /learning-paths/{path_id} ***
    // 暂时保留旧的 Supabase 调用作为后备或未实现 API 的情况
    try {
      print('[LearningPathService] getFullLearningPath called for path: $pathId');
      final fullPath = await _apiService.getLearningPathDetail(pathId);
      print('[LearningPathService] API returned full path details.');
      return fullPath;
    } catch (e) {
       print('[LearningPathService] Error fetching full path via API: $e. Falling back to Supabase.');
       // API 调用失败，尝试从 Supabase 直接获取 (可能数据不完整或未同步)
       try {
          final pathData = await _supabase.from('learning_paths')
              .select()
              .eq('id', pathId)
              .single();
              
          final nodesData = await _supabase.from('path_nodes')
              .select()
              .eq('path_id', pathId);
              
          final edgesData = await _supabase.from('path_edges')
              .select()
              .eq('path_id', pathId);
              
          final resourcesData = await _supabase.from('node_resources')
              .select()
              .eq('path_id', pathId);
          
          return FullLearningPathResponse(
            path: LearningPath.fromJson(pathData),
            nodes: List<Map<String, dynamic>>.from(nodesData).map((n) => PathNode.fromJson(n)).toList(),
            edges: List<Map<String, dynamic>>.from(edgesData).map((e) => PathEdge.fromJson(e)).toList(),
            resources: List<Map<String, dynamic>>.from(resourcesData).map((r) => NodeResource.fromJson(r)).toList(),
          );
       } catch (supabaseError) {
         print('[LearningPathService] Error fetching path from Supabase fallback: $supabaseError');
         throw Exception('获取学习路径详情失败 (API和Supabase均失败): $e');
       }
    }
  }
}

/// 提供 LearningPathService 实例 (业务逻辑层)
final learningPathLogicProvider = Provider<LearningPathService>((ref) { // *** 重命名为 Logic Provider ***
  // 获取 LearningPathApiService 实例
  final apiService = ref.watch(learningPathServiceProvider); // *** 依赖 API Service Provider ***
  return LearningPathService(apiService);
}); 