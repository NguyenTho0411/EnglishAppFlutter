import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/test_entity.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';

/// Mock Test Selection Page - Browse and start tests
class MockTestPage extends StatefulWidget {
  final ExamType examType;
  final String? testId;

  const MockTestPage({
    super.key,
    required this.examType,
    this.testId,
  });

  @override
  State<MockTestPage> createState() => _MockTestPageState();
}

class _MockTestPageState extends State<MockTestPage> {
  @override
  void initState() {
    super.initState();
    // Load available tests
    context.read<ExamCubit>().loadTests(widget.examType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType.name.toUpperCase()} Mock Tests'),
        elevation: 0,
      ),
      body: BlocBuilder<ExamCubit, ExamState>(
        builder: (context, state) {
          if (state is ExamLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamErrorState) {
            return _buildErrorView(state.message);
          }

          if (state is TestListLoadedState) {
            return _buildTestList(state.tests);
          }

          // Default: Show sample tests
          return _buildSampleTests();
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.w, color: Colors.red),
            SizedBox(height: 20.h),
            Text(
              'Error loading tests',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: () => context.read<ExamCubit>().loadTests(widget.examType),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTests() {
    final sampleTests = _generateSampleTests();
    return _buildTestList(sampleTests);
  }

  Widget _buildTestList(List<TestEntity> tests) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80.w, color: Colors.grey),
            SizedBox(height: 20.h),
            Text(
              'No tests available',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _TestCard(
          test: test,
          examType: widget.examType,
          onTap: () => _startTest(test),
        );
      },
    );
  }

  void _startTest(TestEntity test) {
    // Navigate to test execution page
    context.push(
      '/mockTestExecution',
      extra: {
        'examType': widget.examType,
        'test': test,
      },
    );
  }

  List<TestEntity> _generateSampleTests() {
    return List.generate(5, (index) {
      final testNumber = index + 1;
      return TestEntity(
        id: 'test_${widget.examType.name.toLowerCase()}_$testNumber',
        examType: widget.examType,
        title: '${widget.examType.name.toUpperCase()} Practice Test $testNumber',
        description: 'Full-length practice test with all 4 sections. Simulates real exam conditions.',
        sections: _generateSections(),
        totalQuestions: widget.examType == ExamType.ielts ? 40 : 200,
        totalTimeLimit: widget.examType == ExamType.ielts ? 170 : 120, // minutes
        difficulty: DifficultyLevel.values[(index % 4)],
        isPremium: index >= 2,
        createdAt: DateTime.now().subtract(Duration(days: index * 7)),
        updatedAt: DateTime.now().subtract(Duration(days: index * 7)),
      );
    });
  }

  List<TestSection> _generateSections() {
    if (widget.examType == ExamType.ielts) {
      return [
        TestSection(
          id: 'section_listening',
          title: 'Listening',
          skill: SkillType.listening,
          questionIds: List.generate(10, (i) => 'q_listening_$i'),
          timeLimit: 30,
          orderIndex: 0,
        ),
        TestSection(
          id: 'section_reading',
          title: 'Reading',
          skill: SkillType.reading,
          questionIds: List.generate(10, (i) => 'q_reading_$i'),
          timeLimit: 60,
          orderIndex: 1,
        ),
        TestSection(
          id: 'section_writing',
          title: 'Writing',
          skill: SkillType.writing,
          questionIds: List.generate(2, (i) => 'q_writing_$i'),
          timeLimit: 60,
          orderIndex: 2,
        ),
        TestSection(
          id: 'section_speaking',
          title: 'Speaking',
          skill: SkillType.speaking,
          questionIds: List.generate(3, (i) => 'q_speaking_$i'),
          timeLimit: 15,
          orderIndex: 3,
        ),
      ];
    } else {
      // TOEIC
      return [
        TestSection(
          id: 'section_listening',
          title: 'Listening Comprehension',
          skill: SkillType.listening,
          questionIds: List.generate(100, (i) => 'q_listening_$i'),
          timeLimit: 45,
          orderIndex: 0,
        ),
        TestSection(
          id: 'section_reading',
          title: 'Reading Comprehension',
          skill: SkillType.reading,
          questionIds: List.generate(100, (i) => 'q_reading_$i'),
          timeLimit: 75,
          orderIndex: 1,
        ),
      ];
    }
  }
}

class _TestCard extends StatelessWidget {
  final TestEntity test;
  final ExamType examType;
  final VoidCallback onTap;

  const _TestCard({
    required this.test,
    required this.examType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.assessment,
                      color: Colors.purple,
                      size: 28.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            _buildChip(
                              _getDifficultyLabel(test.difficulty),
                              _getDifficultyColor(test.difficulty),
                            ),
                            if (test.isPremium) ...[
                              SizedBox(width: 8.w),
                              _buildChip('Premium', Colors.orange),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.w,
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                test.description ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.question_answer_outlined,
                    '${test.totalQuestions} questions',
                  ),
                  SizedBox(width: 12.w),
                  _buildInfoChip(
                    Icons.timer_outlined,
                    '${test.totalTimeLimit} min',
                  ),
                  SizedBox(width: 12.w),
                  _buildInfoChip(
                    Icons.layers_outlined,
                    '${test.sections.length} sections',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }
}
