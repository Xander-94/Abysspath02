import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abysspath02/core/theme/app_colors.dart'; // Import AppColors
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
    final coreAnalysis = profile.coreAnalysis;
    final behavioralProfile = profile.behavioralProfile;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Adjust padding
      children: [
        if (coreAnalysis != null) ...[
          _buildSectionTitle(context, '核心能力分析', Icons.analytics_outlined),
          _buildCompetencies(context, coreAnalysis.competencies),
          const SizedBox(height: 20), // Increase spacing
          _buildSectionTitle(context, '兴趣领域', Icons.interests_outlined),
          if (coreAnalysis.interestLayers != null)
            _buildInterests(context, coreAnalysis.interestLayers!)
          else
            const Text('暂无兴趣领域数据'),
          const SizedBox(height: 20), // Increase spacing
        ] else ...[
          _buildSectionTitle(context, '核心分析', Icons.analytics_outlined),
          const Text('暂无核心分析数据'),
          const SizedBox(height: 20),
        ],
        
        if (behavioralProfile != null) ...[
          _buildSectionTitle(context, '行为与个性', Icons.person_outline),
          _buildHobbies(context, behavioralProfile.hobbies),
          _buildPersonality(context, behavioralProfile.personality),
        ] else ...[
           _buildSectionTitle(context, '行为与个性', Icons.person_outline),
           const Text('暂无行为与个性数据'),
        ],
      ],
    );
  }

  // --- Helper Widgets for building sections ---

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Adjust spacing
      child: Row( // Use Row for icon and title
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), // Make title bolder
          ),
        ],
      ),
    );
  }

  // Helper to map level string to star rating (example)
  int _getStarsForLevel(String level) {
    switch (level) {
      case '入门': return 1;
      case '中级': return 2;
      case '熟练': return 3;
      case '精通': return 4;
      default: return 0;
    }
  }

  Widget _buildCompetencies(BuildContext context, List<Competency> competencies) {
    if (competencies.isEmpty) {
      return const Text('暂无能力信息');
    }
    return Card(
      elevation: 1, // Slightly reduce elevation for a flatter look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Add rounded corners
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: competencies.map((comp) {
            int stars = _getStarsForLevel(comp.level);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0), // Adjust ListTile padding
              title: Text(comp.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text('等级: ${comp.level} ${comp.validation.isNotEmpty ? "(${comp.validation.join(', ')})" : ""}', style: Theme.of(context).textTheme.bodySmall),
              leading: Row( // Use Row for stars
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: index < stars ? Colors.amber : Colors.grey.shade400,
                      size: 18,
                  )),
              ),
            );
          }).toList(),
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
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Wrap(
           spacing: 8.0, 
           runSpacing: 8.0, // Increase run spacing
           children: allInterests.map((interest) => Chip(
             label: Text(interest),
             backgroundColor: AppColors.primary.withOpacity(0.1),
             labelStyle: TextStyle(color: AppColors.primary, fontSize: 12), // Smaller font
             side: BorderSide(color: AppColors.primary.withOpacity(0.3)), // Subtle border
             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding
            )).toList(),
         ),
       ),
     );
   }

  Widget _buildHobbies(BuildContext context, List<Hobby> hobbies) {
    if (hobbies.isEmpty) {
      return const SizedBox.shrink(); 
    }
     return Card(
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("爱好:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
             const SizedBox(height: 8),
             ...hobbies.map((hobby) => Padding(
               padding: const EdgeInsets.only(bottom: 4.0),
               child: Text('• ${hobby.name} (频率: ${hobby.engagement.frequency ?? '未知'}, 社交: ${hobby.engagement.socialImpact ?? '未知'})', style: Theme.of(context).textTheme.bodyMedium),
             )).toList(),
           ],
         ),
       ),
     );
  }

   Widget _buildPersonality(BuildContext context, Personality personality) {
     final hasStrengths = personality.strengths.isNotEmpty;
     final hasConflicts = personality.conflicts.isNotEmpty;
     if (!hasStrengths && !hasConflicts) {
       return const Text('暂无个性信息');
     }
     return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(top: 12.0), // Add margin if hobbies exist
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text("个性特点:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              if (hasStrengths) ...[
                 const SizedBox(height: 8),
                 Row( // Use Row for icon
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.green.shade600),
                     const SizedBox(width: 6),
                     Expanded(child: Text("优点: ${personality.strengths.join(', ')}", style: Theme.of(context).textTheme.bodyMedium)),
                   ],
                 ),
              ],
              if (hasConflicts) ...[
                 const SizedBox(height: 8),
                 Row( // Use Row for icon
                    crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                     const SizedBox(width: 6),
                     Expanded(child: Text("潜在冲突: ${personality.conflicts.join(', ')}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange.shade800))), // Highlight conflicts
                   ],
                 ),
              ],
           ],
         ),
       ),
     );
   }
} 