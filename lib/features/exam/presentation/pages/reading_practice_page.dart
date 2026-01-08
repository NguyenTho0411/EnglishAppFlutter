import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/passage_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_type.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';

class ReadingPracticePage extends StatefulWidget {
  final ExamType examType;
  final String? passageId;
  final DifficultyLevel? difficulty;

  const ReadingPracticePage({
    Key? key,
    required this.examType,
    this.passageId,
    this.difficulty,
  }) : super(key: key);

  @override
  State<ReadingPracticePage> createState() => _ReadingPracticePageState();
}

class _ReadingPracticePageState extends State<ReadingPracticePage> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _showAnswers = false;
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {};
  final ScrollController _passageScrollController = ScrollController();
  final ScrollController _questionsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPassage();
    _startTimer();
  }

  void _loadPassage() {
    if (widget.passageId != null) {
      context.read<ExamCubit>().loadPassageById(widget.passageId!);
    } else {
      context.read<ExamCubit>().loadRandomPassage(
            examType: widget.examType,
            difficulty: widget.difficulty,
          );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitAnswer(String questionId, String answer) {
    setState(() {
      _userAnswers[questionId] = answer;
    });
  }

  void _submitAllAnswers() {
    final state = context.read<ExamCubit>().state;
    if (state is! ExamLoadedState) return;

    // Calculate score
    int correctCount = 0;
    for (final question in state.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && question.isCorrectAnswer(userAnswer)) {
        correctCount++;
      }
    }

    // Show results
    setState(() {
      _showAnswers = true;
    });

    // Show score dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Practice Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $correctCount/${state.questions.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${((correctCount / state.questions.length) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${_formatTime(_secondsElapsed)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Review Answers'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    // TODO: Save progress to Firestore
    context.read<ExamCubit>().saveReadingProgress(
          passageId: state.passage!.id,
          answers: _userAnswers,
          timeSpentSeconds: _secondsElapsed,
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passageScrollController.dispose();
    _questionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType.displayName} Reading'),
        actions: [
          // Timer display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsElapsed),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          if (state is ExamLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPassage,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ExamLoadedState || state.passage == null) {
            return const Center(child: Text('No passage available'));
          }

          final passage = state.passage!;
          final questions = state.questions;

          return Row(
            children: [
              // LEFT: Passage
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      // Passage header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              passage.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(passage.difficulty.name),
                                  backgroundColor: _getDifficultyColor(passage.difficulty),
                                ),
                                const SizedBox(width: 8),
                                Chip(label: Text(passage.topic)),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('${passage.wordCount} words'),
                                  avatar: const Icon(Icons.text_fields, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('~${passage.estimatedReadingTime} min'),
                                  avatar: const Icon(Icons.schedule, size: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Passage content
                      Expanded(
                        child: Scrollbar(
                          controller: _passageScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _passageScrollController,
                            padding: const EdgeInsets.all(24),
                            child: SelectableText(
                              passage.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(width: 1, color: Colors.grey[300]),
              // RIGHT: Questions
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Questions header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Questions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _userAnswers.length / questions.length,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Answered: ${_userAnswers.length}/${questions.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Questions list
                    Expanded(
                      child: Scrollbar(
                        controller: _questionsScrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _questionsScrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final question = questions[index];
                            return _QuestionWidget(
                              question: question,
                              questionNumber: index + 1,
                              userAnswer: _userAnswers[question.id],
                              showCorrectAnswer: _showAnswers,
                              onAnswerSelected: (answer) {
                                _submitAnswer(question.id, answer);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    // Submit button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _userAnswers.length == questions.length && !_showAnswers
                            ? _submitAllAnswers
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _showAnswers
                              ? 'Review Complete'
                              : 'Submit Answers (${_userAnswers.length}/${questions.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green[100]!;
      case DifficultyLevel.intermediate:
        return Colors.orange[100]!;
      case DifficultyLevel.advanced:
        return Colors.red[100]!;
      case DifficultyLevel.expert:
        return Colors.purple[100]!;
    }
  }
}

class _QuestionWidget extends StatelessWidget {
  final QuestionEntity question;
  final int questionNumber;
  final String? userAnswer;
  final bool showCorrectAnswer;
  final Function(String) onAnswerSelected;

  const _QuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    this.userAnswer,
    required this.showCorrectAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: userAnswer != null ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: userAnswer != null ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: userAnswer != null ? Colors.blue : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: userAnswer != null ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionType.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Answer options
            if (question.questionType == QuestionType.multipleChoice && question.options != null)
              ..._buildMultipleChoiceOptions(),
            if (question.questionType == QuestionType.trueFalseNotGiven ||
                question.questionType == QuestionType.yesNoNotGiven)
              ..._buildTrueFalseOptions(),
            if (question.questionType == QuestionType.shortAnswer ||
                question.questionType == QuestionType.sentenceCompletion)
              _buildShortAnswerField(),
            // Show explanation if answer is shown
            if (showCorrectAnswer && question.explanation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Explanation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions() {
    return question.options!.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
      final isSelected = userAnswer == option;
      final isCorrect = question.isCorrectAnswer(option);

      Color? backgroundColor;
      Color? borderColor;
      Color? textColor;

      if (showCorrectAnswer) {
        if (isCorrect) {
          backgroundColor = Colors.green[100];
          borderColor = Colors.green;
          textColor = Colors.green[900];
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red[100];
          borderColor = Colors.red;
          textColor = Colors.red[900];
        }
      } else if (isSelected) {
        backgroundColor = Colors.blue[50];
        borderColor = Colors.blue;
        textColor = Colors.blue[900];
      }

      return GestureDetector(
        onTap: showCorrectAnswer ? null : () => onAnswerSelected(option),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor ?? Colors.grey[300]!,
              width: borderColor != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? (borderColor ?? Colors.blue) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    optionLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (textColor ?? Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              if (showCorrectAnswer && isCorrect)
                Icon(Icons.check_circle, color: Colors.green[700]),
              if (showCorrectAnswer && isSelected && !isCorrect)
                Icon(Icons.cancel, color: Colors.red[700]),
            ],
          ),
        ),
      );
    }).toList();
  }
  

  List<Widget> _buildTrueFalseOptions() {
    final options = question.questionType == QuestionType.trueFalseNotGiven
        ? ['True', 'False', 'Not Given']
        : ['Yes', 'No', 'Not Given'];

    return options.map((option) {
      final isSelected = userAnswer == option;
      final isCorrect = question.isCorrectAnswer(option);

      Color? backgroundColor;
      Color? borderColor;

      if (showCorrectAnswer) {
        if (isCorrect) {
          backgroundColor = Colors.green[100];
          borderColor = Colors.green;
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red[100];
          borderColor = Colors.red;
        }
      } else if (isSelected) {
        backgroundColor = Colors.blue[50];
        borderColor = Colors.blue;
      }

      return GestureDetector(
        onTap: showCorrectAnswer ? null : () => onAnswerSelected(option),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor ?? Colors.grey[300]!,
              width: borderColor != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: borderColor ?? Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                option,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (showCorrectAnswer && isCorrect)
                Icon(Icons.check_circle, color: Colors.green[700]),
              if (showCorrectAnswer && isSelected && !isCorrect)
                Icon(Icons.cancel, color: Colors.red[700]),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildShortAnswerField() {
    final controller = TextEditingController(text: userAnswer);
    
    return TextField(
      controller: controller,
      enabled: !showCorrectAnswer,
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: showCorrectAnswer ? Colors.grey[200] : Colors.white,
        suffixIcon: showCorrectAnswer
            ? Icon(
                question.isCorrectAnswer(userAnswer ?? '')
                    ? Icons.check_circle
                    : Icons.cancel,
                color: question.isCorrectAnswer(userAnswer ?? '')
                    ? Colors.green
                    : Colors.red,
              )
            : null,
      ),
      onChanged: (value) {
        onAnswerSelected(value);
      },
      onSubmitted: (value) {
        onAnswerSelected(value);
      },
    );
  }
}
