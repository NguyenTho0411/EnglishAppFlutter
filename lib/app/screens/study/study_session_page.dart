import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';
import '../../../features/word/domain/entities/word_entity.dart';
import '../../../features/word/domain/entities/word_progress_entity.dart';
import '../../../features/word/presentation/blocs/word_list/word_list_cubit.dart';
import '../../../features/word/presentation/cubits/word_progress/word_progress_cubit.dart';
import '../../routes/route_manager.dart';
import '../../widgets/widgets.dart';

enum StudySessionStep {
  introduction,
  flashcard,
  quiz,
  summary,
}

class StudySessionPage extends StatefulWidget {
  final List<WordProgressEntity> words;
  final String sessionTitle;

  const StudySessionPage({
    super.key,
    required this.words,
    required this.sessionTitle,
  });

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  StudySessionStep currentStep = StudySessionStep.introduction;
  int totalWords = 0;

  @override
  void initState() {
    super.initState();
    totalWords = widget.words.length;
  }

  void _startFlashcard() {
    setState(() {
      currentStep = StudySessionStep.flashcard;
    });
  }

  void _onFlashcardComplete() {
    setState(() {
      currentStep = StudySessionStep.quiz;
    });
  }

  void _startQuiz() {
    // Navigate to quiz type selection with words
    final wordListState = context.read<WordListCubit>().state;
    if (wordListState is WordListLoadedState) {
      final allWords = wordListState.wordList;
      final selectedWords = allWords
          .where((w) => widget.words.any((pw) => pw.word == w.word))
          .toList();

      if (selectedWords.isNotEmpty) {
        context.push(
          AppRoutes.quizTypeSelection,
          extra: selectedWords,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionTitle),
        centerTitle: true,
      ),
      body: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case StudySessionStep.introduction:
        return _buildIntroduction();
      case StudySessionStep.flashcard:
        return _buildFlashcardStep();
      case StudySessionStep.quiz:
        return _buildQuizStep();
      case StudySessionStep.summary:
        return _buildSummary();
    }
  }

  Widget _buildIntroduction() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 80,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Ready to Study?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Let\'s learn ${totalWords} word${totalWords > 1 ? 's' : ''} together!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Learning Steps
          _buildStepCard(
            icon: Icons.auto_stories,
            step: '1',
            title: 'Study Flashcards',
            description: 'Review words and their meanings carefully',
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            icon: Icons.quiz,
            step: '2',
            title: 'Take Quiz',
            description: 'Test your knowledge with different quiz types',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            icon: Icons.emoji_events,
            step: '3',
            title: 'Review & Improve',
            description: 'See your results and track progress',
            color: Colors.green,
          ),
          const SizedBox(height: 40),

          // Word Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Words in this session:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.words.take(10).map((w) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        w.word,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (widget.words.length > 10)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${widget.words.length - 10} more words...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Start Button
          ElevatedButton(
            onPressed: _startFlashcard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow, size: 28),
                SizedBox(width: 8),
                Text(
                  'Start Learning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skip to Quiz Button
          OutlinedButton(
            onPressed: () {
              setState(() {
                currentStep = StudySessionStep.quiz;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Skip to Quiz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String step,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardStep() {
    return FlashcardStepWidget(
      words: widget.words,
      onComplete: _onFlashcardComplete,
    );
  }

  Widget _buildQuizStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 100,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Time to Test Yourself!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose your quiz type to begin',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardStepWidget extends StatefulWidget {
  final List<WordProgressEntity> words;
  final VoidCallback onComplete;

  const FlashcardStepWidget({
    super.key,
    required this.words,
    required this.onComplete,
  });

  @override
  State<FlashcardStepWidget> createState() => _FlashcardStepWidgetState();
}

class _FlashcardStepWidgetState extends State<FlashcardStepWidget> {
  int currentIndex = 0;
  bool showAnswer = false;
  List<WordEntity> wordEntities = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() {
    final wordListState = context.read<WordListCubit>().state;
    if (wordListState is WordListLoadedState) {
      wordEntities = wordListState.wordList
          .where((w) => widget.words.any((pw) => pw.word == w.word))
          .toList();
      setState(() {});
    }
  }

  void _nextCard() {
    if (currentIndex < widget.words.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  void _toggleAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (wordEntities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final word = wordEntities[currentIndex];
    final progress = ((currentIndex + 1) / widget.words.length);

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flashcard ${currentIndex + 1} of ${widget.words.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // Flashcard
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: _toggleAnswer,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 500,
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          showAnswer ? Icons.lightbulb : Icons.help_outline,
                          size: 48,
                          color: showAnswer
                              ? Colors.amber.shade600
                              : Colors.blue.shade600,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          word.word,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          word.meanings.isNotEmpty ? word.meanings.first.type : '',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (showAnswer) ...[
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            word.meanings.isNotEmpty
                                ? word.meanings.first.meaning
                                : 'No meaning available',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (word.meanings.isNotEmpty && word.meanings.first.examples.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.format_quote,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Example:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    word.meanings.first.examples.first,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 32),
                          Text(
                            'Tap to reveal meaning',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.touch_app,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: currentIndex > 0 ? _previousCard : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: showAnswer ? _nextCard : null,
                icon: Icon(
                  currentIndex < widget.words.length - 1
                      ? Icons.arrow_forward
                      : Icons.check,
                ),
                label: Text(
                  currentIndex < widget.words.length - 1 ? 'Next' : 'Finish',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
