import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// 应用程序根组件
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Abyss Path',
      theme: AppTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,  // 移除调试标记
    );
  }
} 