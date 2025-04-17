import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../profile/providers/profile_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: '设置',
      showBottomNav: true,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {
                // TODO: 实现主题切换
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            trailing: const Text('中文'),
            onTap: () {
              // TODO: 实现语言切换
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知设置'),
            onTap: () {
              // TODO: 实现通知设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () {
              // TODO: 实现关于页面
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('退出登录', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () => _handleSignOut(context, ref),
          ),
        ],
      ),
    );
  }

  void _handleSignOut(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(profileProvider.notifier).signOut();
    if (!success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('退出登录失败，请重试')));
      return;
    }
    if (!context.mounted) return;
    context.go('/login');
  }
} 