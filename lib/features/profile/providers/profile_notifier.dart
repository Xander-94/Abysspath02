import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final Profile? profile;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    Profile? profile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _service.getProfile();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: profile == null ? '获取用户信息失败' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '获取用户信息失败: $e',
      );
    }
  }

  Future<bool> updateProfile({String? name, String? avatar}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = state.profile;
      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          error: '未找到用户信息',
        );
        return false;
      }

      final updatedProfile = profile.copyWith(
        name: name,
        avatar: avatar,
      );

      final success = await _service.updateProfile(updatedProfile);
      if (success) {
        state = state.copyWith(
          isLoading: false,
          profile: updatedProfile,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: '更新用户信息失败',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新用户信息失败: $e',
      );
      return false;
    }
  }

  Future<bool> changePassword(String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _service.changePassword(password);
      state = state.copyWith(
        isLoading: false,
        error: success ? null : '修改密码失败',
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '修改密码失败: $e',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const ProfileState();
  }
} 