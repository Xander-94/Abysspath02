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
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(learningPathProvider.notifier).loadConversations());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部 (与评估页面一致)
  void _scrollToBottom() { 
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () { // 延迟确保渲染完成
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // 滚动到底部
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningPathProvider);
    // 监听消息长度变化
    ref.listen(learningPathProvider.select((s) => s.messages.length), (_, __) { 
      // 在帧结束后调用滚动，确保列表已更新
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

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
              key: ValueKey(state.conversations.length),
              padding: const EdgeInsets.all(8),
              itemCount: state.conversations.length,
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
                          content: const Text('确定要删除这条学习路径吗？此操作不可恢复。'),
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
                    ref.read(learningPathProvider.notifier)
                        .deletePath(conversation['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('已删除学习路径'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRecent ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      child: Icon(Icons.route,
                          color: isRecent ? AppColors.primary : Colors.grey),
                    ),
                    title: Text(
                      conversation['title'] ?? '未命名路径',
                      style: TextStyle(
                        color: isRecent ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      isRecent ? '最近7天' : '30天内',
                      style: TextStyle(
                        fontSize: 12,
                        color: isRecent ? AppColors.textSecondary : Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(learningPathProvider.notifier).selectPath(conversation['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 对话面板 - 仿照评估页面重构
  Widget _buildChatPanel() {
    final state = ref.watch(learningPathProvider);
    
    // !! 修改判断逻辑 !!
    // 1. 如果当前没有选中的路径ID，则显示欢迎/空状态提示
    if (state.currentPathId == null) {
      // (如果需要区分初次加载和无路径，可以结合 state.isLoading)
       return Container(
          color: const Color(0xFFF5F5F5),
          child: Center( // 使用 Center 包裹欢迎信息
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  '输入你的学习目标，开始规划吧！',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                    onPressed: () async {
                      // 触发创建新会话的动作，但不发送消息
                      await ref.read(learningPathProvider.notifier).createNewConversation();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('或先创建新路径'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                    ),
                ),
                const Spacer(), // 推到底部
              ],
            ),
          ),
       );
    }
    
    // 2. 如果有选中路径ID，则总是尝试显示消息列表
    //    即使 messages 为空，ListView.builder 也会处理（显示为空列表）
    //    可以在首次加载时显示菊花图
    if (state.isLoading && state.messages.isEmpty) { 
        return const Center(child: CircularProgressIndicator());
    }
    
    // 3. 显示消息列表
    return Container(
      color: const Color(0xFFF5F5F5), // 聊天背景色
      child: ListView.builder(
        controller: _scrollController, // 关联 ScrollController
        padding: const EdgeInsets.all(16.0),
        itemCount: state.messages.length + (state.isLoading ? 1 : 0), // 如果加载中，多加一项显示加载指示
        itemBuilder: (context, index) {
          if (state.isLoading && index == state.messages.length) {
             // 在列表末尾显示加载指示器
             return _buildTypingIndicator(); 
          }
          final message = state.messages[index];
          return ChatMessageWidget(messageData: message); 
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
                onSubmitted: _handleSendMessage,
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
              onPressed: () => _handleSendMessage(_inputController.text),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage(String message) async {
    message = message.trim();
    if (message.isEmpty) return;

    _inputController.clear();
    try {
      await ref.read(learningPathProvider.notifier).sendMessage(message);
      
      print("Refreshed learningPathProvider after sendMessage on page");

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送消息失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // AI 输入指示器 (需要您提供或实现)
  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(child: Icon(Icons.computer)), // AI 头像
          SizedBox(width: 8),
          // 这里可以放一个跳动的小点动画等
          CircularProgressIndicator(strokeWidth: 2.0), 
        ],
      ),
    );
  }
}

// 假设的 ChatMessageWidget (需要您提供或实现)
// 它需要能处理 state.messages 中 Map 的 'role' 和 'content' 等字段
class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> messageData;

  const ChatMessageWidget({Key? key, required this.messageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUser = messageData['role'] == 'user';
    final messageContent = messageData['content'] ?? '';
    // final metadata = messageData['metadata'] as Map<String, dynamic>?; // 不再需要读取 metadata
    // bool isPathCreatedMessage = metadata?['type'] == 'path_created'; 

    // *** 修改：直接读取数据库返回的 is_creation_confirmation 字段 ***
    bool isPathCreatedMessage = messageData['is_creation_confirmation'] == true;
    // *** 获取 pathId 用于按钮导航，需要确保 messageData 包含 path_id ***
    String? pathIdForButton = messageData['path_id'] as String?;

    // 构建消息内容 Widget
    Widget messageTextWidget = Text(
      messageContent,
      style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary)
    );

    // 如果是路径创建确认消息，添加按钮
    List<Widget> children = [messageTextWidget];
    if (isPathCreatedMessage && pathIdForButton != null) {
      children.add(const SizedBox(height: 8)); // 添加间距
      children.add(
        ElevatedButton.icon(
          onPressed: () {
            // !! 使用正确的路由路径 !!
            context.push('/learning-path/$pathIdForButton');
            print('Navigating to detail for path: $pathIdForButton');
          },
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text('查看详情'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isUser ? Colors.white : AppColors.primary, // 按钮颜色反转
            foregroundColor: isUser ? AppColors.primary : Colors.white, // 文字颜色反转
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: const TextStyle(fontSize: 14),
          ),
        )
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isUser ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
        ),
        child: Column(
           crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min, // 让 Column 包裹内容
           children: children,
        )
      ),
    );
  }
}