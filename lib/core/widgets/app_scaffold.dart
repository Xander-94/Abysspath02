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
  final bool enableSwipeBack;  // 是否启用滑动返回
  final double elevation;  // AppBar 阴影
  final Widget? floatingActionButton;  // 悬浮按钮
  final FloatingActionButtonLocation? floatingActionButtonLocation;  // 悬浮按钮位置

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
    this.enableSwipeBack = true,
    this.elevation = 0.5,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);

    Widget scaffold = Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      drawer: drawer,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: elevation,
        centerTitle: true,  // 标题居中
        title: Text(title, style: theme.textTheme.titleLarge),
        leading: leading ?? (showBackButton ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ) : null),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context, theme) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );

    // 添加滑动返回手势
    if (enableSwipeBack && showBackButton) {
      return WillPopScope(
        onWillPop: () async {
          if (context.canPop()) {
            context.pop();
            return false;
          }
          return true;
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentPath),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      backgroundColor: Colors.white,
      elevation: 8,  // 增加阴影
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,  // 始终显示标签
      animationDuration: const Duration(milliseconds: 400),  // 动画时长
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, size: 24),
          selectedIcon: Icon(Icons.home, size: 24),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined, size: 24),
          selectedIcon: Icon(Icons.school, size: 24),
          label: '学习',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment_outlined, size: 24),
          selectedIcon: Icon(Icons.assessment, size: 24),
          label: '评估',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined, size: 24),
          selectedIcon: Icon(Icons.account_circle, size: 24),
          label: '账户',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_search_outlined, size: 24),
          selectedIcon: Icon(Icons.person_search, size: 24),
          label: '画像',
        ),
      ],
    );
  }

  int _getSelectedIndex(String currentPath) => switch (currentPath) {
    '/' => 0,
    '/learning-path' => 1,
    '/assessment' => 2,
    '/settings' => 3,
    '/profile' => 4,
    _ => 0,
  };

  void _onItemTapped(BuildContext context, int index) {
    final path = switch (index) {
      0 => '/',
      1 => '/learning-path',
      2 => '/assessment',
      3 => '/settings',
      4 => '/profile',
      _ => '/',
    };
    context.go(path);
  }
} 
 