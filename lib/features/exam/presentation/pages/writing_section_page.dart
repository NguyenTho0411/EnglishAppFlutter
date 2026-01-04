import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/services/firestore_exam_service.dart';
import '../../data/services/openai_service.dart';
import '../../utils/ielts_band_calculator.dart';

class WritingSectionPage extends StatefulWidget {
  final String testId;
  final Function(Map<String, dynamic>) onComplete;

  const WritingSectionPage({super.key, required this.testId, required this.onComplete});

  @override
  State<WritingSectionPage> createState() => _WritingSectionPageState();
}

class _WritingSectionPageState extends State<WritingSectionPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  final OpenAIService _openAIService = OpenAIService();
  
  bool _isLoading = true;
  bool _isGrading = false;
  Map<String, dynamic>? _testData;
  List<Map<String, dynamic>> _tasks = [];
  int _currentTaskIndex = 0;
  
  final _task1Controller = TextEditingController();
  final _task2Controller = TextEditingController();
  
  int _timeRemaining = 3600; // 60 minutes
  
  @override
  void initState() {
    super.initState();
    _loadTest();
    _startTimer();
  }

  Future<void> _loadTest() async {
    try {
      final data = await _examService.getWritingTest(widget.testId);
      if (data != null && mounted) {
        setState(() {
          _testData = data;
          _tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _timeRemaining > 0) {
        setState(() => _timeRemaining--);
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _task1Controller.dispose();
    _task2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Writing')), body: Center(child: CircularProgressIndicator()));
    if (_testData == null) return Scaffold(appBar: AppBar(title: Text('Writing')), body: Center(child: Text('No data')));

    final task = _tasks[_currentTaskIndex];
    final controller = _currentTaskIndex == 0 ? _task1Controller : _task2Controller;
    final wordCount = controller.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minWords = task['minWords'] ?? 150;

    return Scaffold(
      appBar: AppBar(
        title: Text('Writing Section'),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(color: _timeRemaining < 300 ? Colors.red : Colors.blue[700], borderRadius: BorderRadius.circular(8.r)),
            child: Row(children: [Icon(Icons.timer, color: Colors.white, size: 18.w), SizedBox(width: 6.w), Text('${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold))]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(12.r)),
                    child: Row(children: [Icon(Icons.edit, color: Colors.white, size: 24.w), SizedBox(width: 12.w), Text('Task ${task['taskNumber']}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white))]),
                  ),
                  SizedBox(height: 20.h),
                  if (task['imageUrl'] != null) ...[Container(height: 250.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 60.w, color: Colors.grey[400]), SizedBox(height: 12.h), Text('Chart/Graph', style: TextStyle(color: Colors.grey[600]))]))), SizedBox(height: 20.h)],
                  Container(padding: EdgeInsets.all(20.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: Text(task['prompt'] ?? '', style: TextStyle(fontSize: 16.sp, height: 1.8))),
                  SizedBox(height: 16.h),
                  Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.amber[200]!)), child: Row(children: [Icon(Icons.info_outline, color: Colors.amber[900], size: 20.w), SizedBox(width: 12.w), Expanded(child: Text('Write at least $minWords words', style: TextStyle(fontSize: 14.sp, color: Colors.amber[900], fontWeight: FontWeight.w500)))])),
                ],
              ),
            ),
            Divider(height: 1, thickness: 2),
            Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Answer', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(color: wordCount >= minWords ? Colors.green[100] : Colors.orange[100], borderRadius: BorderRadius.circular(8.r), border: Border.all(color: wordCount >= minWords ? Colors.green[300]! : Colors.orange[300]!)),
                        child: Row(children: [Icon(wordCount >= minWords ? Icons.check_circle : Icons.edit_note, size: 16.w, color: wordCount >= minWords ? Colors.green[700] : Colors.orange[700]), SizedBox(width: 6.w), Text('$wordCount words', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: wordCount >= minWords ? Colors.green[700] : Colors.orange[700]))]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 400.h,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, width: 2), borderRadius: BorderRadius.circular(12.r)),
                    child: TextField(controller: controller, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, style: TextStyle(fontSize: 16.sp, height: 1.8), decoration: InputDecoration(border: InputBorder.none, hintText: 'Start typing...'), onChanged: (_) => setState(() {})),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))]),
      child: Row(
        children: [
          if (_currentTaskIndex > 0) ...[OutlinedButton(onPressed: () => setState(() => _currentTaskIndex--), child: Text('Task 1')), SizedBox(width: 12.w)],
          Spacer(),
          if (_currentTaskIndex < _tasks.length - 1)
            ElevatedButton.icon(onPressed: () => setState(() => _currentTaskIndex++), icon: Icon(Icons.arrow_forward), label: Text('Task 2'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]))
          else
            ElevatedButton.icon(onPressed: _isGrading ? null : _submitAnswers, icon: _isGrading ? SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.check), label: Text(_isGrading ? 'Grading...' : 'Submit'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700])),
        ],
      ),
    );
  }

  Future<void> _submitAnswers() async {
    setState(() => _isGrading = true);
    
    try {
      final task1Result = await _openAIService.gradeWriting(taskPrompt: _tasks[0]['prompt'], userAnswer: _task1Controller.text, taskNumber: 1);
      final task2Result = await _openAIService.gradeWriting(taskPrompt: _tasks[1]['prompt'], userAnswer: _task2Controller.text, taskNumber: 2);
      
      final task1Score = IELTSBandCalculator.convertAIScoreToBand(task1Result['overall_score'] ?? 5.0);
      final task2Score = IELTSBandCalculator.convertAIScoreToBand(task2Result['overall_score'] ?? 5.0);
      final overallBand = IELTSBandCalculator.roundToHalfBand((task1Score + task2Score * 2) / 3);
      
      widget.onComplete({'writingBand': overallBand, 'writingTask1Score': task1Score, 'writingTask2Score': task2Score, 'writingAnswers': {'task1': _task1Controller.text, 'task2': _task2Controller.text, 'task1Feedback': task1Result, 'task2Feedback': task2Result}});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Grading error: $e')));
    } finally {
      setState(() => _isGrading = false);
    }
  }
}
