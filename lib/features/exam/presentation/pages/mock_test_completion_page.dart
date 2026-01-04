import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockTestCompletionPage extends StatelessWidget {
  final Map<String, dynamic> testResults;

  const MockTestCompletionPage({
    Key? key,
    required this.testResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listeningBand = testResults['listeningBand'] ?? 0.0;
    final readingBand = testResults['readingBand'] ?? 0.0;
    final writingBand = testResults['writingBand'] ?? 0.0;
    final speakingBand = testResults['speakingBand'] ?? 0.0;
    final overallBand = testResults['overallBand'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Test Completed'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with overall score
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[500]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 80.w,
                    color: Colors.amber[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You have completed the IELTS Mock Test',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Overall Band Score',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          overallBand.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(_getBandColor(overallBand)),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _getBandDescriptor(overallBand),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Individual section scores
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section Scores',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildSectionCard(
                    icon: Icons.headphones,
                    title: 'Listening',
                    band: listeningBand,
                    correctAnswers: testResults['listeningCorrect'] ?? 0,
                    totalQuestions: testResults['listeningTotal'] ?? 40,
                    color: Colors.purple,
                  ),

                  SizedBox(height: 12.h),

                  _buildSectionCard(
                    icon: Icons.menu_book,
                    title: 'Reading',
                    band: readingBand,
                    correctAnswers: testResults['readingCorrect'] ?? 0,
                    totalQuestions: testResults['readingTotal'] ?? 40,
                    color: Colors.blue,
                  ),

                  SizedBox(height: 12.h),

                  _buildSectionCard(
                    icon: Icons.edit_note,
                    title: 'Writing',
                    band: writingBand,
                    task1Score: testResults['writingTask1Score'] ?? 0.0,
                    task2Score: testResults['writingTask2Score'] ?? 0.0,
                    color: Colors.green,
                  ),

                  SizedBox(height: 12.h),

                  _buildSectionCard(
                    icon: Icons.mic,
                    title: 'Speaking',
                    band: speakingBand,
                    part1Score: testResults['speakingPart1Score'] ?? 0.0,
                    part2Score: testResults['speakingPart2Score'] ?? 0.0,
                    part3Score: testResults['speakingPart3Score'] ?? 0.0,
                    color: Colors.orange,
                  ),

                  SizedBox(height: 32.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View detailed results
                          },
                          icon: Icon(Icons.analytics),
                          label: Text('Detailed Results'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: Icon(Icons.home),
                          label: Text('Go Home'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            backgroundColor: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required double band,
    int? correctAnswers,
    int? totalQuestions,
    double? task1Score,
    double? task2Score,
    double? part1Score,
    double? part2Score,
    double? part3Score,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4.h),
                if (correctAnswers != null && totalQuestions != null)
                  Text(
                    '$correctAnswers / $totalQuestions correct',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                if (task1Score != null && task2Score != null)
                  Text(
                    'Task 1: ${task1Score.toStringAsFixed(1)} • Task 2: ${task2Score.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                if (part1Score != null && part2Score != null && part3Score != null)
                  Text(
                    'P1: ${part1Score.toStringAsFixed(1)} • P2: ${part2Score.toStringAsFixed(1)} • P3: ${part3Score.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(_getBandColor(band)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              band.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getBandColor(double band) {
    if (band >= 8.0) return 0xFF4CAF50; // Green
    if (band >= 7.0) return 0xFF8BC34A; // Light Green
    if (band >= 6.0) return 0xFF2196F3; // Blue
    if (band >= 5.0) return 0xFFFF9800; // Orange
    if (band >= 4.0) return 0xFFFF5722; // Deep Orange
    return 0xFFF44336; // Red
  }

  String _getBandDescriptor(double band) {
    if (band == 9.0) return 'Expert User';
    if (band >= 8.0) return 'Very Good User';
    if (band >= 7.0) return 'Good User';
    if (band >= 6.0) return 'Competent User';
    if (band >= 5.0) return 'Modest User';
    if (band >= 4.0) return 'Limited User';
    if (band >= 3.0) return 'Extremely Limited User';
    if (band >= 2.0) return 'Intermittent User';
    if (band >= 1.0) return 'Non User';
    return 'Did Not Attempt';
  }
}
