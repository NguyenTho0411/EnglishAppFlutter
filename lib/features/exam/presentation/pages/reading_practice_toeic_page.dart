import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/exam/domain/entities/question_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/features/authentication/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_application_1/features/exam/domain/entities/exam_type.dart';
import 'package:flutter_application_1/features/exam/presentation/cubits/exam_cubit.dart';
import 'package:flutter_application_1/features/exam/presentation/cubits/exam_state.dart';
class ReadingPracticeToeicPage extends StatefulWidget {
  const ReadingPracticeToeicPage({Key? key}) : super(key: key);

  @override
  State<ReadingPracticeToeicPage> createState() => _ReadingPracticeToeicPageState();
}

class _ReadingPracticeToeicPageState extends State<ReadingPracticeToeicPage> {
  // Biến này chỉ để check xem đã gọi API load câu hỏi chưa, tránh gọi lại liên tục
  bool _isQuestionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Hàm load dữ liệu tổng hợp
  void _loadInitialData() {
    final user = context.read<AuthBloc>().state.user;
    
    // 1. Load danh sách câu hỏi (Chỉ load 1 lần khi vào màn hình)
    if (!_isQuestionsLoaded) {
      _isQuestionsLoaded = true;
      context.read<ExamCubit>().loadToeicReadingQuestions();
    }
    
    // 2. Load thống kê điểm số (Cần load mỗi khi quay lại màn hình)
    if (user != null) {
      // Delay nhỏ để tránh xung đột UI
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.read<ExamCubit>().loadToeicStatistics(user.uid);
        }
      });
    }
  }

  /// Hàm refresh dùng cho Kéo-để-refresh
  Future<void> _refreshData() async {
    final user = context.read<AuthBloc>().state.user;
    // Load lại tất cả từ đầu
    context.read<ExamCubit>().loadToeicReadingQuestions();
    if (user != null) {
      await context.read<ExamCubit>().loadToeicStatistics(user.uid);
    }
  }

  // ✅ LOGIC QUAN TRỌNG: Load lại dữ liệu khi quay về
  Future<void> _navigateToPart(ToeicPart part, List<QuestionEntity> allQuestions) async {
    final partQuestions = allQuestions
        .where((q) => q.part == part.partNumber)
        .toList();

    if (partQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions available for ${part.title}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Dùng 'await' để đợi người dùng làm bài xong và quay lại
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToeicReadingPracticeDetailPage(
          part: part,
          questions: partQuestions,
        ),
      ),
    );

    // 2. Sau khi quay lại (dòng code này mới chạy):
    if (mounted) {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        // Chỉ cần load lại thống kê (điểm số), không cần load lại câu hỏi
        print("🔄 Returning from practice, reloading stats...");
        context.read<ExamCubit>().loadToeicStatistics(user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOEIC Reading Practice'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép kéo để refresh
              padding: const EdgeInsets.all(16),
              children: [
                // Phần hiển thị tiến độ (Lấy trực tiếp từ State)
                _buildReadingProgress(state),
                
                const SizedBox(height: 24),
                const Text(
                  'Reading Sections',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Hiển thị danh sách Part
                if (state is ExamLoadedState) ...[
                  _buildReadingCard(
                    ToeicPart.part5,
                    Colors.blue,
                    Icons.text_fields,
                    state.questions,
                  ),
                  _buildReadingCard(
                    ToeicPart.part6,
                    Colors.indigo,
                    Icons.article,
                    state.questions,
                  ),
                  _buildReadingCard(
                    ToeicPart.part7,
                    Colors.deepPurple,
                    Icons.menu_book,
                    state.questions,
                  ),
                ] else if (state is ExamLoadingState) ...[
                   const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                   ),
                ],
                
                if (state is ExamErrorState)
                  _buildErrorWidget(state.message),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS CON (GIỮ NGUYÊN GIAO DIỆN) ---

  Widget _buildReadingProgress(ExamState state) {
    int bestScore = 0;
    int averageScore = 0;
    int totalTests = 0;

    if (state is ExamLoadedState) {
      bestScore = state.bestScore ?? 0;
      averageScore = state.averageScore ?? 0;
      totalTests = state.totalTests ?? 0;
    }

    // Nếu chưa học gì
    if (totalTests == 0 && averageScore == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[700]!]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            'Start practicing to track your progress',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final accuracy = averageScore > 0 ? (averageScore / 495 * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[700]!]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('Overall Accuracy', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text('$accuracy%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMiniItem('Best Score', '$bestScore'),
              Container(width: 1, height: 20, color: Colors.white24),
              _buildStatMiniItem('Total Tests', '$totalTests'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMiniItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildReadingCard(ToeicPart part, Color color, IconData icon, List<QuestionEntity> allQuestions) {
    final questionCount = _getPartQuestionCount(allQuestions, part.partNumber);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        // Gọi hàm _navigateToPart khi bấm
        onTap: questionCount > 0 ? () => _navigateToPart(part, allQuestions) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Part ${part.partNumber}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(part.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      questionCount > 0 ? '$questionCount questions available' : 'No questions yet',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(questionCount > 0 ? Icons.chevron_right : Icons.lock, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  int _getPartQuestionCount(List<QuestionEntity> questions, int partNumber) {
    return questions.where((q) => q.part == partNumber).length;
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class ToeicReadingPracticeDetailPage extends StatefulWidget {
  final ToeicPart part;
  final List<QuestionEntity> questions;

  const ToeicReadingPracticeDetailPage({
    Key? key,
    required this.part,
    required this.questions,
  }) : super(key: key);

  @override
  State<ToeicReadingPracticeDetailPage> createState() =>
      _ToeicReadingPracticeDetailPageState();
}

class _ToeicReadingPracticeDetailPageState
    extends State<ToeicReadingPracticeDetailPage> {
  
  int currentQuestionIndex = 0;
  bool showExplanation = false; // Trạng thái: Đã check đáp án hay chưa

  @override
  void initState() {
    super.initState();
    // Load đoạn văn cho câu hỏi đầu tiên (nếu có)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPassageIfNeeded();
    });
  }

  // Logic tải Passage cho Part 6 và 7
  void _loadPassageIfNeeded() {
    final isReadingPassagePart = widget.part.partNumber == 6 || widget.part.partNumber == 7;
    
    if (isReadingPassagePart && widget.questions.isNotEmpty) {
      final q = widget.questions[currentQuestionIndex];
      if (q.passageId != null) {
        context.read<ExamCubit>().loadPassageById(q.passageId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.part.title)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.part.title),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPartInfo(context),
          ),
        ],
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          // Lấy map câu trả lời từ Cubit (Session State)
          Map<String, String> userAnswers = {};
          if (state is ExamLoadedState) {
            userAnswers = state.practiceAnswers;
          }

          return Column(
            children: [
              // 1. Thanh tiến trình
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                color: Colors.blueAccent,
                minHeight: 6,
              ),

              // 2. Nội dung chính
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Nút xem Passage (Chỉ cho Part 6, 7)
                      if (widget.part.partNumber == 6 || widget.part.partNumber == 7)
                        _buildPassageButton(state),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildQuestionHeader(currentQuestionIndex, questions.length),
                              const SizedBox(height: 16),
                              
                              // Nội dung câu hỏi
                              Text(
                                currentQuestion.questionText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Các lựa chọn (Options)
                              _buildOptions(currentQuestion, userAnswers),
                              
                              // Giải thích (chỉ hiện khi đã bấm Check)
                              if (showExplanation) ...[
                                const SizedBox(height: 24),
                                _buildExplanation(currentQuestion),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. Thanh điều hướng dưới cùng
              _buildBottomBar(context, questions, userAnswers),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị nút mở Passage
  Widget _buildPassageButton(ExamState state) {
    final passage = (state is ExamLoadedState) ? state.passage : null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: passage != null
            ? () => _showPassageModal(context, passage)
            : null,
        icon: Icon(Icons.import_contacts, 
            color: passage != null ? Colors.blue[800] : Colors.grey),
        label: Text(
          passage != null ? 'View Reading Passage' : 'Loading Passage...',
          style: TextStyle(
            color: passage != null ? Colors.blue[800] : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildOptions(QuestionEntity currentQuestion, Map<String, String> userAnswers) {
    if (currentQuestion.options == null) return const SizedBox();

    return Column(
      children: currentQuestion.options!.map<Widget>((option) {
        // Lấy đáp án dựa trên ID câu hỏi
        final selectedAnswer = userAnswers[currentQuestion.id];
        
        final isSelected = selectedAnswer == option;
        final isCorrect = showExplanation && option == currentQuestion.correctAnswer;
        final isWrong = showExplanation && isSelected && option != currentQuestion.correctAnswer;

        // Màu sắc
        Color borderColor = Colors.grey[300]!;
        Color bgColor = Colors.white;
        IconData? icon;
        Color iconColor = Colors.transparent;

        if (isCorrect) {
          borderColor = Colors.green;
          bgColor = Colors.green[50]!;
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (isWrong) {
          borderColor = Colors.red;
          bgColor = Colors.red[50]!;
          icon = Icons.cancel;
          iconColor = Colors.red;
        } else if (isSelected) {
          borderColor = Colors.blue;
          bgColor = Colors.blue[50]!;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: showExplanation 
              ? null // Không cho chọn lại khi đã hiện giải thích
              : () {
                  // Gọi Cubit để lưu trạng thái
                  context.read<ExamCubit>().selectPracticeAnswer(
                    currentQuestion.id, 
                    option
                  );
                },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected || isCorrect || isWrong 
                        ? borderColor 
                        : Colors.grey[200],
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected || isCorrect || isWrong 
                            ? Colors.white 
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      // Lấy text hiển thị từ metadata
                      currentQuestion.metadata?['optionsText']?[option] ?? option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: iconColor),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<QuestionEntity> questions, Map<String, String> userAnswers) {
    // Kiểm tra xem đã chọn đáp án cho câu hiện tại chưa
    final currentQId = questions[currentQuestionIndex].id;
    final hasAnswered = userAnswers.containsKey(currentQId);
    
    // Logic nút bấm: Check Answer -> Next Question -> Finish
    String buttonText = 'Check Answer';
    if (showExplanation) {
      if (currentQuestionIndex < questions.length - 1) {
        buttonText = 'Next Question';
      } else {
        buttonText = 'Finish Practice';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút Back
            if (currentQuestionIndex > 0) ...[
              IconButton(
                onPressed: () {
                  setState(() {
                    currentQuestionIndex--;
                    showExplanation = false; // Reset trạng thái check khi lùi lại
                  });
                  _loadPassageIfNeeded();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
            ],
            
            // Nút Action chính
            Expanded(
              child: ElevatedButton(
                onPressed: (hasAnswered || showExplanation) ? () {
                  if (!showExplanation) {
                    // 1. Bấm Check Answer
                    setState(() => showExplanation = true);
                  } else {
                    // 2. Bấm Next hoặc Finish
                    if (currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        showExplanation = false;
                      });
                      _loadPassageIfNeeded();
                    } else {
                      _submitAnswers(context, questions);
                    }
                  }
                } : null, // Disable nếu chưa chọn đáp án
                style: ElevatedButton.styleFrom(
                  backgroundColor: showExplanation ? Colors.blue : Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitAnswers(BuildContext context, List<QuestionEntity> questions) {
    final userId = context.read<AuthBloc>().state.user?.uid;
    if (userId == null) return;

    // 1. Gọi Cubit tính điểm và lưu
    context.read<ExamCubit>().submitPracticeAndSaveScore(
      userId: userId,
      questions: questions,
      timeSpentSeconds: questions.length * 45, // Giả lập thời gian
    );

    // 2. Hiển thị Dialog chúc mừng
    // Lấy số câu đúng từ Cubit helper
    final answers = context.read<ExamCubit>().state is ExamLoadedState 
        ? (context.read<ExamCubit>().state as ExamLoadedState).practiceAnswers 
        : <String, String>{};
        
    int correct = 0;
    for(var q in questions) {
      if(answers[q.id] == q.correctAnswer) correct++;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Practice Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Score: $correct / ${questions.length}', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 3. Reset Session và thoát
              context.read<ExamCubit>().resetPracticeSession();
              Navigator.pop(ctx); // Đóng Dialog
              Navigator.pop(context); // Đóng màn hình Detail
            },
            child: const Text('Back to Menu'),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(int index, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Question ${index + 1} of $total',
        style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExplanation(QuestionEntity currentQuestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Text(currentQuestion.explanation ?? 'No explanation available.'),
        ],
      ),
    );
  }

  void _showPassageModal(BuildContext context, dynamic passage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reading Passage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (passage.title != null) 
                      Text(passage.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 12),
                    Text(passage.content ?? '', style: const TextStyle(fontSize: 16, height: 1.6)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showPartInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Part ${widget.part.partNumber}: ${widget.part.title}', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            Text(
              widget.part.description, 
              style: const TextStyle(fontSize: 16, height: 1.5)
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.questions.length} questions loaded',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }



}