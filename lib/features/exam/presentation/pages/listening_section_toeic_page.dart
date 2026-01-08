import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_1/features/exam/domain/entities/question_entity.dart';
import 'package:flutter_application_1/features/exam/domain/entities/exam_type.dart';

class ToeicPartPracticePage extends StatefulWidget {
  final ToeicPart part;
  final List<QuestionEntity> questions;

  const ToeicPartPracticePage({
    Key? key,
    required this.part,
    required this.questions,
  }) : super(key: key);

  @override
  State<ToeicPartPracticePage> createState() => _ToeicPartPracticePageState();
}

class _ToeicPartPracticePageState extends State<ToeicPartPracticePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int currentIndex = 0;
  Map<int, String> userAnswers = {};
  bool showExplanation = false;
  
  // Audio states
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isAudioLoaded = false;
  String? audioError;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
    _loadAudioForCurrentQuestion();
  }

  void _setupAudioListeners() {
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });
    
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => position = p);
    });
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  Future<void> _loadAudioForCurrentQuestion() async {
    final question = widget.questions[currentIndex];
    
    setState(() {
      isAudioLoaded = false;
      audioError = null;
    });

    if (question.audioId == null || question.audioId!.isEmpty) {
      setState(() {
        audioError = 'No audio available';
        isAudioLoaded = true;
      });
      return;
    }

    try {
      await _audioPlayer.stop();
      
      // ✅ Check if audioId is a URL or just an ID
      String audioUrl;
      if (question.audioId!.startsWith('http')) {
        audioUrl = question.audioId!;
      } else {
        // TODO: Get from Firebase Storage
        audioUrl = 'https://your-firebase-storage.com/audio/${question.audioId}.mp3';
      }
      
      await _audioPlayer.setSourceUrl(audioUrl);
      
      setState(() => isAudioLoaded = true);
    } catch (e) {
      setState(() {
        audioError = 'Failed to load audio';
        isAudioLoaded = true;
      });
      print('Audio error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.part.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildAudioPlayer(question),
                  _buildQuestionContent(question),
                ],
              ),
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentIndex + 1) / widget.questions.length;
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.orange[100],
            color: Colors.orange,
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentIndex + 1} of ${widget.questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(QuestionEntity question) {
    // Only show for listening questions with audio
    if (question.audioId == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Audio icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headphones,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Error or loading state
          if (!isAudioLoaded)
            const CircularProgressIndicator(color: Colors.white)
          else if (audioError != null)
            Text(
              audioError!,
              style: const TextStyle(color: Colors.white70),
            )
          else ...[
            // Time display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Progress slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds > 0 
                    ? duration.inSeconds.toDouble() 
                    : 1.0,
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _audioControlButton(
                  Icons.replay_10,
                  () {
                    final newPos = position - const Duration(seconds: 10);
                    _audioPlayer.seek(
                      newPos < Duration.zero ? Duration.zero : newPos,
                    );
                  },
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                _audioControlButton(
                  Icons.forward_10,
                  () {
                    final newPos = position + const Duration(seconds: 10);
                    _audioPlayer.seek(
                      newPos > duration ? duration : newPos,
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _audioControlButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      iconSize: 28,
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildQuestionContent(QuestionEntity question) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question ${currentIndex + 1}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Image for Part 1
          if (question.metadata?['imageUrl'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.metadata!['imageUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Question text
          Text(
            question.questionText.isEmpty 
                ? 'Listen and select the best answer:'
                : question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Options
          ...question.options!.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOption(option, question, index);
          }).toList(),
          
          // Explanation (shown after answering)
          if (showExplanation) ...[
            const SizedBox(height: 20),
            _buildExplanation(question),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(String option, QuestionEntity question, int index) {
    final isSelected = userAnswers[currentIndex] == option;
    final isCorrect = showExplanation && option == question.correctAnswer;
    final isWrong = showExplanation && 
        isSelected && 
        option != question.correctAnswer;
    
    Color? borderColor;
    Color? bgColor;
    
    if (showExplanation) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green[50];
      } else if (isWrong) {
        borderColor = Colors.red;
        bgColor = Colors.red[50];
      }
    } else if (isSelected) {
      borderColor = Colors.orange;
      bgColor = Colors.orange[50];
    }

    return GestureDetector(
      onTap: showExplanation ? null : () {
        setState(() => userAnswers[currentIndex] = option);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey[50],
          border: Border.all(
            color: borderColor ?? Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect 
                    ? Colors.green 
                    : isWrong 
                        ? Colors.red 
                        : isSelected 
                            ? Colors.orange 
                            : Colors.white,
                border: Border.all(
                  color: isCorrect || isWrong || isSelected
                      ? Colors.transparent
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isCorrect || isWrong || isSelected
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question.metadata?['optionsText']?[option] ?? option,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (isWrong)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuestionEntity question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation ?? 'No explanation available.',
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final canCheck = userAnswers[currentIndex] != null && !showExplanation;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentIndex > 0) ...[
              IconButton(
                onPressed: () {
                  setState(() {
                    currentIndex--;
                    showExplanation = false;
                  });
                  _loadAudioForCurrentQuestion();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: canCheck
                    ? () {
                        setState(() => showExplanation = true);
                      }
                    : (showExplanation
                        ? () {
                            if (currentIndex < widget.questions.length - 1) {
                              setState(() {
                                currentIndex++;
                                showExplanation = false;
                              });
                              _loadAudioForCurrentQuestion();
                            } else {
                              _showResults();
                            }
                          }
                        : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheck ? Colors.orange : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  canCheck
                      ? 'Check Answer'
                      : (currentIndex < widget.questions.length - 1
                          ? 'Next Question'
                          : 'Finish'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canCheck || showExplanation 
                        ? Colors.white 
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResults() {
    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (userAnswers[i] == widget.questions[i].correctAnswer) {
        correctCount++;
      }
    }

    final score = (correctCount / widget.questions.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            'Practice Complete!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '$score%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You got $correctCount out of ${widget.questions.length} correct',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Back to Practice',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}