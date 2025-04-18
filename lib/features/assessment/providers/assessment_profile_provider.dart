import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:abysspath02/features/assessment/models/assessment_profile.dart';
import 'package:abysspath02/features/profile/services/profile_service.dart'; // 需要 ProfileService
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 导入 Provider

part 'assessment_profile_provider.g.dart';

// 假设 ProfileService 的 Provider 定义 (如果尚未定义，需要添加)
// 注意：如果 ProfileService 有依赖，需要正确地提供这些依赖。
// 这里仅作示例，实际定义可能在其他文件中。
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());


// 使用 Riverpod Generator 简化 Provider 创建
@riverpod
Future<AssessmentProfile?> assessmentProfile(AssessmentProfileRef ref) async {
  // 获取 ProfileService 实例
  final profileService = ref.watch(profileServiceProvider);

  // 调用服务方法获取数据
  final profile = await profileService.getAssessmentProfile();

  // 返回获取到的数据 (可能是 null)
  return profile;
} 