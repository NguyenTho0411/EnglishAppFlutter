import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/entities/test_attempt_entity.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';
import 'reading_section_page.dart';
import 'listening_section_page.dart';
import 'writing_section_page.dart';
import 'speaking_section_page.dart';

/// Mock Test Execution - Full test with 4 sections
class MockTestExecutionPage extends StatefulWidget {
  final ExamType examType;
  final TestEntity test;

  const MockTestExecutionPage({
    super.key,
    required this.examType,
    required this.test,
  });

  @override
  State<MockTestExecutionPage> createState() => _MockTestExecutionPageState();
}

class _MockTestExecutionPageState extends State<MockTestExecutionPage> {
  int _currentSectionIndex = 0;
  Timer? _timer;
  int _timeRemaining = 0; // seconds
  bool _isPaused = false;
  String? _attemptId;
  
  // Store results from all sections
  final Map<String, dynamic> _testResults = {
    'listeningBand': 0.0,
    'readingBand': 0.0,
    'writingBand': 0.0,
    'speakingBand': 0.0,
  };

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
    // Start test attempt in Cubit
    context.read<ExamCubit>().startTest(
      testId: widget.test.id,
      examType: widget.examType,
    );
    
    // Start timer for first section
    _startSectionTimer();
  }

  void _startSectionTimer() {
    final section = widget.test.sections[_currentSectionIndex];
    _timeRemaining = section.timeLimit * 60; // Convert to seconds
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            // Time's up - auto move to next section
            _nextSection();
          }
        });
      }
    });
  }

  void _pauseTest() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _nextSection() {
    _timer?.cancel();
    
    final currentSection = widget.test.sections[_currentSectionIndex];
    
    // Navigate to dedicated page based on skill type
    Widget? sectionPage;
    
    switch (currentSection.skill) {
      case SkillType.listening:
        sectionPage = ListeningSectionPage(
          testId: 'listeningTest1',
          onComplete: (results) {
            _testResults.addAll(results);
            Navigator.pop(context);
          },
        );
        break;
      case SkillType.reading:
        sectionPage = ReadingSectionPage(
          testId: 'test1',
          onComplete: (results) {
            _testResults.addAll(results);
            Navigator.pop(context);
          },
        );
        break;
      case SkillType.writing:
        sectionPage = WritingSectionPage(
          testId: 'test1',
          onComplete: (results) {
            _testResults.addAll(results);
            Navigator.pop(context);
          },
        );
        break;
      case SkillType.speaking:
        sectionPage = SpeakingSectionPage(
          testId: 'speaking_test_1',
          onComplete: (results) {
            _testResults.addAll(results);
            Navigator.pop(context);
          },
        );
        break;
    }
    
    if (sectionPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => sectionPage!),
      ).then((_) {
        // After completing section, move to next
        if (_currentSectionIndex < widget.test.sections.length - 1) {
          setState(() {
            _currentSectionIndex++;
          });
          _startSectionTimer();
        } else {
          _completeTest();
        }
      });
      return;
    }
    
    // Fallback: continue normally
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
      _timer?.cancel();
      setState(() {
        _currentSectionIndex--;
      });
      _startSectionTimer();
    }
  }

  void _completeTest() {
    _timer?.cancel();
    
    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete Test?'),
        content: const Text('Are you sure you want to submit your test? You cannot change your answers after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitTest() {
    // Calculate overall band from 4 sections
    final listeningBand = _testResults['listeningBand'] ?? 0.0;
    final readingBand = _testResults['readingBand'] ?? 0.0;
    final writingBand = _testResults['writingBand'] ?? 0.0;
    final speakingBand = _testResults['speakingBand'] ?? 0.0;
    
    final overallBand = (listeningBand + readingBand + writingBand + speakingBand) / 4;
    final roundedOverallBand = (overallBand * 2).round() / 2; // Round to nearest 0.5
    
    _testResults['overallBand'] = roundedOverallBand;
    
    // Submit to Cubit
    context.read<ExamCubit>().completeTest(_attemptId ?? widget.test.id);
    
    // Navigate to results page with actual results
    context.pushReplacement(
      '/mockTestResults',
      extra: {
        'examType': widget.examType,
        'test': widget.test,
        'attemptId': _attemptId ?? widget.test.id,
        'results': _testResults, // ✅ Pass actual results
      },
    );
  }

  void _exitTest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Your progress will be saved. You can resume later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = widget.test.sections[_currentSectionIndex];
    
    return WillPopScope(
      onWillPop: () async {
        _exitTest();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.test.title}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitTest,
          ),
          actions: [
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: _pauseTest,
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            _buildProgressBar(),
            
            // Timer and section info
            _buildHeader(currentSection),
            
            // Section content
            Expanded(
              child: _buildSectionContent(currentSection),
            ),
            
            // Navigation buttons
            _buildNavigationBar(),
          ],
        ),
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
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
      ),
    );
  }

  Widget _buildHeader(TestSection section) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Section indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getSkillColor(section.skill),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  _getSkillIcon(section.skill),
                  color: Colors.white,
                  size: 16.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Section ${_currentSectionIndex + 1}/${widget.test.sections.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          
          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _timeRemaining < 300 ? Colors.red : Colors.blue, // Red if < 5 min
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Colors.white,
                  size: 16.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(TestSection section) {
    if (_isPaused) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle_outline, size: 80.w, color: Colors.grey),
            SizedBox(height: 20.h),
            Text(
              'Test Paused',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Click play button to continue',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            '${section.skill.emoji} ${_getSkillName(section.skill)} Section',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${section.questionIds.length} questions • ${section.timeLimit} minutes',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20.h),
          
          // Section instructions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  _getInstructions(section.skill),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
          // Questions placeholder
          _buildQuestionsPlaceholder(section),
        ],
      ),
    );
  }

  Widget _buildQuestionsPlaceholder(TestSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(
          section.questionIds.length > 5 ? 5 : section.questionIds.length,
          (index) {
            final questionContent = _getSampleQuestion(section.skill, index + 1);
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: _getSkillColor(section.skill).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: _getSkillColor(section.skill),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Question ${index + 1}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    questionContent,
                    style: TextStyle(fontSize: 14.sp, height: 1.5),
                  ),
                  SizedBox(height: 12.h),
                  ...List.generate(4, (optIndex) {
                    final options = ['A', 'B', 'C', 'D'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                options[optIndex],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _getSampleOption(section.skill, index + 1, optIndex),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
        if (section.questionIds.length > 5)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.more_horiz, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  '+ ${section.questionIds.length - 5} more questions',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentSectionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousSection,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          if (_currentSectionIndex > 0) SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _nextSection, // ✅ Always navigate to section page first
              icon: Icon(
                _currentSectionIndex < widget.test.sections.length - 1
                    ? Icons.arrow_forward
                    : Icons.mic, // Speaking icon for last section
              ),
              label: Text(
                _currentSectionIndex < widget.test.sections.length - 1
                    ? 'Next Section'
                    : 'Start Speaking Test', // ✅ Clear text
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: _currentSectionIndex < widget.test.sections.length - 1
                    ? Colors.purple
                    : Colors.red, // Red for speaking
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

  Color _getSkillColor(SkillType skill) {
    switch (skill) {
      case SkillType.listening:
        return Colors.orange;
      case SkillType.reading:
        return Colors.blue;
      case SkillType.writing:
        return Colors.green;
      case SkillType.speaking:
        return Colors.red;
    }
  }

  IconData _getSkillIcon(SkillType skill) {
    switch (skill) {
      case SkillType.listening:
        return Icons.headphones;
      case SkillType.reading:
        return Icons.book;
      case SkillType.writing:
        return Icons.edit;
      case SkillType.speaking:
        return Icons.mic;
    }
  }

  String _getSkillName(SkillType skill) {
    switch (skill) {
      case SkillType.listening:
        return 'Listening';
      case SkillType.reading:
        return 'Reading';
      case SkillType.writing:
        return 'Writing';
      case SkillType.speaking:
        return 'Speaking';
    }
  }

  String _getInstructions(SkillType skill) {
    switch (skill) {
      case SkillType.listening:
        return 'Listen to the audio and answer the questions. You will hear each recording only once.';
      case SkillType.reading:
        return 'Read the passages carefully and answer all questions. You can return to previous questions.';
      case SkillType.writing:
        return 'Complete both writing tasks. Make sure to manage your time effectively.';
      case SkillType.speaking:
        return 'Record your responses to each question. Speak clearly and answer all parts.';
    }
  }

  String _getSampleQuestion(SkillType skill, int questionNumber) {
    switch (skill) {
      case SkillType.listening:
        return 'According to the speaker, what is the main reason for the delay in the project timeline?';
      case SkillType.reading:
        return 'Which of the following statements is NOT mentioned in paragraph 3 about climate change effects?';
      case SkillType.writing:
        if (questionNumber == 1) {
          return 'Task 1: The chart below shows the number of international students in four different countries from 2010 to 2020. Summarize the information by selecting and reporting the main features.';
        }
        return 'Task 2: Some people believe that technology has made our lives more complex. Others think it has simplified things. Discuss both views and give your own opinion. Write at least 250 words.';
      case SkillType.speaking:
        if (questionNumber == 1) {
          return 'Part 1: Let\'s talk about your hometown. Where are you from? What do you like most about living there?';
        } else if (questionNumber == 2) {
          return 'Part 2: Describe a memorable journey you have taken. You should say: Where you went, Who you went with, What you did there, and explain why it was memorable.';
        }
        return 'Part 3: How has tourism changed in your country over the past few decades? What are the advantages and disadvantages of mass tourism?';
    }
  }

  String _getSampleOption(SkillType skill, int questionNumber, int optionIndex) {
    switch (skill) {
      case SkillType.listening:
        const options = [
          'Unexpected weather conditions affected the construction',
          'The supplier failed to deliver materials on time',
          'Additional safety requirements were implemented',
          'The project scope was expanded by the client',
        ];
        return options[optionIndex];
      case SkillType.reading:
        const options = [
          'Rising sea levels threatening coastal communities',
          'Increased frequency of extreme weather events',
          'Changes in agricultural productivity patterns',
          'Reduction in global biodiversity rates',
        ];
        return options[optionIndex];
      case SkillType.writing:
        return ''; // Writing doesn't have options
      case SkillType.speaking:
        return ''; // Speaking doesn't have options
    }
  }
}
