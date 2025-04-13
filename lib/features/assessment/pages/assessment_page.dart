import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_scaffold.dart';

class AssessmentPage extends ConsumerWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: '能力评估',
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAssessmentCard(
            context,
            icon: Icons.assignment,
            title: '通用问卷',
            description: '基础能力评估问卷',
            color: const Color(0xFF2082FF),  // 莱茵蓝
            onTap: () => context.go('/assessment/general'),
          ),
          _buildAssessmentCard(
            context,
            icon: Icons.check_circle,
            title: '多选问卷',
            description: '专项技能评估',
            color: const Color(0xFF00B8D4),  // 青色
            onTap: () => context.go('/assessment/multiple'),
          ),
          _buildAssessmentCard(
            context,
            icon: Icons.chat,
            title: '对话评估',
            description: 'AI对话能力评估',
            color: const Color(0xFF7C4DFF),  // 紫色
            onTap: () => context.go('/assessment/conversation'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}