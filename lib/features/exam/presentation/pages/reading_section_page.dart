import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/services/firestore_exam_service.dart';
import '../../utils/ielts_band_calculator.dart';

class ReadingSectionPage extends StatefulWidget {
  final String testId;
  final Function(Map<String, dynamic>) onComplete;

  const ReadingSectionPage({
    super.key,
    required this.testId,
    required this.onComplete,
  });

  @override
  State<ReadingSectionPage> createState() => _ReadingSectionPageState();
}

class _ReadingSectionPageState extends State<ReadingSectionPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _testData;
  List<Map<String, dynamic>> _passages = [];
  
  int _currentPassageIndex = 0;
  final Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  Future<void> _loadTest() async {
    try {
      final data = await _examService.getReadingTest(widget.testId);
      if (data != null && mounted) {
        setState(() {
          _testData = data;
          _passages = List<Map<String, dynamic>>.from(data['passages'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reading test: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load test: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Reading Section')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_testData == null || _passages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Reading Section')),
        body: Center(child: Text('No test data available')),
      );
    }

    final passage = _passages[_currentPassageIndex];
    final questions = List<Map<String, dynamic>>.from(passage['questions'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Section'),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Text(
                'Passage ${_currentPassageIndex + 1}/${_passages.length}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top - Reading passage
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passage['title'] ?? 'Passage ${passage['passageNumber']}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    passage['content'] ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, thickness: 2, color: Colors.grey[300]),
            
            // Bottom - Questions
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ...questions.map((q) => _buildQuestion(q)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    final questionId = question['id'] ?? question['questionNumber']?.toString() ?? '';
    final questionType = question['type'] ?? 'multipleChoice';
    final selectedAnswer = _userAnswers[questionId];
    
    // For different question types
    if (questionType == 'noteCompletion' || 
        questionType == 'formCompletion' ||
        questionType == 'summaryCompletion') {
      return _buildFillInBlankQuestion(question, questionId, selectedAnswer);
    } else if (questionType == 'trueFalseNotGiven' || 
               questionType == 'yesNoNotGiven') {
      return _buildTrueFalseQuestion(question, questionId, selectedAnswer);
    } else {
      return _buildMultipleChoiceQuestion(question, questionId, selectedAnswer);
    }
  }

  Widget _buildMultipleChoiceQuestion(
    Map<String, dynamic> question,
    String questionId,
    String? selectedAnswer,
  ) {
    final options = List<dynamic>.from(question['options'] ?? ['A', 'B', 'C', 'D']);
    final questionNumber = question['questionNumber'] ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
        color: selectedAnswer != null ? Colors.blue[50] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  question['question'] ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
            final isSelected = selectedAnswer == optionLetter;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _userAnswers[questionId] = optionLetter;
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[700] : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            color: isSelected ? Colors.blue[700] : Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        option.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFillInBlankQuestion(
    Map<String, dynamic> question,
    String questionId,
    String? selectedAnswer,
  ) {
    final questionNumber = question['questionNumber'] ?? 0;
    final controller = TextEditingController(text: selectedAnswer ?? '');
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  question['question'] ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            onChanged: (value) {
              _userAnswers[questionId] = value.trim();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseQuestion(
    Map<String, dynamic> question,
    String questionId,
    String? selectedAnswer,
  ) {
    final questionNumber = question['questionNumber'] ?? 0;
    final questionType = question['type'] ?? 'trueFalseNotGiven';
    final options = questionType == 'yesNoNotGiven' 
        ? ['YES', 'NO', 'NOT GIVEN']
        : ['TRUE', 'FALSE', 'NOT GIVEN'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
        color: selectedAnswer != null ? Colors.blue[50] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  question['question'] ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: options.map((option) {
              final isSelected = selectedAnswer == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _userAnswers[questionId] = option;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[700] : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalQuestions = _passages.fold<int>(
      0,
      (sum, p) => sum + (p['questions'] as List).length,
    );
    final answeredCount = _userAnswers.length;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress: $answeredCount/$totalQuestions answered',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: answeredCount / totalQuestions,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                  minHeight: 8.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          
          if (_currentPassageIndex > 0)
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentPassageIndex--;
                });
              },
              icon: Icon(Icons.arrow_back),
              label: Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
            ),
          
          if (_currentPassageIndex > 0) SizedBox(width: 12.w),
          
          ElevatedButton.icon(
            onPressed: () {
              if (_currentPassageIndex < _passages.length - 1) {
                setState(() {
                  _currentPassageIndex++;
                });
              } else {
                _submitAnswers();
              }
            },
            icon: Icon(
              _currentPassageIndex < _passages.length - 1
                  ? Icons.arrow_forward
                  : Icons.check,
            ),
            label: Text(
              _currentPassageIndex < _passages.length - 1
                  ? 'Next Passage'
                  : 'Submit Section',
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              backgroundColor: _currentPassageIndex < _passages.length - 1
                  ? Colors.blue[700]
                  : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _submitAnswers() {
    int correctCount = 0;
    int totalQuestions = 0;
    final Map<String, String> correctAnswers = {};
    final Map<String, String> questionTexts = {};
    
    for (var passage in _passages) {
      final questions = List<Map<String, dynamic>>.from(passage['questions'] ?? []);
      totalQuestions += questions.length;
      
      for (var question in questions) {
        final questionId = question['id'] ?? question['questionNumber']?.toString() ?? '';
        final correctAnswer = question['correctAnswer']?.toString().toUpperCase() ?? '';
        final userAnswer = _userAnswers[questionId]?.toUpperCase() ?? '';
        
        // Store correct answer and question text
        correctAnswers[questionId] = correctAnswer;
        questionTexts[questionId] = question['question']?.toString() ?? '';
        
        if (userAnswer == correctAnswer) {
          correctCount++;
        }
      }
    }
    
    final bandScore = IELTSBandCalculator.calculateBandScore(correctCount, totalQuestions);
    
    widget.onComplete({
      'readingBand': bandScore,
      'readingCorrect': correctCount,
      'readingTotal': totalQuestions,
      'readingAnswers': _userAnswers,
      'readingCorrectAnswers': correctAnswers, // ✅ Add correct answers
      'readingQuestions': questionTexts, // ✅ Add question texts
    });
  }
}
