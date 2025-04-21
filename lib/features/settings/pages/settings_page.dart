import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../profile/providers/profile_notifier.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: '设置', // TODO: 国际化/常量化
      showBottomNav: true,
      body: ListView(
        children: [
          // -- 通用设置 --
          const _SettingsSectionHeader(title: '通用'), // 分组标题
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined),
            title: const Text('通知设置'), // TODO: 国际化/常量化
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 跳转到通知设置页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知设置功能待开发')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于 AbyssPath'), // TODO: 国际化/常量化
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 显示关于对话框或页面
              showAboutDialog(
                context: context,
                applicationName: 'AbyssPath',
                applicationVersion: '1.0.0', // TODO: 从配置读取版本号
                applicationLegalese: '© 2024 AbyssPath Team', // TODO: 更新版权信息
              );
            },
          ),
          const Divider(height: 32), // 分隔线
          
          // -- 账户操作 --
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              '退出登录', // TODO: 国际化/常量化
              style: TextStyle(color: Theme.of(context).colorScheme.error)
            ),
            onTap: () => _showSignOutConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  // 显示退出登录确认对话框
  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认退出？'),
          content: const Text('您确定要退出当前账号吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: Text(
                '退出',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // 关闭对话框
                _handleSignOut(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  // 处理退出登录逻辑
  void _handleSignOut(BuildContext context, WidgetRef ref) async {
    // 显示加载指示器（可选）
    // ...

    final success = await ref.read(profileProvider.notifier).signOut();
    
    // 隐藏加载指示器（可选）
    // ...

    if (!context.mounted) return; // 异步操作后检查mounted
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退出登录失败，请重试'))
      );
    } else {
      context.go('/login'); // 退出成功后跳转
      // 可能需要显示一个短暂的成功提示
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('已成功退出登录'))
      // );
    }
  }
}

/// 设置分组标题 (StatelessWidget)
class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0, 
        right: 16.0, 
        top: 24.0, // 增加上边距
        bottom: 8.0
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // 使用主题色
        ),
      ),
    );
  }
} 