import 'package:flutter_riverpod/flutter_riverpod.dart';

class LearningPathState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> conversations;

  const LearningPathState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
  });

  LearningPathState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? conversations,
  }) {
    return LearningPathState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
    );
  }
}

class LearningPathNotifier extends StateNotifier<LearningPathState> {
  LearningPathNotifier() : super(const LearningPathState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 从数据库加载对话历史
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
      state = state.copyWith(
        isLoading: false,
        conversations: [
          {
            'id': '1',
            'title': 'Flutter基础入门',
            'lastMessage': '如何开始学习Flutter？',
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          },
          {
            'id': '2',
            'title': 'Dart语言精通',
            'lastMessage': 'Dart的异步编程',
            'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          },
          // 添加更多示例对话
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载对话历史失败：$e',
      );
    }
  }

  Future<void> createNewConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 创建新对话
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟创建
      final newConversation = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': '新的学习路径',
        'lastMessage': '开始新的学习之旅',
        'timestamp': DateTime.now(),
      };
      state = state.copyWith(
        isLoading: false,
        conversations: [newConversation, ...state.conversations],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '创建新对话失败：$e',
      );
    }
  }
}

final learningPathProvider = StateNotifierProvider<LearningPathNotifier, LearningPathState>((ref) {
  return LearningPathNotifier();
});