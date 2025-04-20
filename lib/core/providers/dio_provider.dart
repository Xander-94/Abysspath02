import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 导入 Supabase
import 'dart:developer' as developer; // 用于打印日志
import 'dart:math' as math; // 添加dart:math库

// 从 dart-define 读取原始 BASE_URL，不包含 /api
const _rawBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://10.0.2.2:8000', // 默认使用安卓模拟器地址
);

// 构建完整 API URL
const _baseUrl = '$_rawBaseUrl/api';

/// Dio实例提供器
final dioProvider = Provider<Dio>((ref) {
  developer.log('使用的后端 Base URL: $_baseUrl', name: 'DioProvider'); // 打印使用的URL
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl, // 使用包含 /api 的完整 URL
    connectTimeout: const Duration(seconds: 5),
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
        developer.log('添加认证头: Bearer ${accessToken.substring(0, math.min(10, accessToken.length))}...', name: 'DioInterceptor');
      } else {
        developer.log('当前无有效访问令牌', name: 'DioInterceptor');
      }
      return handler.next(options); // 继续请求
    },
    onResponse: (response, handler) {
      // 确保response.data中的字段类型安全
      if (response.data is Map) {
        _ensureTypesSafety(response.data);
      }
      return handler.next(response);
    },
    onError: (DioException err, handler) async {
      developer.log(
          '请求错误: ${err.requestOptions.path}, 状态码: ${err.response?.statusCode}',
          name: 'DioInterceptor');
      
      // 401错误特殊处理 - 确保错误响应数据类型安全
      if (err.response?.statusCode == 401) {
        developer.log('收到401错误，尝试处理...', name: 'DioInterceptor');
        
        // 确保错误响应中的数据类型安全
        if (err.response?.data is Map) {
          _ensureTypesSafety(err.response!.data);
        }
        
        try {
          final refreshed = await Supabase.instance.client.auth.refreshSession();
          if (refreshed.session != null && refreshed.session!.accessToken != null) {
            final newAccessToken = refreshed.session!.accessToken!;
            developer.log('令牌刷新成功: Bearer ${newAccessToken.substring(0, math.min(10, newAccessToken.length))}...', name: 'DioInterceptor');
            
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            developer.log('使用新令牌重试请求: ${options.path}', name: 'DioInterceptor');
            final response = await dio.fetch(options);
            
            // 确保重试响应的数据类型安全
            if (response.data is Map) {
              _ensureTypesSafety(response.data);
            }
            
            return handler.resolve(response);
          } else {
            developer.log('刷新会话成功，但未获取到新令牌', name: 'DioInterceptor', error: refreshed.session);
            // 创建安全的错误响应
            final safeResponse = err.response ?? Response(requestOptions: err.requestOptions);
            safeResponse.data = _createSafeErrorResponse(safeResponse.data, '令牌刷新后仍无法获取令牌');
            
            return handler.reject(DioException(
              requestOptions: err.requestOptions,
              error: '令牌刷新后仍无法获取令牌',
              response: safeResponse
            ));
          }
        } on AuthException catch (refreshError) {
          developer.log('令牌刷新失败: ${refreshError.message}', name: 'DioInterceptor', error: refreshError);
          // 确保创建安全的错误响应
          final safeResponse = err.response ?? Response(requestOptions: err.requestOptions);
          safeResponse.data = _createSafeErrorResponse(safeResponse.data, '认证失败: ${refreshError.message}');
          
          return handler.reject(DioException(
            requestOptions: err.requestOptions,
            error: '认证失败: ${refreshError.message}',
            response: safeResponse
          ));
        } catch (e) {
          developer.log('令牌刷新或重试过程中发生未知错误', name: 'DioInterceptor', error: e);
          // 确保创建安全的错误响应
          final safeResponse = err.response ?? Response(requestOptions: err.requestOptions);
          safeResponse.data = _createSafeErrorResponse(safeResponse.data, '认证过程中发生未知错误');
          
          return handler.reject(DioException(
            requestOptions: err.requestOptions,
            error: '认证过程中发生未知错误',
            response: safeResponse
          ));
        }
      }
      return handler.next(err);
    },
  ));

  return dio;
});

// 确保Map中的值类型安全，防止空值导致类型转换错误
void _ensureTypesSafety(Map<dynamic, dynamic> data) {
  data.forEach((key, value) {
    if (value == null) {
      // 保留null值，但确保不会被错误地转换为String
      return;
    }
    if (value is Map) {
      _ensureTypesSafety(value);
    } else if (value is List) {
      for (final item in value) {
        if (item is Map) {
          _ensureTypesSafety(item);
        }
      }
    }
  });
}

// 创建类型安全的错误响应
Map<String, dynamic> _createSafeErrorResponse(dynamic originalData, String message) {
  final Map<String, dynamic> safeData = {
    'detail': message,
    'status': 'error',
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  // 尝试合并原始数据中的安全字段
  if (originalData is Map) {
    originalData.forEach((key, value) {
      if (key is String && value != null) {
        // 只合并非空值
        safeData[key] = value;
      }
    });
  }
  
  return safeData;
} 