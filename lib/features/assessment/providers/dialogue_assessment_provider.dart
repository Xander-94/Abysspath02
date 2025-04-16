import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dialogue_assessment_service.dart';
import 'dart:developer'; // 使用 dart:developer 替代 print

class DialogueAssessmentState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> conversations;  // 历史对话列表
  final List<Map<String, dynamic>> messages;       // 当前对话 UI 消息列表
  final List<Map<String, String>> deepseekMessagesHistory; // Deepseek格式的消息历史
  final String? currentAssessmentId;              // 当前评估ID
  final Map<String, dynamic>? assessmentResult;   // 评估结果

  const DialogueAssessmentState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.messages = const [],
    this.deepseekMessagesHistory = const [], // 初始化
    this.currentAssessmentId,
    this.assessmentResult,
  });

  DialogueAssessmentState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? messages,
    List<Map<String, String>>? deepseekMessagesHistory, // 添加
    String? currentAssessmentId,
    Map<String, dynamic>? assessmentResult,
    bool clearError = false, // 添加标志以清除错误
  }) {
    return DialogueAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error, // 修改: 支持清除错误
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      deepseekMessagesHistory: deepseekMessagesHistory ?? this.deepseekMessagesHistory, // 添加
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final assessment = await _service.startAssessment();
      
      final welcomeMessageContent = '你好！我是AI评估助手。我将通过对话的方式评估您的学习能力和知识掌握程度。请告诉我您想了解哪个领域的知识？';
      final welcomeMessageUI = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': welcomeMessageContent,
        'isUser': false,
        'timestamp': DateTime.now(),
      };
      
      final initialDeepseekHistory = [
        {'role': 'assistant', 'content': welcomeMessageContent}
      ];

      state = state.copyWith(
        isLoading: false,
        currentAssessmentId: assessment['id'],
        messages: [welcomeMessageUI],
        deepseekMessagesHistory: initialDeepseekHistory,
        assessmentResult: null,
      );

    } catch (e, stackTrace) {
      log('创建新对话失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 发送消息
  Future<void> sendMessage(String messageContent) async {
    if (messageContent.trim().isEmpty) return;
    if (state.currentAssessmentId == null) {
      await createNewConversation();
      if (state.currentAssessmentId == null) return; // 如果创建失败则返回
    }
    
    final newMessageUI = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': messageContent,
      'isUser': true,
      'timestamp': DateTime.now(),
    };

    final currentDeepseekHistory = List<Map<String, String>>.from(state.deepseekMessagesHistory);
    currentDeepseekHistory.add({'role': 'user', 'content': messageContent});

    state = state.copyWith(
      messages: [...state.messages, newMessageUI],
      deepseekMessagesHistory: currentDeepseekHistory,
      isLoading: true,
      clearError: true,
    );
    
    try {
      final response = await _service.submitDialogue(
        assessmentId: state.currentAssessmentId!,
        messages: currentDeepseekHistory, // 修复: 传递 Deepseek 历史
      );

      // 检查 submitDialogue 是否成功
      if (response['success'] != true) {
         throw response['error'] ?? '提交对话时发生未知错误';
      }

      final aiResponseContent = response['interaction']?['aiResponse'] ?? '抱歉，我现在无法回答这个问题。';
      
      final aiResponseUI = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': aiResponseContent,
        'isUser': false,
        'timestamp': DateTime.now(),
      };

      currentDeepseekHistory.add({'role': 'assistant', 'content': aiResponseContent});

      state = state.copyWith(
        isLoading: false,
        messages: [...state.messages, aiResponseUI],
        deepseekMessagesHistory: currentDeepseekHistory,
      );

      if (response['isComplete'] == true) {
        await _loadAssessmentResult();
      }
    } catch (e, stackTrace) {
      log('发送消息失败', error: e, stackTrace: stackTrace);
      // 恢复 Deepseek 历史到发送前
      final previousDeepseekHistory = List<Map<String, String>>.from(state.deepseekMessagesHistory);
      if (previousDeepseekHistory.isNotEmpty && previousDeepseekHistory.last['role'] == 'user') {
          previousDeepseekHistory.removeLast();
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        // 恢复UI消息列表(移除刚才添加的用户消息)
        messages: state.messages.where((msg) => msg['id'] != newMessageUI['id']).toList(),
        deepseekMessagesHistory: previousDeepseekHistory,
      );
    }
  }

  // 加载历史对话内容
  Future<void> loadConversation(String assessmentId) async {
    state = state.copyWith(isLoading: true, clearError: true, messages: [], deepseekMessagesHistory: []);
    try {
      final result = await _service.getAssessmentResult(assessmentId);
      final interactions = List<Map<String, dynamic>>.from(result['assessment_interactions'] ?? [])
                           ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']))); // 按时间排序 interactions
      
      final uiMessages = <Map<String, dynamic>>[];
      final deepseekHistory = <Map<String, String>>[];

      for (final interaction in interactions) {
        final userTimestamp = DateTime.parse(interaction['created_at']);
        // 假设用户消息稍早于AI消息 (或使用相同时间戳)
        final aiTimestamp = userTimestamp; 

        if (interaction['user_message'] != null && (interaction['user_message'] as String).isNotEmpty) {
           uiMessages.add({
             'id': '${interaction['id']}_user',
             'content': interaction['user_message'],
             'isUser': true,
             'timestamp': userTimestamp,
           });
           deepseekHistory.add({'role': 'user', 'content': interaction['user_message'] ?? ''});
        }
        if (interaction['ai_response'] != null && (interaction['ai_response'] as String).isNotEmpty) {
            uiMessages.add({
             'id': '${interaction['id']}_ai',
             'content': interaction['ai_response'],
             'isUser': false,
             'timestamp': aiTimestamp,
           });
           deepseekHistory.add({'role': 'assistant', 'content': interaction['ai_response'] ?? ''});
        }
      }
      
      // 对 UI 消息进行最终排序
      uiMessages.sort((a, b) => (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));

      state = state.copyWith(
        isLoading: false,
        currentAssessmentId: assessmentId,
        messages: uiMessages,
        deepseekMessagesHistory: deepseekHistory,
        assessmentResult: result,
      );
    } catch (e, stackTrace) {
      log('加载对话失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
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

  // 生成追问问题
  Future<void> generateFollowUpQuestions() async {
    if (state.currentAssessmentId == null) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.generateFollowUpQuestions(
        assessmentId: state.currentAssessmentId!,
        uiMessages: state.messages, // 修复: 传递 UI 消息列表
      );
      
      log('追问问题服务返回结果: $result'); // 添加日志：记录原始返回结果

      if (result['success'] == true && result['followUpQuestions'] != null && (result['followUpQuestions'] as List).isNotEmpty) {
        final followUpContent = '根据我们的对话，我想进一步了解以下方面：\n\n${(result['followUpQuestions'] as List).map((q) => '• $q').join('\n')}';
        
        final aiMessageUI = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': followUpContent,
          'isUser': false,
          'timestamp': DateTime.now(),
        };
        
        final currentDeepseekHistory = List<Map<String, String>>.from(state.deepseekMessagesHistory);
        currentDeepseekHistory.add({'role': 'assistant', 'content': followUpContent});
        
        final previousMessages = state.messages;

        state = state.copyWith(
          isLoading: false,
          messages: [...state.messages, aiMessageUI],
          deepseekMessagesHistory: currentDeepseekHistory,
        );
        
        // 添加日志：检查状态更新后的 messages 列表
        log('generateFollowUpQuestions 状态更新完成:');
        log('  - isLoading: ${state.isLoading}');
        log('  - 新增 AI 消息: ${aiMessageUI['content']}');
        log('  - 更新前 messages 长度: ${previousMessages.length}');
        log('  - 更新后 messages 长度: ${state.messages.length}');
        if (state.messages.isNotEmpty) {
            log('  - 更新后最后一条消息: ${state.messages.last['content']}');
        }
        
      } else {
        log('生成追问失败或无问题返回: success=${result['success']}, questions=${result['followUpQuestions']}'); // 添加日志
        state = state.copyWith(
          isLoading: false,
          error: result['error']?.toString() ?? (result['success'] != true ? '生成追问问题失败' : null) // 仅在失败时显示错误
        );
      }
    } catch (e, stackTrace) {
      log('生成追问问题时发生异常', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dialogueAssessmentProvider = StateNotifierProvider<DialogueAssessmentNotifier, DialogueAssessmentState>((ref) {
  // TODO: 使用 ref.watch 或依赖注入获取 Service 实例
  final service = DialogueAssessmentService(); 
  return DialogueAssessmentNotifier(service);
}); 