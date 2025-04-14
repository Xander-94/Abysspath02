import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/survey_models.dart';
import '../providers/survey_provider.dart';
import '../widgets/question_card.dart';

class SurveyPage extends ConsumerStatefulWidget {
  final String surveyId;
  
  const SurveyPage({super.key, required this.surveyId});

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, List<String>> _answers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _answers = {};
  }

  void _loadPreviousAnswers(Survey survey) {
    if (survey.previousAnswers.isEmpty) return;
    
    setState(() {
      _answers.clear();
      for (final answer in survey.previousAnswers) {
        if (answer.optionId != null) {
          _answers[answer.questionId] = [answer.optionId!];
        } else if (answer.optionIds != null) {
          _answers[answer.questionId] = answer.optionIds!;
        } else if (answer.answerValue != null) {
          _answers[answer.questionId] = [answer.answerValue!];
        } else if (answer.answerValues != null) {
          _answers[answer.questionId] = answer.answerValues!;
        } else if (answer.answerText != null) {
          _answers[answer.questionId] = [answer.answerText!];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surveyAsync = ref.watch(surveyStateProvider(widget.surveyId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('填写问卷'),
        centerTitle: true,
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            TextButton(
              onPressed: _submitSurvey,
              child: const Text('提交'),
            ),
        ],
      ),
      body: surveyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (survey) {
          // 加载之前的答案
          if (_answers.isEmpty && survey.previousAnswers.isNotEmpty) {
            _loadPreviousAnswers(survey);
          }
          
          return Form(
            key: _formKey,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: survey.questions.length,
              itemBuilder: (context, index) {
                final question = survey.questions[index];
                return QuestionCard(
                  question: question,
                  selectedOptions: _answers[question.id] ?? [],
                  onOptionsChanged: (options) {
                    setState(() {
                      _answers[question.id] = options;
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitSurvey() async {
    final surveyAsync = ref.read(surveyStateProvider(widget.surveyId));
    if (!surveyAsync.hasValue) return;
    
    final survey = surveyAsync.value!;
    // 验证必填项
    final missingRequired = survey.questions.where((q) => 
      q.isRequired && 
      (!_answers.containsKey(q.id) || _answers[q.id]!.isEmpty)
    ).toList();
    
    if (missingRequired.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请完成所有必填题目（第${missingRequired.map((q) => survey.questions.indexOf(q) + 1).join("、")}题）')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final details = _answers.entries.map((entry) {
        final question = survey.questions.firstWhere((q) => q.id == entry.key);
        final values = entry.value;
        
        if (question.questionType == 'text') {
          return ResponseDetail(
            questionId: entry.key,
            answerText: values.first,
          );
        } else if (question.questionType == 'scale') {
          return ResponseDetail(
            questionId: entry.key,
            answerValue: values.first,
          );
        } else if (question.questionType == 'single_choice') {
          return ResponseDetail(
            questionId: entry.key,
            optionId: values.first,
          );
        } else {
          return ResponseDetail(
            questionId: entry.key,
            optionIds: values,
          );
        }
      }).toList();
      
      await ref.read(surveyStateProvider(widget.surveyId).notifier)
          .submitResponse(details);
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交成功')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
} 