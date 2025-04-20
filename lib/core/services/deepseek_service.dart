import 'dart:convert';
import 'package:http/http.dart' as http; // 恢复使用 http
// import 'package:dio/dio.dart'; // 暂时移除 Dio
// import 'package:dartz/dartz.dart'; // 移除 dartz
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 移除 provider
// import '../providers/dio_provider.dart'; // 移除 dio provider 导入

// 从 dart-define 读取 BASE_URL，提供默认值用于模拟器
const _baseUrl = String.fromEnvironment(
  'BASE_URL',
  // 注意：这里的基础 URL 不应包含 /api 后缀，因为 http.post 会拼接完整路径
  defaultValue: 'http://10.0.2.2:8000', // 默认使用安卓模拟器地址 (不含 /api)
);

/// 聊天请求模型
class ChatRequest {
  final List<Map<String, String>> messages;
  final String conversationId;
  final Map<String, dynamic>? metadata;

  ChatRequest({
    required this.messages,
    this.conversationId = 'string',
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'messages': messages,
    'conversation_id': conversationId,
    'metadata': metadata ?? {},
  };
}

/// 聊天响应模型
class ChatResponse {
  final String content;
  final String conversationId;
  final bool success;
  final String? error;

  ChatResponse({
    required this.content,
    this.conversationId = 'string',
    this.success = true,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    content: json['content'] as String? ?? '',
    conversationId: json['conversation_id'] as String? ?? 'string',
    success: json['success'] as bool? ?? true,
    error: json['error'] as String?,
  );

  factory ChatResponse.error(String errorMessage) => ChatResponse(
    content: '',
    success: false,
    error: errorMessage,
  );
}

class DeepseekService {
  // 不再需要 Dio 实例
  // final Dio _dio;
  // DeepseekService(this._dio);

  /// 发送消息到AI服务 (恢复为静态方法，使用 http)
  static Future<ChatResponse> sendMessage(List<Map<String, String>> messages, {String? conversationId}) async {
    try {
      print('发送消息列表到AI服务 (http): $messages');
      // 拼接完整的 API 路径
      final apiUrl = '$_baseUrl/api/chat/'; 
      print('使用API地址: $apiUrl');
      
      final request = ChatRequest(
        messages: messages,
        conversationId: conversationId ?? 'string',
      );
      
      // 使用 http.post 发送请求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8'
        },
        body: utf8.encode(jsonEncode(request.toJson())),
      );

      print('API 响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          // 直接返回 ChatResponse，不再需要 Either
          return ChatResponse.fromJson(data);
        } catch (e) {
           print('解码 API 响应时出错: $e, 响应体: ${utf8.decode(response.bodyBytes)}');
           return ChatResponse.error('解码API响应失败: $e');
        }
      } else {
        return ChatResponse.error(
          '请求失败：${response.statusCode} - ${utf8.decode(response.bodyBytes)}'
        );
      }
    } catch (e) { // http 请求错误或其他异常
      print('AI服务异常: $e');
      return ChatResponse.error('AI服务未知异常：$e');
    }
  }
}

// 移除 Provider
// final deepseekServiceProvider = Provider<DeepseekService>((ref) { ... }); 