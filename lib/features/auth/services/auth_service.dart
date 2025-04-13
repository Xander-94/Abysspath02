import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  // 用户注册
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    return response;
  }

  // 用户登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // 用户登出
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // 重置密码
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // 更新密码
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(
      password: newPassword,
    ));
  }

  // 获取当前用户
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // 更新用户资料
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    await _client.auth.updateUser(UserAttributes(
      data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    ));
  }

  // 监听认证状态变化
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }
} 