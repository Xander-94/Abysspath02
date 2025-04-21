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
    final isLoading = ref.watch(homeProvider.select((s) => s.isLoading));
    final error = ref.watch(homeProvider.select((s) => s.error));

    return AppScaffold(
      title: '首页',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: '退出登录',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorView(context, error)
              : _buildContentView(),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMsg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            '加载首页数据失败',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            errorMsg,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(homeProvider.notifier).loadHomeData();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserInfoCard(),
          SizedBox(height: AppStyles.spacing16),
          _QuickAccess(),
          SizedBox(height: AppStyles.spacing24),
          _LearningProgress(),
          SizedBox(height: AppStyles.spacing24),
        ],
      ),
    );
  }
}

class _UserInfoCard extends ConsumerWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(homeProvider.select((s) => s.username));

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
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: AppStyles.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '欢迎回来',
                      style: TextStyle(
                        fontSize: AppStyles.fontSize16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacing4),
                    Text(
                      username ?? '访客',
                      style: const TextStyle(
                        fontSize: AppStyles.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速入口',
          style: TextStyle(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickAccessItem(
              icon: Icons.assessment_outlined,
              label: '能力评估',
              onTap: () => context.go('/assessment'),
            ),
            _QuickAccessItem(
              icon: Icons.school_outlined,
              label: '学习路径',
              onTap: () => context.go('/learning-path'),
            ),
            _QuickAccessItem(
              icon: Icons.person_outline,
              label: '个人中心',
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radius8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppStyles.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: AppStyles.spacing8),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppStyles.fontSize12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningProgress extends ConsumerWidget {
  const _LearningProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(homeProvider.select((s) => s.progress));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学习进度',
          style: TextStyle(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppStyles.radius4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppStyles.spacing12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
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
}