import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_scaffold.dart';

class LearningPathDetailPage extends ConsumerWidget {
  final String pathId;

  const LearningPathDetailPage({
    super.key,
    required this.pathId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: '路径详情',
      showBackButton: true,  // 显示返回按钮
      showBottomNav: false,  // 子页面不显示底部导航
      body: Center(
        child: Text('路径详情页面 - ID: $pathId'),
      ),
    );
  }
} 
 
 
 