import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/learning_path_service.dart';

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

  Future<void> createNewConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPath = await _service.createPath();
      state = state.copyWith(
        isLoading: false,
        conversations: [newPath, ...state.conversations],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final learningPathProvider = StateNotifierProvider<LearningPathNotifier, LearningPathState>((ref) {
  return LearningPathNotifier(LearningPathService());
});