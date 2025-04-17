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

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, error: $error, profile: ${profile != null ? 'Profile(name: ${profile!.name}, personality: ${profile!.behavior?.learningPersonality})' : 'null'})';
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  // Add a private mounted flag
  bool _mounted = true;

  ProfileNotifier(this._service) : super(const ProfileState());

  @override
  void dispose() {
    _mounted = false; // Set flag to false when disposed
    super.dispose();
  }

  Future<void> loadProfile() async {
    print('[ProfileNotifier] loadProfile started.');
    // Check before initial state update
    if (!_mounted) {
      print('[ProfileNotifier] loadProfile cancelled: not mounted.');
      return;
    } 
    print('[ProfileNotifier] State before loading: $state');
    state = state.copyWith(isLoading: true, error: null);
    print('[ProfileNotifier] State after setting loading: $state');
    try {
      final profile = await _service.getProfile();
      print('[ProfileNotifier] Profile fetched from service: ${profile != null ? 'Profile(name: ${profile.name}, personality: ${profile.behavior?.learningPersonality})' : 'null'}');
      // Check again after await before final state update
      if (!_mounted) {
         print('[ProfileNotifier] loadProfile cancelled after await: not mounted.');
         return;
      }
       print('[ProfileNotifier] State before final update: $state');
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: profile == null ? '获取用户信息失败' : null,
      );
      print('[ProfileNotifier] State after final update: $state');
    } catch (e, stacktrace) {
       print('[ProfileNotifier] Error loading profile: $e');
       print('[ProfileNotifier] Stacktrace: $stacktrace');
      // Check again in catch block
      if (!_mounted) return;
      print('[ProfileNotifier] State before error update: $state');
      state = state.copyWith(
        isLoading: false,
        error: '获取用户信息失败: $e',
      );
      print('[ProfileNotifier] State after error update: $state');
    }
  }

  /// 新增方法：根据指定的 responseId 加载 Profile
  Future<void> loadProfileFromResponse(String responseId) async {
    print('[ProfileNotifier] loadProfileFromResponse started for responseId: $responseId');
    if (!_mounted) {
      print('[ProfileNotifier] loadProfileFromResponse cancelled: not mounted.');
      return;
    }
    print('[ProfileNotifier] State before loading from response: $state');
    state = state.copyWith(isLoading: true, error: null);
    print('[ProfileNotifier] State after setting loading from response: $state');
    try {
      // 调用 service 的新方法，传入 responseId
      final profile = await _service.getProfile(targetResponseId: responseId);
      print('[ProfileNotifier] Profile fetched from service (response $responseId): ${profile != null ? 'Profile(name: ${profile.name}, personality: ${profile.behavior?.learningPersonality})' : 'null'}');
      if (!_mounted) {
         print('[ProfileNotifier] loadProfileFromResponse cancelled after await: not mounted.');
         return;
      }
      print('[ProfileNotifier] State before final update from response: $state');
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: profile == null ? '获取用户信息失败(response: $responseId)' : null, // 错误信息中包含 responseId
      );
      print('[ProfileNotifier] State after final update from response: $state');
    } catch (e, stacktrace) {
       print('[ProfileNotifier] Error loading profile from response $responseId: $e');
       print('[ProfileNotifier] Stacktrace: $stacktrace');
      if (!_mounted) return;
      print('[ProfileNotifier] State before error update from response: $state');
      state = state.copyWith(
        isLoading: false,
        error: '获取用户信息失败(response: $responseId): $e', // 错误信息中包含 responseId
      );
      print('[ProfileNotifier] State after error update from response: $state');
    }
  }

  Future<bool> updateProfile({String? name, String? avatar}) async {
    // Check at start
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = state.profile;
      if (profile == null) {
        // Check before state update
        if (!_mounted) return false;
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
       // Check after await
      if (!_mounted) return false;
      if (success) {
        state = state.copyWith(
          isLoading: false,
          profile: updatedProfile,
        );
        return true;
      }

      // Check before state update on failure
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: '更新用户信息失败',
      );
      return false;
    } catch (e) {
      // Check in catch block
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: '更新用户信息失败: $e',
      );
      return false;
    }
  }

  Future<bool> changePassword(String password) async {
    // Check at start
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _service.changePassword(password);
      // Check after await
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: success ? null : '修改密码失败',
      );
      return success;
    } catch (e) {
      // Check in catch block
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: '修改密码失败: $e',
      );
      return false;
    }
  }

  /// 退出登录
  Future<bool> signOut() async {
    // Check at start
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    final success = await _service.signOut();
    // Check after await
    if (!_mounted) return false; 
    // Resetting state is generally safe, but check anyway
    state = ProfileState();
    return success;
  }
}

/// 提供 ProfileNotifier 实例
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  final notifier = ProfileNotifier(profileService);
  return notifier;
});

/// 提供 ProfileService 实例
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService()); 