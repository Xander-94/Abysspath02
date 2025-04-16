import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService();
  Profile? _profile;
  bool _loading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
      _error = _profile == null ? '获取用户信息失败' : null;
    } catch (e) {
      _error = '获取用户信息失败: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Profile profile) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.updateProfile(profile);
      if (success) {
        _profile = profile;
        return true;
      }
      _error = '更新用户信息失败';
      return false;
    } catch (e) {
      _error = '更新用户信息失败: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.changePassword(password);
      if (!success) _error = '修改密码失败';
      return success;
    } catch (e) {
      _error = '修改密码失败: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _profile = null;
    notifyListeners();
  }
}