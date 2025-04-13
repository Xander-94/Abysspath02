import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../core/config/supabase_config.dart';

/// 认证状态
class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

/// 认证状态管理
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        final userData = await SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        state = state.copyWith(user: UserModel.fromJson(userData));
      }
    } catch (e) {
      state = state.copyWith(error: '初始化用户信息失败: $e');
    }
  }

  Future<void> _createUserRecord(String userId, String email) async {
    try {
      final now = DateTime.now().toIso8601String();
      await SupabaseConfig.client.from('users').insert({
        'id': userId,
        'email': email,
        'created_at': now,
        'updated_at': now,
        'metadata': {},
      });
    } catch (e) {
      throw '创建用户记录失败: $e';
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await SupabaseConfig.client.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _createUserRecord(response.user!.id, email);
        await _initUser();
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '注册失败: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await SupabaseConfig.client.auth.signInWithPassword(email: email, password: password);
      await _initUser();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '登录失败: $e');
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await SupabaseConfig.client.auth.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '登出失败: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      if (state.user != null) {
        await SupabaseConfig.client.from('users').update(data).eq('id', state.user!.id);
        await _initUser();
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '更新个人信息失败: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());