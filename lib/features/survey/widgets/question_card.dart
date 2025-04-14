import 'package:flutter/material.dart';
import '../models/survey_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';

class QuestionCard extends ConsumerStatefulWidget {
  final Question question;
  final List<String> selectedOptions;
  final Function(List<String>) onOptionsChanged;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedOptions,
    required this.onOptionsChanged,
  });

  @override
  ConsumerState<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<QuestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
    if (widget.question.questionType == 'text' && widget.selectedOptions.isNotEmpty) {
      _textController.text = widget.selectedOptions.first;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(),
          if (widget.question.section.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.question.section,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildQuestionContent(),
        ],
      ),
    ),
  );

  Widget _buildQuestionHeader() => Row(
    children: [
      Expanded(
        child: Text(
          widget.question.questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      if (widget.question.maxChoices != null && widget.question.questionType == 'multiple') ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '已选 ${widget.selectedOptions.length}/${widget.question.maxChoices}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      if (widget.question.isRequired) ...[
        const SizedBox(width: 4),
        Text(
          '*',
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 14,
          ),
        ),
      ],
    ],
  );

  Widget _buildQuestionContent() {
    switch (widget.question.questionType) {
      case 'single_choice':
        return _buildSingleChoice();
      case 'multiple_choice':
        return _buildMultipleChoice();
      case 'scale':
        return _buildScale();
      case 'text':
        return _buildTextInput();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSingleChoice() => Column(
    children: widget.question.options.map((option) => RadioListTile<String>(
      title: Text(option.optionText),
      value: option.id,
      groupValue: widget.selectedOptions.isEmpty ? null : widget.selectedOptions.first,
      onChanged: (value) {
        if (value != null) {
          _controller.forward().then((_) => _controller.reverse());
          widget.onOptionsChanged([value]);
        }
      },
      activeColor: Colors.blue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    )).toList(),
  );

  Widget _buildMultipleChoice() => Column(
    children: widget.question.options.map((option) => CheckboxListTile(
      title: Text(option.optionText),
      value: widget.selectedOptions.contains(option.id),
      onChanged: (selected) {
        if (selected == null) return;
        final newSelection = List<String>.from(widget.selectedOptions);
        if (selected) {
          if (widget.question.maxChoices == null || newSelection.length < widget.question.maxChoices!) {
            _controller.forward().then((_) => _controller.reverse());
            newSelection.add(option.id);
          }
        } else {
          newSelection.remove(option.id);
        }
        widget.onOptionsChanged(newSelection);
      },
      activeColor: Colors.blue,
      checkColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    )).toList(),
  );

  Widget _buildScale() => Column(
    children: [
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final value = (index + 1).toString();
          final isSelected = widget.selectedOptions.contains(value);
          return InkWell(
            onTap: () {
              _controller.forward().then((_) => _controller.reverse());
              widget.onOptionsChanged([value]);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('完全生疏', style: TextStyle(color: Colors.grey)),
          Text('精通', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ],
  );

  Widget _buildTextInput() => TextField(
    controller: _textController,
    maxLines: null,
    decoration: InputDecoration(
      hintText: widget.question.questionText.contains('领域') ? '请输入"领域A × 领域B"格式的组合' : '请输入您的答案',
      errorText: _validateTextInput(),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    onChanged: (value) {
      if (widget.question.questionText.contains('领域')) {
        if (!value.contains('×') && !value.contains('x')) {
          return;
        }
      }
      widget.onOptionsChanged([value]);
    },
  );

  String? _validateTextInput() {
    if (widget.question.questionText.contains('领域')) {
      final text = _textController.text;
      if (text.isNotEmpty && !text.contains('×') && !text.contains('x')) {
        return '请使用"领域A × 领域B"的格式';
      }
    }
    return null;
  }
} 