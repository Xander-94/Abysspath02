import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dialogue_assessment_service.dart';

class DialogueAssessmentState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> conversations;  // 历史对话列表
  final List<Map<String, dynamic>> messages;       // 当前对话消息列表
  final String? currentAssessmentId;              // 当前评估ID
  final Map<String, dynamic>? assessmentResult;   // 评估结果

  const DialogueAssessmentState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.messages = const [],
    this.currentAssessmentId,
    this.assessmentResult,
  });

  DialogueAssessmentState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? messages,
    String? currentAssessmentId,
    Map<String, dynamic>? assessmentResult,
  }) {
    return DialogueAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      currentAssessmentId: currentAssessmentId ?? this.currentAssessmentId,
      assessmentResult: assessmentResult ?? this.assessmentResult,
    );
  }
}

class DialogueAssessmentNotifier extends StateNotifier<DialogueAssessmentState> {
  final DialogueAssessmentService _service;

  DialogueAssessmentNotifier(this._service) : super(const DialogueAssessmentState());

  // 加载历史对话
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversations = await _service.getHistoryConversations();
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

  // 创建新对话
  Future<void> createNewConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final assessment = await _service.startAssessment();
      state = state.copyWith(
        isLoading: false,
        currentAssessmentId: assessment['id'],
        messages: [],
        assessmentResult: null,
      );
      
      // 添加AI的开场白
      final welcomeMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': '你好！我是AI评估助手。我将通过对话的方式评估您的学习能力和知识掌握程度。请告诉我您想了解哪个领域的知识？',
        'isUser': false,
        'timestamp': DateTime.now(),
      };
      state = state.copyWith(
        messages: [welcomeMessage],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 发送消息
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (state.currentAssessmentId == null) {
      await createNewConversation();
    }
    
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': message,
      'isUser': true,
      'timestamp': DateTime.now(),
    };

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );

    state = state.copyWith(isLoading: true);
    try {
      final response = await _service.submitDialogue(
        assessmentId: state.currentAssessmentId!,
        message: message,
      );

      final aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': response['interaction']['aiResponse'] ?? '抱歉，我现在无法回答这个问题。',
        'isUser': false,
        'timestamp': DateTime.now(),
      };

      state = state.copyWith(
        isLoading: false,
        messages: [...state.messages, aiResponse],
      );

      // 如果评估完成，获取评估结果
      if (response['isComplete'] == true) {
        await _loadAssessmentResult();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载历史对话内容
  Future<void> loadConversation(String assessmentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.getAssessmentResult(assessmentId);
      final interactions = List<Map<String, dynamic>>.from(result['interactions'] ?? []);
      
      final messages = interactions.expand((interaction) => [
        {
          'id': '${interaction['id']}_user',
          'content': interaction['userResponse'],
          'isUser': true,
          'timestamp': DateTime.parse(interaction['timestamp']),
        },
        {
          'id': '${interaction['id']}_ai',
          'content': interaction['aiResponse'],
          'isUser': false,
          'timestamp': DateTime.parse(interaction['timestamp']),
        },
      ]).toList();

      state = state.copyWith(
        isLoading: false,
        currentAssessmentId: assessmentId,
        messages: messages,
        assessmentResult: result['userProfile'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载评估结果
  Future<void> _loadAssessmentResult() async {
    if (state.currentAssessmentId == null) return;
    
    try {
      final result = await _service.getAssessmentResult(state.currentAssessmentId!);
      state = state.copyWith(
        assessmentResult: result['userProfile'],
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  // 删除对话
  Future<void> deleteConversation(String assessmentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deleteConversation(assessmentId);
      // 从列表中移除已删除的对话
      final updatedConversations = state.conversations
          .where((conv) => conv['id'] != assessmentId)
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

final dialogueAssessmentProvider = StateNotifierProvider<DialogueAssessmentNotifier, DialogueAssessmentState>((ref) {
  return DialogueAssessmentNotifier(DialogueAssessmentService());
}); 