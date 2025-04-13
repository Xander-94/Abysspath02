 import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 评估状态
class AssessmentState {
  final bool isLoading;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic>? currentQuestion;
  final Map<String, dynamic>? results;
  final String? error;

  const AssessmentState({
    this.isLoading = false,
    this.questions = const [],
    this.currentQuestion,
    this.results,
    this.error,
  });

  AssessmentState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? questions,
    Map<String, dynamic>? currentQuestion,
    Map<String, dynamic>? results,
    String? error,
  }) {
    return AssessmentState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}

/// 评估状态管理
class AssessmentNotifier extends StateNotifier<AssessmentState> {
  AssessmentNotifier() : super(const AssessmentState());

  /// 加载评估问题
  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 实现加载问题逻辑
      final questions = [
        {'id': '1', 'text': '问题1', 'type': 'single'},
        {'id': '2', 'text': '问题2', 'type': 'multiple'},
      ];
      state = state.copyWith(
        isLoading: false,
        questions: questions,
        currentQuestion: questions.first,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 提交答案
  Future<void> submitAnswer(String questionId, dynamic answer) async {
    // TODO: 实现提交答案逻辑
  }

  /// 获取评估结果
  Future<void> getResults() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 实现获取结果逻辑
      final results = {
        'score': 85,
        'analysis': '分析结果',
      };
      state = state.copyWith(
        isLoading: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}