import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes/route_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/test_entity.dart';
import '../cubits/exam_cubit.dart';
import '../cubits/exam_state.dart';


/// Trang danh sách đề thi thử TOEIC Full Test
class ToeicFullTestSelectionPage extends StatefulWidget {
  const ToeicFullTestSelectionPage({super.key});

  @override
  State<ToeicFullTestSelectionPage> createState() => _ToeicFullTestSelectionPageState();
}

class _ToeicFullTestSelectionPageState extends State<ToeicFullTestSelectionPage> {
  // Hardcode ExamType là TOEIC
  final ExamType _examType = ExamType.toeic;

  @override
  void initState() {
    super.initState();
    // Load danh sách đề thi TOEIC từ Server/Local
    context.read<ExamCubit>().loadTests(_examType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề thi thử TOEIC'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
            // Nếu API trả về list rỗng thì hiển thị sample
            final tests = state.tests.isNotEmpty ? state.tests : _generateSampleToeicTests();
            return _buildTestList(tests);
          }

          // Mặc định hiển thị dữ liệu mẫu nếu chưa có API
          return _buildTestList(_generateSampleToeicTests());
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
              'Không thể tải danh sách đề thi',
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
              onPressed: () => context.read<ExamCubit>().loadTests(_examType),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
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
              'Chưa có đề thi nào',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: tests.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final test = tests[index];
        return _ToeicTestCard(
          test: test,
          onTap: () => _startTest(test),
        );
      },
    );
  }

  void _startTest(TestEntity test) {
    // Điều hướng đến trang làm bài thi TOEIC (ToeicFullTestExecutionPage)
    // Bạn cần đảm bảo đã cấu hình GoRouter cho đường dẫn này
    context.push(
    AppRoutes.toeicTestExecution, // Route path dẫn đến ToeicFullTestExecutionPage
      extra: {
        'examType': _examType,
        'test': test,
      },
    );
  }

  // === SAMPLE DATA GENERATOR CHO TOEIC ===
  List<TestEntity> _generateSampleToeicTests() {
    return List.generate(5, (index) {
      final testNumber = index + 1;
      return TestEntity(
        id: 'toeic_sim_test_$testNumber',
        examType: ExamType.toeic,
        title: 'TOEIC Simulation Test $testNumber', // ETS 2024 Test...
        description: 'Đề thi mô phỏng hoàn chỉnh gồm Listening và Reading. Cấu trúc chuẩn format mới.',
        sections: _generateToeicSections(),
        totalQuestions: 200, // Chuẩn TOEIC
        totalTimeLimit: 120, // 45p Listening + 75p Reading
        difficulty: DifficultyLevel.values[(index % 3)], // Random độ khó
        isPremium: index >= 2, // 2 đề đầu free
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
        updatedAt: DateTime.now(),
      );
    });
  }

  List<TestSection> _generateToeicSections() {
    return [
      TestSection(
        id: 'sec_listening',
        title: 'Listening Comprehension',
        skill: SkillType.listening,
        questionIds: List.generate(100, (i) => 'q_L_$i'),
        timeLimit: 45, // 45 phút
        orderIndex: 0,
      ),
      TestSection(
        id: 'sec_reading',
        title: 'Reading Comprehension',
        skill: SkillType.reading,
        questionIds: List.generate(100, (i) => 'q_R_$i'),
        timeLimit: 75, // 75 phút
        orderIndex: 1,
      ),
    ];
  }
}

/// Widget Card hiển thị thông tin đề thi TOEIC
class _ToeicTestCard extends StatelessWidget {
  final TestEntity test;
  final VoidCallback onTap;

  const _ToeicTestCard({
    required this.test,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.blue.withOpacity(0.2),
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
              // Header: Icon + Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'ETS', // Icon giả lập logo ETS
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
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
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            _buildTag(
                              _getDifficultyLabel(test.difficulty),
                              _getDifficultyColor(test.difficulty),
                            ),
                            if (test.isPremium) ...[
                              SizedBox(width: 8.w),
                              _buildTag('PRO', Colors.orange),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18.w,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(height: 1, color: Colors.grey[200]),
              ),

              // Info Row: Questions | Time | Sections
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(Icons.format_list_numbered, '${test.totalQuestions} câu'),
                  _buildInfoItem(Icons.timer_outlined, '${test.totalTimeLimit} phút'),
                  _buildInfoItem(Icons.headphones, 'L & R'), // Listening & Reading
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner: return 'Dễ';
      case DifficultyLevel.intermediate: return 'Trung bình';
      case DifficultyLevel.advanced: return 'Khó';
      case DifficultyLevel.expert: return 'Rất khó';
    }
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner: return Colors.green;
      case DifficultyLevel.intermediate: return Colors.blue;
      case DifficultyLevel.advanced: return Colors.orange;
      case DifficultyLevel.expert: return Colors.red;
    }
  }
}