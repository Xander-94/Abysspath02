import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);  // 全局状态管理底部导航索引

class AppScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showBottomNav;
  final Widget? drawer;
  final Widget? leading;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.showBottomNav = true,
    this.drawer,
    this.leading,
    this.scaffoldKey,
    this.backgroundColor,
  });

  void _onNavTap(BuildContext context, WidgetRef ref, int index) {
    ref.read(bottomNavIndexProvider.notifier).state = index;
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/learning-path'); break;
      case 2: context.go('/assessment'); break;
      case 3: context.go('/profile'); break;
      case 4: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      drawer: drawer,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(title),
        leading: leading ?? (showBackButton ? IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ) : null),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentPath),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: '学习',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: '评估',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }

  int _getSelectedIndex(String currentPath) {
    switch (currentPath) {
      case '/':
        return 0;
      case '/learning-path':
        return 1;
      case '/assessment':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    String path;
    switch (index) {
      case 0:
        path = '/';
        break;
      case 1:
        path = '/learning-path';
        break;
      case 2:
        path = '/assessment';
        break;
      case 3:
        path = '/profile';
        break;
      default:
        path = '/';
    }
    context.go(path);
  }
} 
 