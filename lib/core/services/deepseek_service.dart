import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepseekService {
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android模拟器中访问本机服务需要使用10.0.2.2
  
  /// 发送消息到AI服务
  static Future<String> sendMessage(String message, {String role = 'user'}) async {
    try {
      print('发送消息到AI服务: $message');
      print('使用API地址: $_baseUrl/chat');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8'
        },
        body: utf8.encode(jsonEncode({
          'message': message,
          'metadata': {'role': role}
        })),
      );

      print('API 响应状态码: ${response.statusCode}');
      print('API 响应体: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content'] as String;
      }
      throw '请求失败：${response.statusCode} - ${utf8.decode(response.bodyBytes)}';
    } catch (e) {
      print('AI服务异常: $e');
      throw 'AI服务异常：$e';
    }
  }
} 