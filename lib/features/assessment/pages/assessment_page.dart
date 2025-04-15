import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '能力评估',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAssessmentCard(
            context,
            title: '通用问卷',
            subtitle: '基础能力评估问卷',
            description: '全面评估您的学习能力、兴趣和目标，包含基础信息、能力评估、兴趣图谱、学习模式等多个维度',
            color: Colors.blue,
            icon: Icons.assignment,
            onTap: () async {
              final supabase = Supabase.instance.client;
              try {
                final surveyData = await supabase
                    .from('surveys')
                    .select('id')
                    .eq('title', '通用学习能力评估问卷')
                    .single();
                
                if (context.mounted) {
                  context.push('/survey/${surveyData['id']}');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('获取问卷失败，请稍后重试')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _buildAssessmentCard(
            context,
            title: '多选问卷',
            subtitle: '专项技能评估',
            description: '针对特定领域的专项技能评估，帮助您了解在该领域的具体能力水平',
            color: Colors.teal,
            icon: Icons.check_circle,
            onTap: () async {
              final supabase = Supabase.instance.client;
              try {
                final surveyData = await supabase
                    .from('surveys')
                    .select('id')
                    .eq('title', '学习者画像多选问卷')
                    .single();
                
                if (context.mounted) {
                  context.push('/survey/${surveyData['id']}');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('获取问卷失败，请稍后重试')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _buildAssessmentCard(
            context,
            title: '对话评估',
            subtitle: 'AI对话能力评估',
            description: '通过智能对话的方式，评估您的学习能力和知识掌握程度',
            color: Colors.purple,
            icon: Icons.chat,
            onTap: () => context.push('/assessment/dialogue'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}