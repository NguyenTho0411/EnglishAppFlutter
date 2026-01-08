import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../data/services/firestore_exam_service.dart';
import 'writing_section_page.dart';
import '../../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';

class WritingPracticePage extends StatefulWidget {
  final ExamType examType;
  final String? taskId;
  final DifficultyLevel? difficulty;

  const WritingPracticePage({
    super.key,
    required this.examType,
    this.taskId,
    this.difficulty,
  });

  @override
  State<WritingPracticePage> createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  final FirestoreExamService _examService = FirestoreExamService();
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final tests = await _examService.getWritingTests();
    if (mounted) {
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    }
  }

  void _startTest(Map<String, dynamic> test) {
    final testId = test['testId'] ?? test['id'] ?? '';
    final testTitle = test['title'] ?? 'Writing Test ${test['testNumber'] ?? ''}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritingSectionPage(
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
    final task1Band = results['writingTask1Score'] ?? 0.0;
    final task2Band = results['writingTask2Score'] ?? 0.0;
    final overallBand = results['writingBand'] ?? 0.0;

    // Save to Firebase
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _examService.savePracticeResult(
        userId: user.uid,
        skillType: 'writing',
        testId: results['testId'] ?? '',
        results: {
          'testTitle': results['testTitle'] ?? 'Writing Practice',
          'score': 0,
          'totalQuestions': 2,
          'bandScore': overallBand,
          'timeSpent': results['timeSpent'] ?? 0,
          'details': {'task1Band': task1Band, 'task2Band': task2Band, 'overallBand': overallBand},
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
            Text('Task 1 Band: ${task1Band.toStringAsFixed(1)}', style: TextStyle(fontSize: 18.sp)),
            SizedBox(height: 8.h),
            Text('Task 2 Band: ${task2Band.toStringAsFixed(1)}', style: TextStyle(fontSize: 18.sp)),
            SizedBox(height: 8.h),
            Text('Overall Band: ${overallBand.toStringAsFixed(1)}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)),
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
        title: Text('${widget.examType.name.toUpperCase()} Writing Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 100.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'No writing tests available',
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
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.green,
                            size: 32.w,
                          ),
                        ),
                        title: Text(
                          test['title'] ?? 'Writing Test ${test['testNumber'] ?? index + 1}',
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
                              test['description'] ?? 'Practice your writing skills',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.timer, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '60 mins',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(width: 16.w),
                                Icon(Icons.assignment, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '2 tasks',
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
