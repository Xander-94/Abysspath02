import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../providers/dialogue_assessment_provider.dart';
import '../providers/assessment_profile_provider.dart'; // Import the provider
import './assessment_result_page.dart'; // Import the result page

/// 对话评估页面 - AI对话方式评估能力
/// 支持多轮对话，通过DialogueAssessmentProvider管理状态
class DialogueAssessmentPage extends ConsumerStatefulWidget {
  const DialogueAssessmentPage({super.key});

  @override
  ConsumerState<DialogueAssessmentPage> createState() => _DialogueAssessmentPageState();
}

class _DialogueAssessmentPageState extends ConsumerState<DialogueAssessmentPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 用于消息自动滚动
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
    // 初始加载历史对话列表
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

  // 消息列表滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dialogueAssessmentProvider);
    
    // 监听消息变化，自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

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
          TextButton(
            onPressed: state.isLoading ? null : _completeAssessment,
            child: Text(
              '完成评估',
              style: TextStyle(
                color: state.isLoading ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 错误提示（如果有）
          if (state.error != null)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: AppStyles.bodySmall.copyWith(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade700, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      // 清除错误信息
                      ref.read(dialogueAssessmentProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildChatPanel(state),
          ),
          _buildBottomInput(state), // 传入state用于禁用加载中的输入框
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

  void _completeAssessment() {
    ref.refresh(assessmentProfileProvider); 
    
    context.push('/assessment/result');
  }

  // 对话消息面板
  Widget _buildChatPanel(DialogueAssessmentState state) {
    // 没有消息时显示欢迎界面
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

    // 有消息时显示对话内容
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController, // 添加控制器以支持滚动到底部
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length + (state.assessmentResult != null ? 1 : 0),
          itemBuilder: (context, index) {
            // 如果有评估结果且是最后一项，显示评估结果
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
        // 显示加载指示器
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

  // 底部输入框
  Widget _buildBottomInput(DialogueAssessmentState state) {
    // 加载中禁用输入
    final bool isInputEnabled = !state.isLoading;

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
          IconButton(
            icon: Icon(Icons.psychology_outlined, 
                color: isInputEnabled ? AppColors.primary : Colors.grey),
            onPressed: isInputEnabled ? () => _handleFollowUpQuestions() : null,
            tooltip: '智能追问',
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isInputEnabled ? Colors.grey.shade100 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: isInputEnabled ? '请输入您想要评估的内容...' : 'AI正在思考中...',
                  hintStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: AppStyles.bodyMedium,
                onSubmitted: isInputEnabled ? _sendMessage : null,
                enabled: isInputEnabled,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isInputEnabled ? AppColors.primary : Colors.grey,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: isInputEnabled ? () => _sendMessage(_inputController.text) : null,
            ),
          ),
        ],
      ),
    );
  }

  // 发送消息
  void _sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      // 该方法内部已经实现了多轮对话的逻辑，包括：
      // 1. 将用户消息添加到 messagesHistory
      // 2. 将完整的 messagesHistory 发送到后端
      // 3. 接收AI回复并添加到 messagesHistory
      ref.read(dialogueAssessmentProvider.notifier).sendMessage(message.trim());
      _inputController.clear();
    }
  }

  // 处理追问请求
  void _handleFollowUpQuestions() async {
    final state = ref.read(dialogueAssessmentProvider);
    if (state.currentAssessmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先开始对话评估')),
      );
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 调用provider中的追问方法
      await ref.read(dialogueAssessmentProvider.notifier).generateFollowUpQuestions();
      if (mounted) Navigator.pop(context); // 关闭加载对话框
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成追问失败: ${e.toString()}')),
        );
      }
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

// 添加一个扩展方法到 DialogueAssessmentNotifier 类
extension DialogueAssessmentNotifierExtension on DialogueAssessmentNotifier {
  // 清除错误信息的便捷方法
  void clearError() {
    state = state.copyWith(clearError: true);
  }
} 