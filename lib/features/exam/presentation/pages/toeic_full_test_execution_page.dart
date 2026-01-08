import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes/route_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/test_entity.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';

class ToeicFullTestExecutionPage extends StatefulWidget {
  final ExamType examType;
  final TestEntity test;

  const ToeicFullTestExecutionPage({
    super.key,
    required this.examType,
    required this.test,
  });

  @override
  State<ToeicFullTestExecutionPage> createState() => _ToeicFullTestExecutionPageState();
}

class _ToeicFullTestExecutionPageState extends State<ToeicFullTestExecutionPage> {
  int _currentSectionIndex = 0;
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isPaused = false;
  String? _attemptId;

  List<QuestionEntity> _allQuestions = [];
  final Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTest() {
    context.read<ExamCubit>().startTest(
      testId: widget.test.id,
      examType: widget.examType,
    );
    context.read<ExamCubit>().loadFullTestDetails(widget.test.id);
  }

  void _startSectionTimer() {
    final section = widget.test.sections[_currentSectionIndex];
    _timeRemaining = section.timeLimit * 60;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (mounted) {
          setState(() {
            if (_timeRemaining > 0) {
              _timeRemaining--;
            } else {
              _handleTimeOut();
            }
          });
        }
      }
    });
  }

  void _pauseTest() => setState(() => _isPaused = !_isPaused);

  void _nextSection() {
    if (_currentSectionIndex < widget.test.sections.length - 1) {
      setState(() {
        _currentSectionIndex++;
      });
      _startSectionTimer();
    } else {
      _completeTest();
    }
  }

  void _previousSection() {
    if (_currentSectionIndex > 0) {
      setState(() {
        _currentSectionIndex--;
      });
      _startSectionTimer();
    }
  }

  void _completeTest() {
    _timer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài thi?'),
        content: const Text('Bạn có chắc chắn muốn nộp bài? Bạn sẽ không thể thay đổi đáp án sau khi nộp.'),
        actions: [
          TextButton(
            onPressed: () {
              _startSectionTimer();
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  void _exitTest() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = widget.test.sections[_currentSectionIndex];

    return BlocConsumer<ExamCubit, ExamState>(
      listener: (context, state) {
        if (state is ExamLoadedState) {
          setState(() {
            _allQuestions = state.questions;
          });

          if (_timer == null || !_timer!.isActive) {
            _startSectionTimer();
          }
        }
      },
      builder: (context, state) {
        if (state is ExamLoadingState && _allQuestions.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return WillPopScope(
          onWillPop: () async {
            _exitTest();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.test.title, style: TextStyle(fontSize: 18.sp)),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: _exitTest),
              actions: [
                IconButton(
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause_circle_filled),
                  color: _isPaused ? Colors.green : Colors.orange,
                  onPressed: _pauseTest,
                ),
              ],
            ),
            body: Column(
              children: [
                _buildProgressBar(),
                _buildHeader(currentSection),
                Expanded(
                  child: _isPaused
                      ? _buildPausedView()
                      : _allQuestions.isEmpty
                          ? const Center(child: Text("Đang tải dữ liệu câu hỏi..."))
                          : _buildSectionContent(currentSection),
                ),
                _buildNavigationBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContent(TestSection section) {
    final sectionQuestions = _allQuestions.where((q) {
      if (section.skill == SkillType.listening) {
        return q.part >= 1 && q.part <= 4;
      } else {
        return q.part >= 5 && q.part <= 7;
      }
    }).toList();

    sectionQuestions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (sectionQuestions.isEmpty) {
      return const Center(child: Text("Không có câu hỏi nào cho phần này."));
    }

    // Tách theo section type
    if (section.skill == SkillType.listening) {
      return ListeningSection(
        questions: sectionQuestions,
        userAnswers: _userAnswers,
        isPaused: _isPaused,
        onAnswerChanged: (questionId, answer) {
          setState(() {
            _userAnswers[questionId] = answer;
          });
          context.read<ExamCubit>().submitAnswer(
            questionId: questionId,
            answer: answer,
            attemptId: _attemptId ?? widget.test.id,
            timeSpentSeconds: 0,
          );
        },
      );
    } else {
      return ReadingSection(
        questions: sectionQuestions,
        userAnswers: _userAnswers,
        isPaused: _isPaused,
        onAnswerChanged: (questionId, answer) {
          setState(() {
            _userAnswers[questionId] = answer;
          });
          context.read<ExamCubit>().submitAnswer(
            questionId: questionId,
            answer: answer,
            attemptId: _attemptId ?? widget.test.id,
            timeSpentSeconds: 0,
          );
        },
      );
    }
  }

  Widget _buildPausedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_filled, size: 80.w, color: Colors.orangeAccent),
          SizedBox(height: 20.h),
          Text('Bài thi đang tạm dừng', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentSectionIndex + 1) / widget.test.sections.length;
    return Container(
      height: 6.h,
      color: Colors.grey[200],
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
      ),
    );
  }

  Widget _buildHeader(TestSection section) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            section.title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _timeRemaining < 300 ? Colors.red[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 16.w, color: _timeRemaining < 300 ? Colors.red : Colors.blue),
                SizedBox(width: 4.w),
                Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _timeRemaining < 300 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          if (_currentSectionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousSection,
                child: const Text('Back'),
              ),
            ),
          if (_currentSectionIndex > 0) SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextSection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text(
                _currentSectionIndex < widget.test.sections.length - 1 ? 'Next Section' : 'Submit Test',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitTest() {
    _timer?.cancel();

    int listeningCorrect = 0;
    int readingCorrect = 0;
    
    for (var question in _allQuestions) {
      final userAnswer = _userAnswers[question.id];
      
      if (userAnswer != null && userAnswer == question.correctAnswer) {
        if (question.skill == SkillType.listening) {
          listeningCorrect++;
        } else if (question.skill == SkillType.reading) {
          readingCorrect++;
        }
      }
    }

    int listeningScore = 0;
    int readingScore = 0;

    int totalListening = _allQuestions.where((q) => q.skill == SkillType.listening).length;
    int totalReading = _allQuestions.where((q) => q.skill == SkillType.reading).length;

    if (totalListening > 0) {
      listeningScore = ((listeningCorrect / totalListening) * 490).round() + 5;
    }
    
    if (totalReading > 0) {
      readingScore = ((readingCorrect / totalReading) * 490).round() + 5;
    }

    if (listeningScore > 495) listeningScore = 495;
    if (readingScore > 495) readingScore = 495;

    final totalScore = listeningScore + readingScore;

    final results = {
      'listeningScore': listeningScore,
      'readingScore': readingScore,
      'totalScore': totalScore,
      'listeningCorrect': listeningCorrect,
      'readingCorrect': readingCorrect,
      'listeningTotal': totalListening,
      'readingTotal': totalReading,
    };
    
    context.read<ExamCubit>().completeTest(_attemptId ?? widget.test.id);
    
    context.pushReplacement(
      AppRoutes.toeicTestResults,
      extra: results,
    );
  }

  void _handleTimeOut() {
    if (_currentSectionIndex < widget.test.sections.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hết giờ phần này! Đang chuyển sang phần tiếp theo...")),
      );
      _nextSection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hết giờ làm bài! Hệ thống đang nộp bài...")),
      );
      _submitTest();
    }
  }
}

// ============================================
// LISTENING SECTION - Có Audio Player
// ============================================
class ListeningSection extends StatefulWidget {
  final List<QuestionEntity> questions;
  final Map<String, String> userAnswers;
  final bool isPaused;
  final Function(String questionId, String answer) onAnswerChanged;

  const ListeningSection({
    Key? key,
    required this.questions,
    required this.userAnswers,
    required this.isPaused,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  State<ListeningSection> createState() => _ListeningSectionState();
}

class _ListeningSectionState extends State<ListeningSection> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isAudioLoaded = false;
  String? audioError;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
    _loadAudioForListeningSection();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });
    
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          position = Duration.zero;
          isPlaying = false;
        });
      }
    });
  }

  // ✅ Load audio một lần cho cả section Listening
  Future<void> _loadAudioForListeningSection() async {
    // Lấy audio từ câu hỏi đầu tiên
    if (widget.questions.isEmpty) return;
    
    final firstQuestion = widget.questions.first;
    
    setState(() {
      isAudioLoaded = false;
      audioError = null;
    });

    // ✅ Chỉ load audio nếu là TOEIC Listening
    if (firstQuestion.examType != ExamType.toeic || 
        firstQuestion.skill != SkillType.listening ||
        firstQuestion.audioId == null || 
        firstQuestion.audioId!.isEmpty) {
      setState(() {
        audioError = 'No audio available';
        isAudioLoaded = true;
      });
      return;
    }

    try {
      await _audioPlayer.stop();
      
      String audioUrl;
      if (firstQuestion.audioId!.startsWith('http')) {
        audioUrl = firstQuestion.audioId!;
      } else {
        // TODO: Replace with your actual Firebase Storage URL
        audioUrl = 'https://your-firebase-storage.com/audio/${firstQuestion.audioId}.mp3';
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAudioPlayer(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: widget.questions.length,
            itemBuilder: (context, index) {
              final q = widget.questions[index];
              return _buildQuestionItem(q, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    // Kiểm tra xem có audio không (từ câu hỏi đầu tiên)
    if (widget.questions.isEmpty || widget.questions.first.audioId == null) {
      return const SizedBox();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.headphones, size: 40.w, color: Colors.white),
          ),
          
          SizedBox(height: 16.h),
          
          if (!isAudioLoaded)
            const CircularProgressIndicator(color: Colors.white)
          else if (audioError != null)
            Text(audioError!, style: const TextStyle(color: Colors.white70))
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text(_formatDuration(duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _audioControlButton(Icons.replay_10, () {
                  final newPos = position - const Duration(seconds: 10);
                  _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
                }),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
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
                      color: Colors.blue,
                      size: 32.w,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                _audioControlButton(Icons.forward_10, () {
                  final newPos = position + const Duration(seconds: 10);
                  _audioPlayer.seek(newPos > duration ? duration : newPos);
                }),
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
      iconSize: 28.w,
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildQuestionItem(QuestionEntity q, int displayIndex) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    '$displayIndex',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Part ${q.part}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Image for Part 1
            if (q.metadata?['imageUrl'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  q.metadata!['imageUrl'],
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200.h,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            
            Text(
              q.questionText.isEmpty ? 'Listen and select the best answer:' : q.questionText,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12.h),

            if (q.options != null)
              ...q.options!.map((opt) {
                return RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: widget.userAnswers[q.id],
                  activeColor: Colors.blueAccent,
                  contentPadding: EdgeInsets.zero,
                  onChanged: widget.isPaused ? null : (val) {
                    widget.onAnswerChanged(q.id, val!);
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

// ============================================
// READING SECTION - Có Passage cho Part 6-7
// ============================================
class ReadingSection extends StatefulWidget {
  final List<QuestionEntity> questions;
  final Map<String, String> userAnswers;
  final bool isPaused;
  final Function(String questionId, String answer) onAnswerChanged;

  const ReadingSection({
    Key? key,
    required this.questions,
    required this.userAnswers,
    required this.isPaused,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  State<ReadingSection> createState() => _ReadingSectionState();
}

class _ReadingSectionState extends State<ReadingSection> {
  String? _currentPassageId;
  String? _passageContent;
  bool _isLoadingPassage = false;

  @override
  void initState() {
    super.initState();
    _loadFirstPassageIfNeeded();
  }

  void _loadFirstPassageIfNeeded() {
    if (widget.questions.isNotEmpty) {
      final firstQuestion = widget.questions.first;
      if (firstQuestion.part >= 6 && firstQuestion.passageId != null) {
        _loadPassage(firstQuestion.passageId!);
      }
    }
  }

  void _loadPassage(String passageId) {
    if (_currentPassageId == passageId) return;

    setState(() {
      _isLoadingPassage = true;
      _currentPassageId = passageId;
    });

    context.read<ExamCubit>().loadPassageById(passageId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamCubit, ExamState>(
      listener: (context, state) {
        if (state is PassageLoadedState) {
          setState(() {
            _passageContent = state.passage.content;
            _isLoadingPassage = false;
          });
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final q = widget.questions[index];
          
          // Load passage khi gặp câu hỏi Part 6-7
          if (q.part >= 6 && q.passageId != null && q.passageId != _currentPassageId) {
            _loadPassage(q.passageId!);
          }

          return Column(
            children: [
              // Hiển thị passage nếu là Part 6-7 và là câu đầu của passage
              if (q.part >= 6 && 
                  q.passageId != null && 
                  (index == 0 || widget.questions[index - 1].passageId != q.passageId))
                _buildPassageCard(),
              
              _buildQuestionItem(q, index + 1),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPassageCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 20.h),
      elevation: 3,
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article, color: Colors.orange[700]),
                SizedBox(width: 8.w),
                Text(
                  'Reading Passage',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.orange[200], height: 20.h),
            
            if (_isLoadingPassage)
              const Center(child: CircularProgressIndicator())
            else if (_passageContent != null)
              Text(
                _passageContent!,
                style: TextStyle(fontSize: 15.sp, height: 1.6),
              )
            else
              Text(
                'Passage content not available',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(QuestionEntity q, int displayIndex) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.green[50],
                  child: Text(
                    '$displayIndex',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Part ${q.part}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            Text(
              q.questionText,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12.h),

            if (q.options != null)
              ...q.options!.map((opt) {
                return RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: widget.userAnswers[q.id],
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                  onChanged: widget.isPaused ? null : (val) {
                    widget.onAnswerChanged(q.id, val!);
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}