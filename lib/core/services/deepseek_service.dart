import 'dart:convert';
import 'package:http/http.dart' as http;

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
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android模拟器中访问本机服务需要使用10.0.2.2
  
  /// 发送消息到AI服务
  static Future<ChatResponse> sendMessage(List<Map<String, String>> messages, {String? conversationId}) async {
    try {
      print('发送消息列表到AI服务: $messages');
      print('使用API地址: $_baseUrl/api/chat/');
      
      final request = ChatRequest(
        messages: messages,
        conversationId: conversationId ?? 'string',
      );
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8'
        },
        body: utf8.encode(jsonEncode(request.toJson())),
      );

      print('API 响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatResponse.fromJson(data);
      }
      
      return ChatResponse.error(
        '请求失败：${response.statusCode} - ${utf8.decode(response.bodyBytes)}'
      );
    } catch (e) {
      print('AI服务异常: $e');
      return ChatResponse.error('AI服务异常：$e');
    }
  }
} 