 import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 个人中心状态
class ProfileState {
  final bool isLoading;
  final String? username;
  final String? email;
  final String? avatar;
  final Map<String, dynamic>? statistics;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.username,
    this.email,
    this.avatar,
    this.statistics,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? username,
    String? email,
    String? avatar,
    Map<String, dynamic>? statistics,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      statistics: statistics ?? this.statistics,
      error: error ?? this.error,
    );
  }
}

/// 个人中心状态管理
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  /// 加载用户信息
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 实现加载用户信息逻辑
      final profile = {
        'username': '用户名',
        'email': 'email@example.com',
        'avatar': 'avatar_url',
      };
      state = state.copyWith(
        isLoading: false,
        username: profile['username'],
        email: profile['email'],
        avatar: profile['avatar'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 更新用户信息
  Future<void> updateProfile(String username, String email) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 实现更新用户信息逻辑
      state = state.copyWith(
        isLoading: false,
        username: username,
        email: email,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 实现加载统计数据逻辑
      final statistics = {
        'learningTime': 100,
        'completedCourses': 10,
        'assessmentScore': 85,
      };
      state = state.copyWith(
        isLoading: false,
        statistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}