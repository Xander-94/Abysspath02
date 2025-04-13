import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';

/// 首页状态
class HomeState {
  final bool isLoading;
  final String? username;
  final double progress;
  final List<Map<String, dynamic>> recommendedPaths;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.username,
    this.progress = 0.0,
    this.recommendedPaths = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? username,
    double? progress,
    List<Map<String, dynamic>>? recommendedPaths,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      progress: progress ?? this.progress,
      recommendedPaths: recommendedPaths ?? this.recommendedPaths,
      error: error ?? this.error,
    );
  }
}

/// 首页状态管理
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  /// 加载首页数据
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        // 加载用户名
        state = state.copyWith(
          username: user.email ?? '',
          isLoading: false,
        );
        
        // TODO: 加载其他数据
        // 这里可以加载学习进度和推荐路径等数据
        
      } else {
        state = state.copyWith(
          error: '用户未登录',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

/// 首页状态Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});