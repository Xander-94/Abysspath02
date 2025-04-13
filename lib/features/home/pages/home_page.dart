import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/home_provider.dart';
import '../../../core/config/supabase_config.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).loadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final user = SupabaseConfig.client.auth.currentUser;

    return AppScaffold(
      title: '首页',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await SupabaseConfig.client.auth.signOut();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出登录')),
              );
              context.go('/login');
            }
          },
        ),
      ],
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '出错了：${state.error}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(homeProvider.notifier).loadHomeData();
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(state),
                      const SizedBox(height: 16),
                      _buildQuickAccess(),
                      const SizedBox(height: 24),
                      _buildLearningProgress(state),
                      const SizedBox(height: 24),
                      _buildRecommendedPaths(state),
                    ],
                  ),
                ),
    );
  }

  // 用户信息卡片
  Widget _buildUserInfoCard(HomeState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radius12),
      ),
      child: InkWell(
        onTap: () => context.go('/profile'),
        borderRadius: BorderRadius.circular(AppStyles.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacing16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: AppStyles.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来',
                      style: TextStyle(
                        fontSize: AppStyles.fontSize16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacing4),
                    Text(
                      state.username ?? '未登录',
                      style: TextStyle(
                        fontSize: AppStyles.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 快速入口
  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速入口',
          style: TextStyle(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessItem(
                icon: Icons.assessment,
                label: '能力评估',
                onTap: () => context.go('/assessment'),
              ),
            ),
            const SizedBox(width: AppStyles.spacing16),
            Expanded(
              child: _buildQuickAccessItem(
                icon: Icons.school,
                label: '学习路径',
                onTap: () => context.go('/learning-path'),
              ),
            ),
            const SizedBox(width: AppStyles.spacing16),
            Expanded(
              child: _buildQuickAccessItem(
                icon: Icons.person,
                label: '个人中心',
                onTap: () => context.go('/profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 学习进度
  Widget _buildLearningProgress(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学习进度',
          style: TextStyle(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            child: Column(
              children: [
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${(state.progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '当前进度',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppStyles.fontSize14,
                      ),
                    ),
                    Text(
                      '${(state.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppStyles.fontSize14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 推荐学习路径
  Widget _buildRecommendedPaths(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐学习路径',
          style: TextStyle(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recommendedPaths.length,
          itemBuilder: (context, index) {
            final path = state.recommendedPaths[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: AppStyles.spacing8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radius12),
              ),
              child: InkWell(
                onTap: () => context.go('/learning-path/${path['id']}'),
                borderRadius: BorderRadius.circular(AppStyles.radius12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(path['title'] as String),
                  subtitle: Text(path['description'] as String),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 快速入口项
  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radius8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radius8),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacing16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: AppStyles.spacing8),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppStyles.fontSize14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}