import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/assessment/providers/assessment_provider.dart';
import '../../features/profile/providers/profile_notifier.dart';
import '../../features/profile/services/profile_service.dart';

/// 全局Provider容器
final container = ProviderContainer();

/// 认证状态Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 评估状态Provider
final assessmentProvider = StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
  return AssessmentNotifier();
});

/// 个人中心状态Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final service = ProfileService();
  return ProfileNotifier(service);
});