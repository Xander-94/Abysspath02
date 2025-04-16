import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

/// 个人中心服务
class ProfileService {
  final _supabase = Supabase.instance.client;

  /// 获取用户信息
  Future<Profile?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
      
      return Profile.fromJson(response);
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  /// 更新用户信息
  Future<bool> updateProfile(Profile profile) async {
    try {
      if (profile.id == null) return false;
      await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id!);
      return true;
    } catch (e) {
      print('更新用户信息失败: $e');
      return false;
    }
  }

  /// 修改密码
  Future<bool> changePassword(String password) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      return true;
    } catch (e) {
      print('修改密码失败: $e');
      return false;
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
} 