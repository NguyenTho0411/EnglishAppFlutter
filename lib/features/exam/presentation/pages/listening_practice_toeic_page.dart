import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/widgets/exam_audio_player.dart';
import 'package:flutter_application_1/features/authentication/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/question_entity.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';

class ListeningPracticeToeicPage extends StatefulWidget {
  const ListeningPracticeToeicPage({Key? key}) : super(key: key);

  @override
  State<ListeningPracticeToeicPage> createState() => _ListeningPracticeToeicPageState();
}

class _ListeningPracticeToeicPageState extends State<ListeningPracticeToeicPage> {
  
  @override
  void initState() {
    super.initState();
    _loadData(); // Load lần đầu
  }

  // ✅ 1. Hàm load dữ liệu (dùng chung cho Init, Pull-to-refresh và Return)
  Future<void> _loadData() async {
    // Gọi Cubit load lại danh sách
    await context.read<ExamCubit>().loadToeicListeningQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOEIC Listening Practice'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          if (state is ExamLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamErrorState) {
            // Cho phép kéo xuống để thử lại khi lỗi
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(child: Text('Error: ${state.message}')),
                ],
              ),
            );
          }

          if (state is ExamLoadedState) {
            final questions = state.questions;

            final part1 = questions.where((q) => q.part == 1).toList();
            final part2 = questions.where((q) => q.part == 2).toList();
            final part3 = questions.where((q) => q.part == 3).toList();
            final part4 = questions.where((q) => q.part == 4).toList();

            // ✅ 2. Bọc ListView bằng RefreshIndicator
            return RefreshIndicator(
              onRefresh: _loadData, // Gọi hàm khi kéo xuống
              child: ListView(
                // Luôn cho phép scroll để RefreshIndicator hoạt động ngay cả khi list ngắn
                physics: const AlwaysScrollableScrollPhysics(), 
                padding: const EdgeInsets.all(16),
                children: [
                  _partTile(context, 'Part 1 – Photographs', Icons.image, part1),
                  _partTile(context, 'Part 2 – Question–Response', Icons.record_voice_over, part2),
                  _partTile(context, 'Part 3 – Conversations', Icons.forum, part3),
                  _partTile(context, 'Part 4 – Short Talks', Icons.campaign, part4),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _partTile(BuildContext context, String title, IconData icon, List<QuestionEntity> questions) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${questions.length} questions'),
        trailing: const Icon(Icons.chevron_right),
        enabled: questions.isNotEmpty,
        onTap: () async { // ✅ Đánh dấu async
          if (questions.isNotEmpty) {
            // ✅ 3. Dùng await để đợi người dùng quay lại
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToeicListeningPracticeDetailPage(
                  title: title,
                  questions: questions,
                ),
              ),
            );

            // ✅ Sau khi quay lại (pop), code sẽ chạy tiếp dòng dưới này:
            if (mounted) {
              _loadData(); // Load lại dữ liệu để cập nhật thống kê hoặc reset trạng thái
            }
          }
        },
      ),
    );
  }
}



class ToeicListeningPracticeDetailPage extends StatefulWidget {
  final String title;
  final List<QuestionEntity> questions;

  const ToeicListeningPracticeDetailPage({
    Key? key,
    required this.title,
    required this.questions,
  }) : super(key: key);

  @override
  State<ToeicListeningPracticeDetailPage> createState() =>
      _ToeicListeningPracticeDetailPageState();
}

class _ToeicListeningPracticeDetailPageState
    extends State<ToeicListeningPracticeDetailPage> {
  
  int currentQuestionIndex = 0;
  bool showExplanation = false; // Trạng thái: Đã hiện giải thích chưa

  @override
  void initState() {
    super.initState();
    // Load audio cho câu đầu tiên ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentAudio();
    });
  }

  // Hàm load audio dựa trên audioId của câu hỏi hiện tại
  void _loadCurrentAudio() {
    final currentQuestion = widget.questions[currentQuestionIndex];
    if (currentQuestion.audioId != null) {
      context.read<ExamCubit>().loadAudioById(currentQuestion.audioId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final q = questions[currentQuestionIndex];
    
    // Lấy options text & Image URL từ metadata
    final optionsTextMap = q.metadata?['optionsText'] as Map<String, dynamic>? ?? {};
    final imageUrl = q.metadata?['imageUrl'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          // 1. Lấy Map câu trả lời từ Cubit (Session State)
          Map<String, String> userAnswers = {};
          if (state is ExamLoadedState) {
            userAnswers = state.practiceAnswers;
          }

          return Column(
            children: [
              // === AUDIO PLAYER SECTION ===
              // Chỉ hiển thị khi Audio đã load xong
              if (state is ExamLoadedState && state.audio != null)
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExamAudioPlayer(
                    audioUrl: state.audio!.audioUrl,
                    autoPlay: true, // Tự động phát khi chuyển câu
                  ),
                ),

              // === PROGRESS BAR ===
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                color: Colors.blueAccent,
                minHeight: 4,
              ),

              // === QUESTION CONTENT ===
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Question 1/10
                      _buildQuestionHeader(currentQuestionIndex, questions.length),
                      const SizedBox(height: 16),

                      // PART 1: HIỂN THỊ ẢNH
                      if (q.part == 1 && imageUrl != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (ctx, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                            ),
                          ),
                        ),

                      // CÂU HỎI (Text)
                      if (q.questionText.isNotEmpty)
                        Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w600,
                            height: 1.4
                          ),
                        ),

                      const SizedBox(height: 24),

                      // CÁC LỰA CHỌN (OPTIONS) - Logic giống Reading
                      _buildOptions(q, userAnswers, optionsTextMap),

                      // GIẢI THÍCH (Chỉ hiện khi bấm Check)
                      if (showExplanation) ...[
                        const SizedBox(height: 24),
                        _buildExplanation(q),
                      ],
                    ],
                  ),
                ),
              ),

              // === BOTTOM BAR ===
              _buildBottomBar(context, questions, userAnswers),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị Header (Question X of Y)
  Widget _buildQuestionHeader(int index, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Question ${index + 1} of $total',
        style: const TextStyle(
          color: Colors.blue, 
          fontSize: 13, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // Widget hiển thị Options (Logic giống hệt Reading)
  Widget _buildOptions(
    QuestionEntity currentQuestion, 
    Map<String, String> userAnswers,
    Map<String, dynamic> optionsTextMap
  ) {
    // Nếu options null hoặc rỗng thì không render
    if (currentQuestion.options == null || currentQuestion.options!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: currentQuestion.options!.map<Widget>((optionKey) {
        // 1. Lấy đáp án đã chọn từ Cubit (Session)
        final selectedAnswer = userAnswers[currentQuestion.id];
        
        final isSelected = selectedAnswer == optionKey;
        final isCorrect = showExplanation && optionKey == currentQuestion.correctAnswer;
        final isWrong = showExplanation && isSelected && optionKey != currentQuestion.correctAnswer;

        // 2. Logic màu sắc
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

        // 3. Lấy text hiển thị (cho Part 3,4) hoặc fallback (cho Part 1,2)
        final displayText = optionsTextMap[optionKey] ?? 'Option $optionKey';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: showExplanation 
              ? null // Khóa khi đã hiện giải thích
              : () {
                  // Gọi Cubit lưu đáp án vào RAM
                  context.read<ExamCubit>().selectPracticeAnswer(
                    currentQuestion.id, 
                    optionKey
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
                      optionKey,
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
                      displayText,
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

  // Widget hiển thị giải thích
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

  // Bottom Bar (Check Answer -> Next -> Finish)
  Widget _buildBottomBar(BuildContext context, List<QuestionEntity> questions, Map<String, String> userAnswers) {
    // Check xem câu hiện tại đã được chọn chưa
    final currentQId = questions[currentQuestionIndex].id;
    final hasAnswered = userAnswers.containsKey(currentQId);
    
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
                    showExplanation = false;
                  });
                  _loadCurrentAudio(); // Load lại audio cũ
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
            ],
            
            // Nút Action
            Expanded(
              child: ElevatedButton(
                onPressed: (hasAnswered || showExplanation) ? () {
                  if (!showExplanation) {
                    // Bấm Check Answer
                    setState(() => showExplanation = true);
                  } else {
                    // Bấm Next hoặc Finish
                    if (currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        showExplanation = false;
                      });
                      _loadCurrentAudio(); // Load audio mới
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

  // Hàm Nộp bài và Lưu kết quả
  void _submitAnswers(BuildContext context, List<QuestionEntity> questions) {
    final userId = context.read<AuthBloc>().state.user?.uid;
    if (userId == null) return;

    // 1. Lưu kết quả Listening
    context.read<ExamCubit>().submitPracticeAndSaveScore(
      userId: userId,
      questions: questions,
      timeSpentSeconds: questions.length * 45, // Giả lập thời gian
    );

    // 2. Tính điểm hiển thị Dialog
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
        title: const Text('Listening Practice Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.headphones, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text('Score: $correct / ${questions.length}', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 3. Reset session và thoát
              context.read<ExamCubit>().resetPracticeSession();
              Navigator.pop(ctx); 
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          )
        ],
      ),
    );
  }
}
