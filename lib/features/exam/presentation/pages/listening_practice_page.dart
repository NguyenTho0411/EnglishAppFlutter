import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../data/services/firestore_exam_service.dart';
import 'listening_section_page.dart';
import '../../utils/ielts_band_calculator.dart';
import '../../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';

class ListeningPracticePage extends StatefulWidget {
  final ExamType examType;
  final String? audioId;
  final DifficultyLevel? difficulty;

  const ListeningPracticePage({
    super.key,
    required this.examType,
    this.audioId,
    this.difficulty,
  });

  @override
  State<ListeningPracticePage> createState() => _ListeningPracticePageState();
}

class _ListeningPracticePageState extends State<ListeningPracticePage> {
  final FirestoreExamService _examService = FirestoreExamService();
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final tests = await _examService.getListeningTests();
    if (mounted) {
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    }
  }

  void _startTest(Map<String, dynamic> test) {
    final testId = test['testId'] ?? test['id'] ?? '';
    final testTitle = test['title'] ?? 'Listening Test ${test['testNumber'] ?? ''}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListeningSectionPage(
          testId: testId,
          onComplete: (results) {
            Navigator.pop(context);
            // Add testId and testTitle to results
            results['testId'] = testId;
            results['testTitle'] = testTitle;
            _showResults(results);
          },
        ),
      ),
    );
  }

  void _showResults(Map<String, dynamic> results) {
    final correctCount = results['listeningCorrect'] ?? 0;
    final totalQuestions = results['listeningTotal'] ?? 0;
    final bandScore = results['listeningBand'] ?? 0.0;

    // Save to Firebase
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _examService.savePracticeResult(
        userId: user.uid,
        skillType: 'listening',
        testId: results['testId'] ?? '',
        results: {
          'testTitle': results['testTitle'] ?? 'Listening Practice',
          'score': correctCount,
          'totalQuestions': totalQuestions,
          'bandScore': bandScore,
          'timeSpent': results['timeSpent'] ?? 0,
          'details': results,
        },
      ).catchError((e) => print('Error saving result: $e'));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Practice Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correct: $correctCount / $totalQuestions', style: TextStyle(fontSize: 18.sp)),
            SizedBox(height: 8.h),
            Text('Band Score: $bandScore', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType.name.toUpperCase()} Listening Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.headphones_outlined,
                        size: 100.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'No listening tests available',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _tests.length,
                  itemBuilder: (context, index) {
                    final test = _tests[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.w),
                        leading: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.headphones_outlined,
                            color: Colors.orange,
                            size: 32.w,
                          ),
                        ),
                        title: Text(
                          test['title'] ?? 'Listening Test ${test['testNumber'] ?? index + 1}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            Text(
                              test['description'] ?? 'Practice your listening skills',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.timer, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '${test['duration'] ?? 30} mins',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(width: 16.w),
                                Icon(Icons.question_answer, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '${test['totalQuestions'] ?? 40} questions',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => _startTest(test),
                      ),
                    );
                  },
                ),
    );
  }
}
