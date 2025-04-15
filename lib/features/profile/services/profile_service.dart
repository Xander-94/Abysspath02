import 'package:supabase_flutter/supabase_flutter.dart';

/// 个人中心服务
class ProfileService {
  final _supabase = Supabase.instance.client;

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw '用户未登录';

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('获取用户信息失败: $e');
      throw '获取用户信息失败：$e';
    }
  }

  /// 更新用户信息
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw '用户未登录';

      await _supabase.from('profiles').upsert({
        'id': userId,
        'name': name,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('更新用户信息失败: $e');
      throw '更新用户信息失败：$e';
    }
  }

  /// 修改密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw '用户未登录';
      if (user.email == null) throw '用户邮箱不存在';

      // 先验证旧密码
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPassword,
      );
      
      if (response.user == null) throw '旧密码验证失败';

      // 更新新密码
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      print('修改密码失败: $e');
      if (e.toString().contains('Invalid login credentials')) {
        throw '旧密码不正确';
      }
      throw '修改密码失败：$e';
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('退出登录失败: $e');
      throw '退出登录失败：$e';
    }
  }
} 