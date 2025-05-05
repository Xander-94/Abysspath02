import 'dart:convert';
import 'package:http/http.dart' as http; // 恢复使用 http
// import 'package:dio/dio.dart'; // 暂时移除 Dio
// import 'package:dartz/dartz.dart'; // 移除 dartz
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 移除 provider
// import '../providers/dio_provider.dart'; // 移除 dio provider 导入
import 'dart:io' show Platform; // 导入 Platform 类

// 电脑的局域网 IP 地址
const String hostLanIp = '172.17.10.232';

// 根据平台自动选择 DeepseekService 使用的基础 URL
String get _deepseekServiceBaseUrl {
  if (Platform.isAndroid) {
    // Android 模拟器和真机都尝试使用电脑的局域网 IP
    return 'http://$hostLanIp:8000';
  } else if (Platform.isIOS) {
    return 'http://localhost:8000';
  } else {
    return 'http://$hostLanIp:8000';
  }
}

/// 聊天请求模型 (修正为与后端匹配)
class ChatRequest {
  final String message; // 应该是单个消息字符串
  final String? conversationId;
  final Map<String, dynamic>? metadata;

  ChatRequest({
    required this.message,
    this.conversationId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
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

  static final String _apiUrl = '$_deepseekServiceBaseUrl/api/chat/'; // 将API URL定义移到这里

  /// 发送消息到AI服务 (恢复为静态方法，使用 http)
  static Future<ChatResponse> sendMessage(List<Map<String, String>> messages, {String? conversationId}) async {
    if (messages.isEmpty) {
      print('错误：尝试发送空消息列表');
      return ChatResponse.error('无法发送空消息');
    }
    
    // 获取最后一条用户消息内容
    final String lastMessageContent = messages.lastWhere(
      (msg) => msg['role'] == 'user',
      orElse: () => {'content': ''} // 如果没有用户消息，则发送空字符串
    )['content'] ?? '';

    print('发送给后端的最后一条消息内容: $lastMessageContent');
    print('使用的API地址 (DeepseekService): $_apiUrl'); // 明确日志来源

    final request = ChatRequest(
      message: lastMessageContent, // 使用最后一条消息内容
      conversationId: conversationId, // 传递会话ID
    );

    // *** 添加详细日志: 打印即将发送的 JSON 体 ***
    final requestBodyJson = jsonEncode(request.toJson());
    print('发送的请求体 JSON: $requestBodyJson');

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          // 注意：如果后端需要认证，这里可能需要添加 Authorization 头
        },
        body: utf8.encode(requestBodyJson), // 使用已编码的 JSON 字符串
      );

      print('API 响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return ChatResponse.fromJson(data);
        } catch (e) {
          print('解码 API 响应时出错: $e, 响应体: ${utf8.decode(response.bodyBytes)}');
          return ChatResponse.error('解码API响应失败: $e');
        }
      } else if (response.statusCode == 422) {
        // 特别处理422错误，打印详细信息
        print('收到 422 Unprocessable Entity 错误');
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          print('422 错误详情: ${jsonEncode(errorData)}');
          return ChatResponse.error(
            '请求格式错误(422): ${errorData['detail']?[0]?['msg'] ?? utf8.decode(response.bodyBytes)}'
          );
        } catch (_) {
           return ChatResponse.error(
            '请求格式错误(422): ${utf8.decode(response.bodyBytes)}'
          );
        }
      } else {
        return ChatResponse.error(
            '请求失败：${response.statusCode} - ${utf8.decode(response.bodyBytes)}'
        );
      }
    } on http.ClientException catch (e) {
      // 捕获 ClientException，包括 SocketException (例如连接超时)
      print('AI服务网络异常 (ClientException): $e');
      return ChatResponse.error('网络连接错误: ${e.message}');
    } catch (e) {
      print('AI服务未知异常: $e');
      return ChatResponse.error('AI服务未知异常: $e');
    }
  }
}

// 移除 Provider
// final deepseekServiceProvider = Provider<DeepseekService>((ref) { ... }); 