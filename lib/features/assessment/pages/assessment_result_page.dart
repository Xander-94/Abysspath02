import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abysspath02/features/assessment/providers/assessment_profile_provider.dart';
import 'package:abysspath02/features/assessment/models/assessment_profile.dart';

class AssessmentResultPage extends ConsumerWidget {
  const AssessmentResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentProfileAsync = ref.watch(assessmentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 评估结果'),
      ),
      body: assessmentProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
           print('Error loading assessment profile: $err'); // Log error
           print('Stacktrace: $stack');
           return Center(child: Text('加载评估结果失败: $err'));
        },
        data: (profile) {
          if (profile == null) {
            // 处理没有找到评估数据的情况
            return const Center(
              child: Text(
                '未找到您的 AI 评估记录。\n请先完成一次对话评估。',
                textAlign: TextAlign.center,
              ),
            );
          }
          // 如果有数据，构建展示 UI
          return _buildProfileDisplay(context, profile);
        },
      ),
    );
  }

  Widget _buildProfileDisplay(BuildContext context, AssessmentProfile profile) {
    // Handle cases where coreAnalysis or behavioralProfile might be null
    final coreAnalysis = profile.coreAnalysis;
    final behavioralProfile = profile.behavioralProfile;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (coreAnalysis != null) ...[
          _buildSectionTitle(context, '核心能力分析'),
          _buildCompetencies(context, coreAnalysis.competencies),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '兴趣领域'),
          if (coreAnalysis.interestLayers != null)
            _buildInterests(context, coreAnalysis.interestLayers!)
          else
            const Text('暂无兴趣领域数据'),
          const SizedBox(height: 16),
        ] else ...[
          _buildSectionTitle(context, '核心分析'),
          const Text('暂无核心分析数据'),
          const SizedBox(height: 16),
        ],
        
        if (behavioralProfile != null) ...[
          _buildSectionTitle(context, '行为与个性'),
          _buildHobbies(context, behavioralProfile.hobbies),
          _buildPersonality(context, behavioralProfile.personality),
        ] else ...[
           _buildSectionTitle(context, '行为与个性'),
           const Text('暂无行为与个性数据'),
        ],
        // TODO: Add AI suggestions display here
      ],
    );
  }

  // --- Helper Widgets for building sections ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildCompetencies(BuildContext context, List<Competency> competencies) {
    if (competencies.isEmpty) {
      return const Text('暂无能力信息');
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: competencies.map((comp) => ListTile(
            title: Text(comp.name),
            subtitle: Text('等级: ${comp.level} ${comp.validation.isNotEmpty ? "(${comp.validation.join(', ')})" : ""}'),
            leading: const Icon(Icons.star_border), // Example icon
          )).toList(),
        ),
      ),
    );
  }

   Widget _buildInterests(BuildContext context, InterestLayers interests) {
     final List<String> allInterests = [...interests.explicit, ...interests.implicit];
     if (allInterests.isEmpty) {
       return const Text('暂无具体兴趣信息');
     }
     return Card(
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Wrap(
           spacing: 8.0,
           runSpacing: 4.0,
           children: allInterests.map((interest) => Chip(label: Text(interest))).toList(),
         ),
       ),
     );
   }

  Widget _buildHobbies(BuildContext context, List<Hobby> hobbies) {
    if (hobbies.isEmpty) {
      return const SizedBox.shrink(); // 如果没有爱好，不显示
    }
     return Card(
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("爱好:", style: Theme.of(context).textTheme.titleMedium),
             const SizedBox(height: 8),
             ...hobbies.map((hobby) => ListTile(
               title: Text(hobby.name),
               subtitle: Text('频率: ${hobby.engagement.frequency ?? '未知'}, 社交: ${hobby.engagement.socialImpact ?? '未知'}'),
               dense: true,
             )).toList(),
           ],
         ),
       ),
     );
  }

   Widget _buildPersonality(BuildContext context, Personality personality) {
     if (personality.strengths.isEmpty && personality.conflicts.isEmpty) {
       return const Text('暂无个性信息');
     }
     return Card(
        margin: const EdgeInsets.only(top: 8.0), // Add margin if hobbies exist
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text("个性特点:", style: Theme.of(context).textTheme.titleMedium),
              if (personality.strengths.isNotEmpty) ...[
                 const SizedBox(height: 8),
                 Text("优点: ${personality.strengths.join(', ')}"),
              ],
              if (personality.conflicts.isNotEmpty) ...[
                 const SizedBox(height: 8),
                 Text("潜在冲突: ${personality.conflicts.join(', ')}", style: const TextStyle(color: Colors.orange)), // Highlight conflicts
              ],
           ],
         ),
       ),
     );
   }
} 