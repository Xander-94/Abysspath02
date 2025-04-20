import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

// 导入模型
import '../models/learning_path_models.dart';
// 导入聊天模型 (假设在 deepseek_service.dart)
import '../../../core/services/deepseek_service.dart';
// 导入Dio provider
import '../../../core/providers/dio_provider.dart';

part 'learning_path_api_service.g.dart';

/// 定义 API 接口
@RestApi()
abstract class LearningPathApiService {
  factory LearningPathApiService(Dio dio, {String baseUrl}) = _LearningPathApiService;

  // 创建学习路径
  @POST("/learning-paths/") // *** 确保路径是 /learning-paths/ (相对于 Base URL) ***
  Future<LearningPath> createLearningPath(
    @Body() LearningPathCreateRequest request
  );

  // 获取学习路径列表
  @GET("/learning-paths/") // *** 获取列表也应该是 /learning-paths/ ***
  Future<List<LearningPath>> getLearningPaths();

  // 获取学习路径详情
  @GET("/learning-paths/{path_id}") // *** 详情路径 ***
  Future<FullLearningPathResponse> getLearningPathDetail(
    @Path("path_id") String pathId
  );

  // 删除学习路径
  @DELETE("/learning-paths/{path_id}") // *** 删除路径 ***
  @DioResponseType(ResponseType.plain) // 如果后端返回 204 No Content，指定响应类型
  Future<String> deleteLearningPath(@Path("path_id") String pathId);

  // 调用聊天接口 (如果 API Service 也负责这个的话)
  // 根据你的设计，聊天接口可能在其他 Service 中，或者也在这里定义
  @POST("/chat/") // *** 聊天接口路径 ***
  Future<ChatResponse> sendChatMessage(@Body() ChatRequest request);

}

/// 提供 LearningPathApiService 实例
final learningPathServiceProvider = Provider<LearningPathApiService>((ref) {
  final dio = ref.watch(dioProvider);
  // baseUrl 可以省略，因为 Dio Provider 已经设置了
  return LearningPathApiService(dio);
});

/// 学习路径API异常
class LearningPathApiException implements Exception {
  final String message;
  final int? statusCode;
  LearningPathApiException(this.message, {this.statusCode});

  @override
  String toString() => 'LearningPathApiException: $message (Status code: $statusCode)';
} 