import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../providers/dialogue_assessment_provider.dart';

/// 对话评估页面 - AI对话方式评估能力
class DialogueAssessmentPage extends ConsumerStatefulWidget {
  const DialogueAssessmentPage({super.key});

  @override
  ConsumerState<DialogueAssessmentPage> createState() => _DialogueAssessmentPageState();
}

class _DialogueAssessmentPageState extends ConsumerState<DialogueAssessmentPage> {
  final TextEditingController _inputController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
    Future.microtask(() => ref.read(dialogueAssessmentProvider.notifier).loadConversations());
  }

  void _checkAuth() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Future.microtask(() {
        context.go('/auth/login', extra: {'returnTo': '/assessment/dialogue'});
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dialogueAssessmentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text('对话评估', style: AppStyles.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppColors.primary),
            onPressed: () => _showHistoryDialog(context, state),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _startNewAssessment(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatPanel(state),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, DialogueAssessmentState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('历史评估记录', style: AppStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        final timestamp = DateTime.parse(conversation['created_at']);
                        final isRecent = DateTime.now().difference(timestamp).inDays < 7;
                        
                        return Dismissible(
                          key: Key(conversation['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('确认删除'),
                                  content: const Text('确定要删除这条对话记录吗？此操作不可恢复。'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('删除', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            ref.read(dialogueAssessmentProvider.notifier)
                                .deleteConversation(conversation['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('已删除对话记录'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isRecent ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              child: Icon(Icons.chat,
                                  color: isRecent ? AppColors.primary : Colors.grey),
                            ),
                            title: Text(
                              conversation['title'] ?? '未命名对话',
                              style: AppStyles.bodyMedium.copyWith(
                                color: isRecent ? AppColors.textPrimary : Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              isRecent ? '最近7天' : '30天内',
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: AppColors.textSecondary),
                            onTap: () {
                              Navigator.pop(context);
                              ref.read(dialogueAssessmentProvider.notifier)
                                  .loadConversation(conversation['id']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewAssessment() async {
    await ref.read(dialogueAssessmentProvider.notifier).createNewConversation();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已开始新的对话评估'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 对话面板
  Widget _buildChatPanel(DialogueAssessmentState state) {
    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.chat,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              '开始AI对话评估',
              style: AppStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '通过智能对话的方式，评估您的学习能力和知识掌握程度',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startNewAssessment,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('开始新对话'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length + (state.assessmentResult != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.messages.length && state.assessmentResult != null) {
              return _buildAssessmentResult(state.assessmentResult!);
            }

            final message = state.messages[index];
            final isUser = message['isUser'] as bool;
            
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message['content'] as String,
                  style: AppStyles.bodyMedium.copyWith(
                    color: isUser ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        if (state.isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI正在思考中...',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '请输入您想要评估的内容...',
                  hintStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: AppStyles.bodyMedium,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_inputController.text),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      ref.read(dialogueAssessmentProvider.notifier).sendMessage(message.trim());
      _inputController.clear();
    }
  }

  Widget _buildAssessmentResult(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('评估结果', style: AppStyles.titleMedium),
            ],
          ),
          if (result['summary'] != null) ...[
            const SizedBox(height: 16),
            Text('总体评价', style: AppStyles.titleSmall),
            const SizedBox(height: 8),
            Text(
              result['summary'] as String,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (result['skillProficiency'] != null) ...[
            const SizedBox(height: 16),
            Text('技能熟练度', style: AppStyles.titleSmall),
            const SizedBox(height: 8),
            ...(result['skillProficiency'] as Map<String, dynamic>).entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value as double,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 