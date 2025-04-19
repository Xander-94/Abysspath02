import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 导入 Supabase
import 'dart:developer' as developer; // 用于打印日志

/// Dio实例提供器
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000/api', // 安卓模拟器中访问本机服务
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 300),
    contentType: 'application/json',
    validateStatus: (status) => status != null && status < 500,
  ));

  // 添加日志拦截器
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  // 添加认证和令牌刷新拦截器
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // 尝试获取当前会话的访问令牌
      final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        developer.log('添加认证头: Bearer ${accessToken.substring(0, 10)}...', name: 'DioInterceptor');
      } else {
         developer.log('当前无有效访问令牌', name: 'DioInterceptor');
      }
      return handler.next(options); // 继续请求
    },
    onError: (DioException err, handler) async {
      developer.log(
          '请求错误: ${err.requestOptions.path}, 状态码: ${err.response?.statusCode}',
          name: 'DioInterceptor');
      // 检查是否是401错误
      if (err.response?.statusCode == 401) {
        developer.log('收到401错误，尝试刷新令牌...', name: 'DioInterceptor');
        try {
          // 尝试刷新令牌
          final refreshed = await Supabase.instance.client.auth.refreshSession();

          if (refreshed.session != null && refreshed.session!.accessToken != null) {
            final newAccessToken = refreshed.session!.accessToken!;
            developer.log('令牌刷新成功: Bearer ${newAccessToken.substring(0, 10)}...', name: 'DioInterceptor');

            // 更新Dio实例的默认头（如果需要，或仅更新当前请求）
            // dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

            // 更新失败请求的头
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            // 重试请求
            developer.log('使用新令牌重试请求: ${options.path}', name: 'DioInterceptor');
            final response = await dio.fetch(options);
            return handler.resolve(response); // 返回重试成功的结果
          } else {
             developer.log('刷新会话成功，但未获取到新令牌', name: 'DioInterceptor', error: refreshed.session);
             // 如果刷新后仍然没有令牌，可能需要引导用户重新登录
             // 可以抛出特定异常或直接拒绝
             return handler.reject(DioException(
                requestOptions: err.requestOptions,
                error: '令牌刷新后仍无法获取令牌',
                response: err.response
             ));
          }
        } on AuthException catch (refreshError) {
          // 刷新令牌失败 (例如刷新令牌也过期了)
          developer.log('令牌刷新失败: ${refreshError.message}', name: 'DioInterceptor', error: refreshError);
          // 可以在这里触发登出逻辑
          // await Supabase.instance.client.auth.signOut();
          // ref.read(authProvider.notifier).setUnauthenticated(); // 假设有这样的方法
          return handler.reject(err); // 拒绝原始错误
        } catch (e) {
           developer.log('令牌刷新或重试过程中发生未知错误', name: 'DioInterceptor', error: e);
           return handler.reject(err); // 拒绝原始错误
        }
      }
      // 如果不是401错误，或者刷新失败，则将错误继续传递下去
      return handler.next(err);
    },
  ));

  return dio;
}); 