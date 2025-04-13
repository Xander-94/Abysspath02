import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../providers/learning_path_provider.dart';

/// 学习路径页面 - 显示学习路径列表或详情
class LearningPathPage extends ConsumerStatefulWidget {
  const LearningPathPage({super.key});

  @override
  ConsumerState<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends ConsumerState<LearningPathPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(learningPathProvider.notifier).loadConversations());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningPathProvider);

    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      title: '学习路径',
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () async {
            await ref.read(learningPathProvider.notifier).createNewConversation();
            if (mounted) {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          },
        ),
      ],
      drawer: _buildHistoryDrawer(state),
      body: Column(
        children: [
          Expanded(
            child: _buildChatPanel(),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  // 历史对话抽屉
  Widget _buildHistoryDrawer(LearningPathState state) {
    if (state.isLoading) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Drawer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(learningPathProvider.notifier).loadConversations();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.route, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text('历史学习路径', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final timestamp = conversation['timestamp'] as DateTime;
                final isRecent = DateTime.now().difference(timestamp).inDays < 7;
                
                return ListTile(
                  leading: Icon(
                    Icons.history,
                    color: isRecent ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    conversation['title'] as String,
                    style: TextStyle(
                      color: isRecent ? AppColors.textPrimary : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    isRecent ? '7天内' : '30天内',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRecent ? AppColors.textSecondary : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/learning-path/${conversation['id']}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 对话面板
  Widget _buildChatPanel() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.route, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                '嗨！我是你的学习路径助手',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我可以帮你规划学习路径、跟踪学习进度',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  // 底部输入框
  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: '输入你想学习的内容...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 1,
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
              onPressed: () {
                final message = _inputController.text.trim();
                if (message.isNotEmpty) {
                  // TODO: 发送消息
                  _inputController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}