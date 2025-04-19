import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 导入模型
import '../models/learning_path_models.dart';
// 导入Dio provider
import '../../../core/providers/dio_provider.dart';

/// 学习路径API服务提供者
final learningPathServiceProvider = Provider<LearningPathApiService>((ref) {
  final dio = ref.watch(dioProvider);
  // 从Supabase获取会话token
  final token = Supabase.instance.client.auth.currentSession?.accessToken;

  return LearningPathApiService(dio, token);
});

/// 学习路径API异常
class LearningPathApiException implements Exception {
  final String message;
  final int? statusCode;
  LearningPathApiException(this.message, {this.statusCode});

  @override
  String toString() => 'LearningPathApiException: $message (Status code: $statusCode)';
}

/// 学习路径API服务
class LearningPathApiService {
  final Dio _dio;
  final String? _token; // 存储认证Token

  // 构造函数，接收Dio实例和Token
  LearningPathApiService(this._dio, this._token);

  // 辅助方法，用于添加认证头
  Options _getAuthOptions() {
    if (_token == null || _token.isEmpty) {
      throw LearningPathApiException('用户未认证或Token为空', statusCode: 401);
    }
    return Options(headers: {'Authorization': 'Bearer $_token'});
  }

  // 创建学习路径 (POST /learning-paths/)
  Future<String> createLearningPath(LearningPathCreateRequest request) async {
    try {
      final response = await _dio.post(
        '/learning-paths/',
        data: request.toJson(),
        options: _getAuthOptions(),
      );

      // 严格检查状态码，只接受201
      if (response.statusCode == 201 && response.data != null) {
        // 确保response.data是Map<String, dynamic>
        if (response.data is Map<String, dynamic>){
             final responseData = response.data as Map<String, dynamic>;
             // !! 直接从响应中提取 learning_path_id !!
             final pathId = responseData['learning_path_id'] as String?;
             if (pathId != null) {
                return pathId;
             } else {
                 throw LearningPathApiException(
                    '创建路径成功，但响应中缺少路径ID',
                    statusCode: response.statusCode);
             }
        } else {
             throw LearningPathApiException(
                '创建路径后服务器返回格式无效',
                statusCode: response.statusCode);
        }
      } else {
        final String? detail = _extractDetailFromResponse(response.data);
        throw LearningPathApiException(
            detail != null ? detail : '创建学习路径失败 (非201状态码)',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
       final String? detail = _extractDetailFromResponse(e.response?.data);
       final String message = detail != null ? detail : (e.message != null ? e.message! : '创建路径时网络错误');
       throw LearningPathApiException(
          message,
          statusCode: e.response?.statusCode
       );
    } catch (e) {
       // 捕获其他错误，例如类型转换失败
       throw LearningPathApiException('发生意外错误: ${e.toString()}');
    }
  }

  // 获取学习路径列表 (GET /learning-paths/)
  Future<List<LearningPath>> listLearningPaths() async {
    try {
      final response = await _dio.get(
        '/learning-paths/',
        options: _getAuthOptions(),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => LearningPath.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
         final String? detail = _extractDetailFromResponse(response.data);
         throw LearningPathApiException(
            detail != null ? detail : '加载学习路径失败 (非200状态码或格式无效)',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
        final String? detail = _extractDetailFromResponse(e.response?.data);
        final String message = detail != null ? detail : (e.message != null ? e.message! : '加载路径时网络错误');
        throw LearningPathApiException(
            message,
            statusCode: e.response?.statusCode
        );
    } catch (e) {
        throw LearningPathApiException('发生意外错误: ${e.toString()}');
    }
  }

  // 获取学习路径详情 (GET /learning-paths/{path_id})
  Future<FullLearningPathResponse> getLearningPathDetail(String pathId) async {
    if (pathId.isEmpty) {
        throw LearningPathApiException('路径ID不能为空');
    }
    try {
      final response = await _dio.get(
        '/learning-paths/$pathId',
        options: _getAuthOptions(),
      );

      if (response.statusCode == 200 && response.data != null) {
         if (response.data is Map<String, dynamic>) {
            return FullLearningPathResponse.fromJson(response.data as Map<String, dynamic>);
         } else {
            throw LearningPathApiException(
                '路径详情的服务器响应格式无效',
                statusCode: response.statusCode);
         }
      }
      // DioException catch块会处理404
      else {
          final String? detail = _extractDetailFromResponse(response.data);
          throw LearningPathApiException(
            detail != null ? detail : '加载学习路径详情失败 (非200状态码)',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
         if (e.response?.statusCode == 404) {
             final String? detail = _extractDetailFromResponse(e.response?.data);
             throw LearningPathApiException(detail != null ? detail : '学习路径不存在或无权访问', statusCode: 404);
         }
         final String? detail = _extractDetailFromResponse(e.response?.data);
         final String message = detail != null ? detail : (e.message != null ? e.message! : '加载路径详情时网络错误');
         throw LearningPathApiException(
             message,
             statusCode: e.response?.statusCode
         );
    } catch (e) {
        // 添加 stackTrace 参数并打印详细信息
        print('*** Detailed Deserialization Error in getLearningPathDetail ***');
        print('Error Object: $e');
        // 尝试打印堆栈跟踪 (如果可用)
        if (e is Error) {
          print('Stack Trace:\n${e.stackTrace}');
        }
        // 仍然抛出原来的异常，以便上层能捕获
        throw LearningPathApiException('发生意外错误: ${e.toString()}');
    }
  }

  // 辅助方法，尝试从响应数据中提取'detail'字段
  String? _extractDetailFromResponse(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      return data['detail']?.toString();
    }
    return null;
  }
} 