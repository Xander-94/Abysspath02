import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/learning_path_service.dart';
import 'dart:convert'; // 用于 jsonEncode
import 'dart:math'; // 导入 math 库

// 导入需要访问的 Provider
import '../../profile/providers/profile_notifier.dart';
import '../../assessment/providers/assessment_profile_provider.dart';
import '../models/learning_path_models.dart'; // 导入 LearningPathCreateRequest

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
  final Ref _ref; // *** 修改为 Ref ***

  LearningPathNotifier(this._service, this._ref) : super(const LearningPathState());

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
    String? targetPathId = state.currentPathId;
    bool isNewPathFlow = false;

    // 1. 确定 Path ID，并判断是否是新路径的第一个消息
    if (targetPathId == null) {
      print('LearningPathNotifier: 当前无路径，创建新路径...');
      final newPath = await createNewConversation();
      if (newPath == null) {
        print('LearningPathNotifier: 创建新路径失败');
        return;
      }
      targetPathId = newPath['id'];
      isNewPathFlow = true; // 标记这是新路径的第一个消息流程
      print('LearningPathNotifier: 新路径已创建, ID: $targetPathId');
      // 注意: createNewConversation 会将 messages 置为空
    } else {
      // 如果已有路径，检查消息列表是否为空来判断是否为第一次发送
      if (state.messages.isEmpty) {
          isNewPathFlow = true;
          print('LearningPathNotifier: 现有路径 $targetPathId 但无消息，视为路径生成流程');
      }
    }

    // 防御性检查
    if (targetPathId == null) {
        state = state.copyWith(isLoading: false, error: "未能获取有效的学习路径ID");
        print('LearningPathNotifier: 错误 - 未能获取有效的学习路径ID');
        return;
    }

    // 2. 根据是否为新路径流程，决定调用哪个服务
    if (isNewPathFlow) {
      // --- 学习路径生成流程 ---
      state = state.copyWith(isLoading: true, error: null);
      print('LearningPathNotifier: 开始学习路径生成流程 for path $targetPathId with goal: $message');
      try {
        // 2.1 获取画像数据
        print('LearningPathNotifier: 获取用户画像数据...');
        final profileState = _ref.read(profileProvider);
        final assessmentProfileAsync = await _ref.read(assessmentProfileProvider.future);
        
        String? userProfileJson;
        Map<String, dynamic> combinedProfile = {};
        if (profileState.profile != null) {
          combinedProfile = profileState.profile!.toJson();
          print('LearningPathNotifier: 获取到基础 Profile');
        }
        if (assessmentProfileAsync != null) {
          combinedProfile['ai_assessment'] = assessmentProfileAsync.toJson();
          print('LearningPathNotifier: 获取并转换了 AI 评估 Profile 为 Map');
        }
        
        if (combinedProfile.isNotEmpty) {
          userProfileJson = jsonEncode(combinedProfile);
          print('LearningPathNotifier: 组合后的 Profile JSON: ${userProfileJson.substring(0, min(userProfileJson.length, 100))}...');
        }

        // 2.2 准备请求体
        final request = LearningPathCreateRequest(
          userGoal: message,
          userProfileJson: userProfileJson,
          // 如果需要，这里可以添加 assessmentSessionId
          // assessmentSessionId: _ref.read(currentAssessmentSessionIdProvider), 
        );

        print('LearningPathNotifier: 调用 _service.generateAndSaveLearningPath...');
        final String newPathId = await _service.generateAndSaveLearningPath(request);
        print('LearningPathNotifier: generateAndSaveLearningPath 调用成功，返回 ID: $newPathId');

        // !! 2.4 构建用户和助手消息 !!
        final userMessageForState = {
          'role': 'user',
          'content': message, // 使用传入的 message 变量
          'created_at': DateTime.now().toIso8601String(), // 近似时间
          'path_id': newPathId, // 使用新获取的 ID
        };
        final assistantMessageForState = {
           'role': 'assistant',
           'content': '学习路径已为您生成！点击下方按钮查看详情。', // 提示语
           'created_at': DateTime.now().toIso8601String(), // 助手消息时间略后
           'path_id': newPathId,
           'is_creation_confirmation': true,
        };

        // *** 乐观更新 Conversations 列表 ***
        final currentConversations = state.conversations;
        final newPathListItem = {
          'id': newPathId,
          // 尝试使用用户目标作为标题，如果太长就用通用标题
          'title': (message.length < 30) ? message : '新的学习路径', 
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // 添加其他列表项可能需要的字段，使用默认值
          'description': null, 
          'status': 'in_progress', 
          'message_count': 2, // 初始消息计数
          // 根据你的 LearningPathListItemAPI 模型补充可能需要的其他字段
        };
        final updatedConversations = [newPathListItem, ...currentConversations];
        // ************************************

        // 2.5 更新状态，使用手动更新后的列表
        // final conversations = await _service.getHistoryPaths(); // 不再立即获取
        state = state.copyWith(
          isLoading: false,
          conversations: updatedConversations, // <--- 使用乐观更新后的列表
          currentPathId: newPathId,
          messages: [userMessageForState, assistantMessageForState],
          error: null,
        );
        print('LearningPathNotifier: 路径生成流程完成，状态已更新 (乐观)');

        // (可选) 可以在后台稍后静默刷新一次列表以确保最终一致性
        // Future.delayed(const Duration(seconds: 2), () => loadConversations());
        
      } catch (e) {
        print('LearningPathNotifier: 学习路径生成流程出错: $e');
        // 确保在 catch 块中也重置 isLoading
        state = state.copyWith(
          isLoading: false, 
          error: '通过API生成学习路径失败: ${e.toString()}',
          messages: [], // 保留空消息列表
        );
      }

    } else {
      // --- 普通聊天消息流程 ---
      print('LearningPathNotifier: 开始普通聊天消息流程 for path $targetPathId');
      // 立即添加用户消息
      final userMessage = {
        'role': 'user',
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
        'path_id': targetPathId,
      };
      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(
          messages: updatedMessages,
          isLoading: true,
          error: null
      );
      print('LearningPathNotifier: 用户消息已添加，准备调用 _service.sendMessage');
      try {
        await _service.sendMessage(targetPathId, message);
        print('LearningPathNotifier: _service.sendMessage 成功');
        final dbMessages = await _service.getPathMessages(targetPathId);
        final conversations = await _service.getHistoryPaths();
        print('LearningPathNotifier: 获取到 ${dbMessages.length} 条消息, ${conversations.length} 个会话');
        state = state.copyWith(
          isLoading: false,
          messages: dbMessages,
          conversations: conversations,
          currentPathId: targetPathId,
          error: null,
        );
        print('LearningPathNotifier: 普通消息流程状态更新完成');
      } catch (e) {
        print('LearningPathNotifier: 普通消息流程出错: $e');
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          messages: state.messages.where((m) => m != userMessage).toList(),
        );
      }
    }
  }
}

// Provider 定义
final learningPathProvider = StateNotifierProvider<LearningPathNotifier, LearningPathState>((ref) {
  // *** 依赖 learningPathLogicProvider 获取 LearningPathService 实例 ***
  final service = ref.watch(learningPathLogicProvider);
  return LearningPathNotifier(service, ref);
});

// 如果有 assessmentSessionId 的 Provider，需要确保它被正确设置和读取
// final currentAssessmentSessionIdProvider = Provider<String?>((ref) => null);