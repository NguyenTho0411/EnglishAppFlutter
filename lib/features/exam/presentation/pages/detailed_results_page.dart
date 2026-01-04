import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/services/firestore_exam_service.dart';

class DetailedResultsPage extends StatefulWidget {
  final Map<String, dynamic> testResults;

  const DetailedResultsPage({super.key, required this.testResults});

  @override
  State<DetailedResultsPage> createState() => _DetailedResultsPageState();
}

class _DetailedResultsPageState extends State<DetailedResultsPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  bool _isLoadingCorrectAnswers = false;
  Map<String, dynamic>? _readingCorrectAnswers;
  Map<String, dynamic>? _listeningCorrectAnswers;

  @override
  void initState() {
    super.initState();
    _loadCorrectAnswersIfNeeded();
  }

  Future<void> _loadCorrectAnswersIfNeeded() async {
    // Load correct answers from Firebase if user hasn't completed the sections
    final needsReading = widget.testResults['readingAnswers'] == null;
    final needsListening = widget.testResults['listeningAnswers'] == null;

    if (!needsReading && !needsListening) return;

    setState(() => _isLoadingCorrectAnswers = true);

    try {
      if (needsReading) {
        final data = await _examService.getReadingTest('test1');
        if (data != null) {
          final correctAnswers = <String, dynamic>{};
          final questions = <String, dynamic>{};
          
          final passages = List<Map<String, dynamic>>.from(data['passages'] ?? []);
          for (var passage in passages) {
            final passageQuestions = List<Map<String, dynamic>>.from(passage['questions'] ?? []);
            for (var q in passageQuestions) {
              final id = q['id']?.toString() ?? '';
              correctAnswers[id] = q['correctAnswer'];
              questions[id] = q['question'];
            }
          }
          
          _readingCorrectAnswers = {
            'correctAnswers': correctAnswers,
            'questions': questions,
          };
        }
      }

      if (needsListening) {
        final data = await _examService.getListeningTest('listeningTest1');
        if (data != null) {
          final correctAnswers = <String, dynamic>{};
          final questions = <String, dynamic>{};
          
          final sections = List<Map<String, dynamic>>.from(data['sections'] ?? []);
          for (var section in sections) {
            final sectionQuestions = List<Map<String, dynamic>>.from(section['questions'] ?? []);
            for (var q in sectionQuestions) {
              final id = q['id']?.toString() ?? '';
              correctAnswers[id] = q['correctAnswer'];
              questions[id] = q['question'];
            }
          }
          
          _listeningCorrectAnswers = {
            'correctAnswers': correctAnswers,
            'questions': questions,
          };
        }
      }
    } catch (e) {
      print('Error loading correct answers: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCorrectAnswers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCorrectAnswers) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết bài làm'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết bài làm'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Reading Section - Always show
          _buildSectionHeader('Reading', Icons.book, Colors.blue),
          widget.testResults['readingAnswers'] != null
              ? _buildReadingDetails()
              : _buildReadingCorrectAnswersOnly(),
          SizedBox(height: 24.h),
          
          // Listening Section - Always show
          _buildSectionHeader('Listening', Icons.headphones, Colors.orange),
          widget.testResults['listeningAnswers'] != null
              ? _buildListeningDetails()
              : _buildListeningCorrectAnswersOnly(),
          SizedBox(height: 24.h),
          
          // Writing Section - Always show
          _buildSectionHeader('Writing', Icons.edit, Colors.green),
          widget.testResults['writingAnswers'] != null
              ? _buildWritingDetails()
              : _buildNotCompletedSection('Writing'),
          SizedBox(height: 24.h),
          
          // Speaking Section - Always show
          _buildSectionHeader('Speaking', Icons.mic, Colors.red),
          widget.testResults['speakingDetailedFeedback'] != null || widget.testResults['speakingTranscripts'] != null
              ? _buildSpeakingDetails()
              : _buildNotCompletedSection('Speaking'),
        ],
      ),
    );
  }

  Widget _buildNotCompletedSection(String sectionName) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48.w, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(
            'Chưa hoàn thành phần $sectionName',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bạn đã bỏ qua phần này trong bài thi',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.w),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Spacer(),
          Text(
            'Band ${widget.testResults['${title.toLowerCase()}Band']?.toStringAsFixed(1) ?? '0.0'}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingDetails() {
    final answers = widget.testResults['readingAnswers'] as Map<String, dynamic>?;
    final correctAnswers = widget.testResults['readingCorrectAnswers'] as Map<String, dynamic>?;
    final questions = widget.testResults['readingQuestions'] as Map<String, dynamic>?;
    
    if (answers == null || correctAnswers == null) return SizedBox();

    return Column(
      children: answers.entries.map((entry) {
        final questionId = entry.key;
        final userAnswer = entry.value?.toString() ?? '';
        final correctAnswer = correctAnswers[questionId]?.toString() ?? 'N/A';
        final questionText = questions?[questionId]?.toString() ?? questionId;
        final isCorrect = userAnswer.toUpperCase() == correctAnswer.toUpperCase();
        
        return _buildQuestionCard(
          questionId: questionText,
          userAnswer: userAnswer,
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
        );
      }).toList(),
    );
  }

  Widget _buildReadingCorrectAnswersOnly() {
    if (_readingCorrectAnswers == null) {
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48.w, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              'Chưa hoàn thành phần Reading',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    final correctAnswers = _readingCorrectAnswers!['correctAnswers'] as Map<String, dynamic>;
    final questions = _readingCorrectAnswers!['questions'] as Map<String, dynamic>;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Chưa làm bài - Dưới đây là đáp án đúng',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...correctAnswers.entries.map((entry) {
          final questionId = entry.key;
          final correctAnswer = entry.value?.toString() ?? '';
          final questionText = questions[questionId]?.toString() ?? questionId;
          
          return _buildCorrectAnswerOnlyCard(
            questionId: questionText,
            correctAnswer: correctAnswer,
            color: Colors.blue,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildListeningDetails() {
    final answers = widget.testResults['listeningAnswers'] as Map<String, dynamic>?;
    final correctAnswers = widget.testResults['listeningCorrectAnswers'] as Map<String, dynamic>?;
    final questions = widget.testResults['listeningQuestions'] as Map<String, dynamic>?;
    
    if (answers == null || correctAnswers == null) return SizedBox();

    return Column(
      children: answers.entries.map((entry) {
        final questionId = entry.key;
        final userAnswer = entry.value?.toString() ?? '';
        final correctAnswer = correctAnswers[questionId]?.toString() ?? 'N/A';
        final questionText = questions?[questionId]?.toString() ?? questionId;
        final isCorrect = userAnswer.toUpperCase() == correctAnswer.toUpperCase();
        
        return _buildQuestionCard(
          questionId: questionText,
          userAnswer: userAnswer,
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
        );
      }).toList(),
    );
  }

  Widget _buildListeningCorrectAnswersOnly() {
    if (_listeningCorrectAnswers == null) {
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48.w, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              'Chưa hoàn thành phần Listening',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    final correctAnswers = _listeningCorrectAnswers!['correctAnswers'] as Map<String, dynamic>;
    final questions = _listeningCorrectAnswers!['questions'] as Map<String, dynamic>;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Chưa làm bài - Dưới đây là đáp án đúng',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...correctAnswers.entries.map((entry) {
          final questionId = entry.key;
          final correctAnswer = entry.value?.toString() ?? '';
          final questionText = questions[questionId]?.toString() ?? questionId;
          
          return _buildCorrectAnswerOnlyCard(
            questionId: questionText,
            correctAnswer: correctAnswer,
            color: Colors.orange,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWritingDetails() {
    final writingData = widget.testResults['writingAnswers'] as Map<String, dynamic>?;
    if (writingData == null) return SizedBox();

    final task1 = writingData['task1'] ?? '';
    final task2 = writingData['task2'] ?? '';
    final task1Feedback = writingData['task1Feedback'];
    final task2Feedback = writingData['task2Feedback'];

    return Column(
      children: [
        // Task 1
        _buildWritingTaskCard(
          taskNumber: 1,
          answer: task1,
          score: widget.testResults['writingTask1Score'],
          feedback: task1Feedback,
        ),
        SizedBox(height: 16.h),
        // Task 2
        _buildWritingTaskCard(
          taskNumber: 2,
          answer: task2,
          score: widget.testResults['writingTask2Score'],
          feedback: task2Feedback,
        ),
      ],
    );
  }

  Widget _buildSpeakingDetails() {
    final detailedFeedback = widget.testResults['speakingDetailedFeedback'] as Map<String, dynamic>?;
    
    if (detailedFeedback == null || detailedFeedback.isEmpty) return SizedBox();

    // Group by parts
    final part1Questions = detailedFeedback.entries.where((e) => e.key.startsWith('part1')).toList();
    final part2Question = detailedFeedback['part2_cuecard'];
    final part3Questions = detailedFeedback.entries.where((e) => e.key.startsWith('part3')).toList();

    return Column(
      children: [
        // Part 1
        if (part1Questions.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.red[700]),
                SizedBox(width: 8.w),
                Text('Part 1 - Introduction & Interview', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red[700])),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ...part1Questions.map((entry) => _buildSpeakingQuestionCard(entry.value)),
          SizedBox(height: 16.h),
        ],
        
        // Part 2
        if (part2Question != null) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.red[700]),
                SizedBox(width: 8.w),
                Text('Part 2 - Long Turn (Cue Card)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red[700])),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildSpeakingQuestionCard(part2Question),
          SizedBox(height: 16.h),
        ],
        
        // Part 3
        if (part3Questions.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.forum, color: Colors.red[700]),
                SizedBox(width: 8.w),
                Text('Part 3 - Discussion', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red[700])),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ...part3Questions.map((entry) => _buildSpeakingQuestionCard(entry.value)),
        ],
      ],
    );
  }

  Widget _buildSpeakingQuestionCard(Map<String, dynamic> data) {
    final question = data['question']?.toString() ?? '';
    final transcript = data['transcript']?.toString() ?? '';
    final score = data['score'] ?? 0.0;
    final feedback = data['feedback']?.toString() ?? '';
    final strengths = List<String>.from(data['strengths'] ?? []);
    final improvements = List<String>.from(data['improvements'] ?? []);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Band ${score.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text('Transcript:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              transcript.isEmpty ? '(Không có ghi âm)' : transcript,
              style: TextStyle(fontSize: 13.sp, height: 1.5),
            ),
          ),
          if (feedback.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text('AI Feedback:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(feedback, style: TextStyle(fontSize: 13.sp, height: 1.5)),
            ),
          ],
          if (strengths.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text('✅ Điểm mạnh:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.green[700])),
            ...strengths.map((s) => Padding(
              padding: EdgeInsets.only(left: 12.w, top: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.green[700])),
                  Expanded(child: Text(s, style: TextStyle(fontSize: 12.sp, color: Colors.green[700]))),
                ],
              ),
            )),
          ],
          if (improvements.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text('🔧 Cần cải thiện:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.orange[700])),
            ...improvements.map((s) => Padding(
              padding: EdgeInsets.only(left: 12.w, top: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.orange[700])),
                  Expanded(child: Text(s, style: TextStyle(fontSize: 12.sp, color: Colors.orange[700]))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String questionId,
    required String userAnswer,
    required String correctAnswer,
    required bool? isCorrect,
  }) {
    final color = isCorrect == null ? Colors.grey : (isCorrect ? Colors.green : Colors.red);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  questionId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Spacer(),
              if (isCorrect != null)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 24.w,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildAnswerRow('Câu trả lời của bạn:', userAnswer, Colors.blue),
          SizedBox(height: 8.h),
          _buildAnswerRow('Đáp án đúng:', correctAnswer, Colors.green),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            answer.isEmpty ? '(Chưa trả lời)' : answer,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWritingTaskCard({
    required int taskNumber,
    required String answer,
    required double? score,
    required Map<String, dynamic>? feedback,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Task $taskNumber',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Band ${score?.toStringAsFixed(1) ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Bài làm của bạn:',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              answer.isEmpty ? '(Chưa làm)' : answer,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ),
          if (feedback != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Nhận xét từ AI:',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                feedback['feedback']?.toString() ?? 'No feedback',
                style: TextStyle(fontSize: 13.sp, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectAnswerOnlyCard({
    required String questionId,
    required String correctAnswer,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionId,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 20.w),
              SizedBox(width: 8.w),
              Text('Đáp án đúng:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    correctAnswer,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
