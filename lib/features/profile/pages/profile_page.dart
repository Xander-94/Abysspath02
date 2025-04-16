import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile.dart';
import '../providers/profile_notifier.dart';
import '../services/profile_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../widgets/profile_avatar.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ProfileService());
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading) {
      return AppScaffold(
        title: '个人中心',
        showBottomNav: true,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (profileState.error != null) {
      return AppScaffold(
        title: '个人中心',
        showBottomNav: true,
        body: Center(child: Text('加载失败: ${profileState.error}')),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return AppScaffold(
        title: '个人中心',
        showBottomNav: true,
        body: const Center(child: Text('未找到个人信息')),
      );
    }

    return AppScaffold(
      title: '个人中心',
      showBottomNav: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: ProfileAvatar(
            url: profile.avatar,
            size: 100,
            onTap: () => _showEditDialog(context, profile, isAvatar: true),
          )),
          const SizedBox(height: 16),
          ListTile(
            title: Text('用户名'),
            subtitle: Text(profile.name ?? '未设置'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, profile),
            ),
          ),
          ListTile(
            title: Text('邮箱'),
            subtitle: Text(profile.email ?? '未设置'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password),
            title: Text('修改密码'),
            onTap: () => _showChangePasswordDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('退出登录'),
            onTap: () => _handleSignOut(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Profile profile, {bool isAvatar = false}) async {
    final controller = TextEditingController(
      text: isAvatar ? profile.avatar : profile.name,
    );
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAvatar ? '修改头像' : '修改用户名'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isAvatar ? '请输入头像URL' : '请输入用户名',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final notifier = ref.read(profileProvider.notifier);
      final success = await notifier.updateProfile(
        name: isAvatar ? null : result,
        avatar: isAvatar ? result : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '更新成功' : '更新失败'),
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '请输入新密码',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '请确认新密码',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('两次输入的密码不一致')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text('确定'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final notifier = ref.read(profileProvider.notifier);
      final success = await notifier.changePassword(passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '密码修改成功' : '密码修改失败'),
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认退出'),
        content: Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(profileProvider.notifier).signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }
}