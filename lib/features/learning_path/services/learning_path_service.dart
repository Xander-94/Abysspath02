import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http; // 不再需要
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dartz/dartz.dart'; // *** 彻底移除 dartz 导入 ***
import '../models/learning_path_models.dart';
import 'learning_path_api_service.dart';
import '../../../core/providers/dio_provider.dart'; // *** 添加 Dio Provider 的导入 ***

/// 学习路径服务 (现在包含与后端API交互的逻辑)
class LearningPathService {
  final _supabase = Supabase.instance.client;
  // final _baseUrl = 'http://192.168.137.1:8000';  // 不再需要，由 Dio Provider 处理
  final LearningPathApiService _apiService; // *** 接收 API 服务实例 ***
  final Dio _dio; // *** 添加 Dio 实例 ***

  // *** 修改构造函数以接收 API 服务 和 Dio ***
  LearningPathService(this._apiService, this._dio);

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
      // *** 直接使用 _dio 发起 POST 请求 ***
      final response = await _dio.post(
        '/learning-paths/', // 使用相对路径，Dio Provider 会处理基础 URL
        data: request.toJson(), // 使用请求模型的 toJson 方法
      );
      
      print('[LearningPathService] Backend API response status: ${response.statusCode}');
      print('[LearningPathService] Backend API response data: ${response.data}');

      // *** 检查响应状态码并解析简单 JSON ***
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('learning_path_id') && responseData['learning_path_id'] is String) {
          final pathId = responseData['learning_path_id'] as String;
           print('[LearningPathService] Extracted learning_path_id: $pathId');
          if (pathId.isNotEmpty) {
            return pathId;
          } else {
             throw Exception('API 创建路径成功，但返回的路径 ID 为空字符串');
          }
        } else {
          throw Exception('API 响应成功，但未找到有效的 learning_path_id 字段');
        }
      } else {
        // 处理非 201 状态码或无效响应格式
        throw DioException(
           requestOptions: response.requestOptions,
           response: response,
           error: '创建学习路径请求失败或响应格式无效',
           type: DioExceptionType.badResponse,
        );
      }

    } catch (e) {
      print('[LearningPathService] Error generating learning path via API: $e');
      if (e is DioException) {
        // *** 改进 DioException 处理 ***
        String errorMessage = '网络错误';
        if (e.response?.statusCode != null) {
           errorMessage += ' (状态码: ${e.response!.statusCode})';
        }
        if (e.response?.data != null) {
           // 尝试提取后端的 detail 信息
           var detail = e.response!.data;
           if (detail is Map<String, dynamic> && detail.containsKey('detail')) {
              errorMessage += ': ${detail['detail']}';
           } else if (detail is String && detail.isNotEmpty) {
              errorMessage += ': ${detail}'; // 如果直接返回错误字符串
           } else if (detail is Map<String, dynamic> && detail.containsKey('message')) {
             // 尝试提取 message 字段 (如此处成功响应中的 message)
              errorMessage += ': ${detail['message']}'; 
           }
        } else if (e.message != null && e.message!.isNotEmpty) {
           errorMessage += ': ${e.message}'; // 使用 DioException 的 message 作为后备
        }
        // 抛出更具体的异常信息
        throw Exception('通过API生成学习路径失败: $errorMessage');
      } else {
        // 保留对其他类型异常的处理
        throw Exception('通过API生成学习路径时发生未知错误: $e'); 
      }
    }
  }

  /// 发送消息到后端聊天接口并保存到数据库 - 恢复版
  Future<String> sendMessage(String pathId, String message) async {
    try {
      // 1. 保存用户消息到数据库
      await _supabase.from('learning_path_messages').insert({
        'path_id': pathId,
        'role': 'user',
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. 发送消息到后端聊天接口 (使用 Dio)
      final response = await _dio.post(
        '/chat/', 
        data: {
          'message': message,
          'conversation_id': pathId, 
          'metadata': {'role': 'user'}
        },
      );

      if (response.statusCode == 200) {
        String aiResponse;
        if (response.data is Map<String, dynamic> && response.data.containsKey('content')) {
          aiResponse = response.data['content'] as String;
        } else if (response.data is String) {
          aiResponse = response.data;
        } else {
           print('警告：/chat/ 接口响应格式未知: ${response.data}');
           // 抛出异常表示无法处理
           throw Exception('无法解析AI响应'); 
        }

        // 3. 保存AI响应到数据库
        await _supabase.from('learning_path_messages').insert({
          'path_id': pathId,
          'role': 'assistant',
          'content': aiResponse,
          'created_at': DateTime.now().toIso8601String(),
        });

        // 直接返回 AI 响应字符串
        return aiResponse;
      } else { // 非 200 状态码
        // 抛出异常，携带错误信息
        throw Exception('请求失败：${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) { // 处理 Dio 错误
      print('发送消息 Dio 异常: $e');
      // 重新抛出，让调用者处理
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) { // 处理其他错误，例如 Supabase 插入失败
      print('发送消息失败: $e');
      // 重新抛出
      throw Exception('发送消息时发生错误：$e');
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
  final dio = ref.watch(dioProvider); // *** 获取 Dio 实例 ***
  return LearningPathService(apiService, dio); // *** 传递 Dio 实例 ***
}); 