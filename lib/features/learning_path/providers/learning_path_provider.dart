import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/learning_path_service.dart';

class LearningPathState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> conversations;
  final String? currentPathId;  // 当前选中的路径ID
  final List<Map<String, dynamic>> messages;  // 当前路径的消息列表

  const LearningPathState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.currentPathId,
    this.messages = const [],
  });

  LearningPathState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? conversations,
    String? currentPathId,
    List<Map<String, dynamic>>? messages,
  }) {
    return LearningPathState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
      currentPathId: currentPathId ?? this.currentPathId,
      messages: messages ?? this.messages,
    );
  }
}

class LearningPathNotifier extends StateNotifier<LearningPathState> {
  final LearningPathService _service;

  LearningPathNotifier(this._service) : super(const LearningPathState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversations = await _service.getHistoryPaths();
      state = state.copyWith(
        isLoading: false,
        conversations: conversations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>?> createNewConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPath = await _service.createPath();
      state = state.copyWith(
        isLoading: false,
        conversations: [newPath, ...state.conversations],
        currentPathId: newPath['id'],  // 设置为当前路径
        messages: [],  // 清空消息列表
      );
      return newPath;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<void> deletePath(String pathId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deletePath(pathId);
      final updatedConversations = state.conversations
          .where((conv) => conv['id'] != pathId)
          .toList();
      
      state = state.copyWith(
        isLoading: false,
        conversations: updatedConversations,
        currentPathId: pathId == state.currentPathId ? null : state.currentPathId,
        messages: pathId == state.currentPathId ? [] : state.messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectPath(String pathId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _service.getPathMessages(pathId);
      state = state.copyWith(
        isLoading: false,
        currentPathId: pathId,
        messages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (state.currentPathId == null) {
      // 如果没有当前路径，先创建一个
      final newPath = await createNewConversation();
      if (newPath == null) return;
    }

    // 立即添加用户消息到状态
    final userMessage = {
      'role': 'user',
      'content': message,
      'created_at': DateTime.now().toIso8601String(),
      'path_id': state.currentPathId,
    };
    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );

    try {
      final response = await _service.sendMessage(state.currentPathId!, message);
      
      // 重新加载消息列表和会话列表
      final messages = await _service.getPathMessages(state.currentPathId!);
      final conversations = await _service.getHistoryPaths();
      
      state = state.copyWith(
        isLoading: false,
        messages: messages,
        conversations: conversations,
      );
    } catch (e) {
      // 发生错误时，移除临时添加的用户消息
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        messages: state.messages.where((m) => m != userMessage).toList(),
      );
    }
  }
}

final learningPathProvider = StateNotifierProvider<LearningPathNotifier, LearningPathState>((ref) {
  return LearningPathNotifier(LearningPathService());
});