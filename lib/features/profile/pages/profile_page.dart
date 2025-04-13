import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppScaffold(
      title: '个人中心',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户基本信息卡片
          AppCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user?.email ?? '未登录'),
              subtitle: const Text('点击修改个人信息'),
              onTap: () {
                // TODO: 跳转到个人信息编辑页面
              },
            ),
          ),
          const SizedBox(height: 16),

          // 个人画像卡片
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('个人画像', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildProfileItem('兴趣爱好', user?.metadata?['interests'] ?? ['暂无数据']),
                  const SizedBox(height: 8),
                  _buildProfileItem('技能水平', user?.metadata?['skills'] ?? ['暂无数据']),
                  const SizedBox(height: 8),
                  _buildProfileItem('元能力', user?.metadata?['meta_abilities'] ?? ['暂无数据']),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 安全设置卡片
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('修改密码'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 跳转到密码修改页面
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('退出登录'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认退出'),
                        content: const Text('确定要退出登录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(authProvider.notifier).signOut();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: items.map((item) => Chip(
            label: Text(item.toString()),
            backgroundColor: AppColors.primary.withOpacity(0.1),
          )).toList(),
        ),
      ],
    );
  }
}