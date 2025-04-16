import 'package:flutter/material.dart';
import '../services/dialogue_assessment_service.dart';
import 'dart:convert';

class AssessmentDetailPage extends StatelessWidget {
  final String assessmentId;
  
  const AssessmentDetailPage({super.key, required this.assessmentId});

  Widget _buildProfileDataCard(Map<String, dynamic>? profileData) {
    if (profileData == null) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('用户画像数据', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            if (profileData['competency'] != null) ...[
              const Text('能力评估:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('技能树: ${jsonEncode(profileData['competency']['skill_tree'] ?? {})}'),
              Text('知识缺口: ${jsonEncode(profileData['competency']['knowledge_gaps'] ?? [])}'),
            ],
            if (profileData['interest_graph'] != null) ...[
              const SizedBox(height: 8),
              const Text('兴趣图谱:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('主要兴趣: ${jsonEncode(profileData['interest_graph']['primary_interests'] ?? [])}'),
            ],
            if (profileData['behavior'] != null) ...[
              const SizedBox(height: 8),
              const Text('行为特征:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('活动周期: ${profileData['behavior']['activity_cycle']}'),
              Text('内容偏好: ${profileData['behavior']['content_preference']}'),
            ],
            if (profileData['constraints'] != null) ...[
              const SizedBox(height: 8),
              const Text('约束条件:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('时间可用性: ${profileData['constraints']['time_availability']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 48 : 8,
        right: isUser ? 8 : 48,
        top: 4,
        bottom: 4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(text, style: TextStyle(
        color: isUser ? Colors.blue.shade900 : Colors.green.shade900,
        fontSize: 15,
      )),
    );
  }

  Widget _buildInteractionCard(Map<String, dynamic> interaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade600,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  Expanded(
                    child: _buildMessageBubble(interaction['user_message'], true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade600,
                    child: const Icon(Icons.smart_toy, color: Colors.white),
                  ),
                  Expanded(
                    child: _buildMessageBubble(interaction['ai_response'], false),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Text(
                  '时间: ${DateTime.parse(interaction['created_at']).toLocal().toString().substring(0, 19)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              if (interaction['profile_data'] != null) ...[
                const Divider(height: 24),
                _buildProfileDataCard(interaction['profile_data']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评估详情'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('评估说明'),
                  content: const Text(
                    '1. 每次对话都会更新用户画像数据\n'
                    '2. 绿色区域显示AI的回复\n'
                    '3. 蓝色区域显示用户的提问\n'
                    '4. 每次对话后会显示更新的用户画像数据'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('了解'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: FutureBuilder<Map<String, dynamic>>(
          future: DialogueAssessmentService().getAssessmentDetail(assessmentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text('加载失败: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              );
            }
            
            final data = snapshot.data!;
            final interactions = (data['assessment_interactions'] as List<dynamic>)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            
            if (interactions.isEmpty) {
              return const Center(
                child: Text('暂无评估记录', 
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              );
            }

            return ListView.builder(
              itemCount: interactions.length,
              itemBuilder: (context, index) => _buildInteractionCard(interactions[index]),
            );
          },
        ),
      ),
    );
  }
} 