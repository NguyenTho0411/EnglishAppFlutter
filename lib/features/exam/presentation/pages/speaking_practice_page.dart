import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../data/services/firestore_exam_service.dart';
import 'speaking_section_page.dart';

class SpeakingPracticePage extends StatefulWidget {
  final ExamType examType;
  final String? questionId;
  final DifficultyLevel? difficulty;

  const SpeakingPracticePage({
    super.key,
    required this.examType,
    this.questionId,
    this.difficulty,
  });

  @override
  State<SpeakingPracticePage> createState() => _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends State<SpeakingPracticePage> {
  final FirestoreExamService _examService = FirestoreExamService();
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final tests = await _examService.getSpeakingTests();
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
        builder: (context) => SpeakingSectionPage(
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
    final overallBand = results['overallBand'] ?? 0.0;
    final fluency = results['fluency'] ?? 0.0;
    final vocabulary = results['vocabulary'] ?? 0.0;
    final grammar = results['grammar'] ?? 0.0;
    final pronunciation = results['pronunciation'] ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Practice Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Band: $overallBand', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 12.h),
            Text('Fluency: $fluency', style: TextStyle(fontSize: 16.sp)),
            Text('Vocabulary: $vocabulary', style: TextStyle(fontSize: 16.sp)),
            Text('Grammar: $grammar', style: TextStyle(fontSize: 16.sp)),
            Text('Pronunciation: $pronunciation', style: TextStyle(fontSize: 16.sp)),
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
        title: Text('${widget.examType.name.toUpperCase()} Speaking Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_outlined,
                        size: 100.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'No speaking tests available',
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
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.mic_outlined,
                            color: Colors.red,
                            size: 32.w,
                          ),
                        ),
                        title: Text(
                          test['title'] ?? 'Speaking Test ${test['testNumber'] ?? index + 1}',
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
                              test['description'] ?? 'Practice your speaking skills',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.timer, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '11-14 mins',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(width: 16.w),
                                Icon(Icons.question_answer, size: 16.w, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '3 parts',
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
