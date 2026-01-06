import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../data/services/firestore_exam_service.dart';
import 'reading_section_page.dart';
import '../../utils/ielts_band_calculator.dart';

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
  final FirestoreExamService _examService = FirestoreExamService();
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final tests = await _examService.getReadingTests();
    if (mounted) {
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    }
  }

  void _startTest(Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingSectionPage(
          testId: test['testId'] ?? test['id'] ?? '',
          onComplete: (results) {
            Navigator.pop(context);
            _showResults(results);
          },
        ),
      ),
    );
  }

  void _showResults(Map<String, dynamic> results) {
    final correctCount = results['correctCount'] ?? 0;
    final totalQuestions = results['totalQuestions'] ?? 0;
    final bandScore = IELTSBandCalculator.calculateBandScore(correctCount, totalQuestions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Practice Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correct: $correctCount / $totalQuestions',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Band Score: $bandScore',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType.name.toUpperCase()} Reading Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 100.w, color: Colors.grey),
                  SizedBox(height: 20.h),
                  Text(
                    'No reading tests available',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
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
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.book_outlined,
                        color: Colors.blue,
                        size: 32.w,
                      ),
                    ),
                    title: Text(
                      test['title'] ??
                          'Reading Test ${test['testNumber'] ?? index + 1}',
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
                          test['description'] ?? 'Practice your reading skills',
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
                            Icon(
                              Icons.question_answer,
                              size: 16.w,
                              color: Colors.grey,
                            ),
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
