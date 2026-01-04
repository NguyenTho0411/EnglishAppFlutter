import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/test_entity.dart';
import 'detailed_results_page.dart';

/// Mock Test Results Page - Detailed results analysis
class MockTestResultsPage extends StatelessWidget {
  final ExamType examType;
  final TestEntity test;
  final String attemptId;
  final Map<String, dynamic> results;

  const MockTestResultsPage({
    super.key,
    required this.examType,
    required this.test,
    required this.attemptId,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    // Use actual results instead of sample data
    final actualResults = results.isNotEmpty ? results : _generateSampleResults();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/examHome'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share results
              _shareResults(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall score card
            _buildOverallScore(actualResults),
            
            // Section breakdown
            _buildSectionBreakdown(actualResults),
            
            // Performance analysis
            _buildPerformanceAnalysis(results),
            
            // Recommendations
            _buildRecommendations(),
            
            // Action buttons
            _buildActionButtons(context, actualResults),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScore(Map<String, dynamic> results) {
    final bandScore = (results['overallBand'] ?? 0.0) as double;
    final percentage = bandScore / 9.0 * 100; // Convert band to percentage
    
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 60.w,
            color: Colors.amber,
          ),
          SizedBox(height: 16.h),
          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You completed the test',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Band score
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  examType == ExamType.ielts ? 'Overall Band Score' : 'Total Score',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  examType == ExamType.ielts ? bandScore.toStringAsFixed(1) : percentage.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                if (examType == ExamType.toeic)
                  Text(
                    '/ 990',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Accuracy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Correct', '${results['correct']}', Colors.white),
              _buildStatItem('Wrong', '${results['wrong']}', Colors.white),
              _buildStatItem('Accuracy', '${percentage.toStringAsFixed(0)}%', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBreakdown(Map<String, dynamic> results) {
    // Build sections from actual results instead of expecting 'sections' key
    final sections = [
      {
        'skill': SkillType.listening,
        'score': results['listeningBand'] ?? 0.0,
        'percentage': ((results['listeningCorrect'] ?? 0) / (results['listeningTotal'] ?? 40) * 100),
      },
      {
        'skill': SkillType.reading,
        'score': results['readingBand'] ?? 0.0,
        'percentage': ((results['readingCorrect'] ?? 0) / (results['readingTotal'] ?? 40) * 100),
      },
      {
        'skill': SkillType.writing,
        'score': results['writingBand'] ?? 0.0,
        'percentage': ((results['writingTask1Score'] ?? 0.0) + (results['writingTask2Score'] ?? 0.0)) / 2 * 10,
      },
      {
        'skill': SkillType.speaking,
        'score': results['speakingBand'] ?? 0.0,
        'percentage': ((results['speakingPart1Score'] ?? 0.0) + (results['speakingPart2Score'] ?? 0.0) + (results['speakingPart3Score'] ?? 0.0)) / 3 * 10,
      },
    ];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ...sections.map((section) => _buildSectionCard(section)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    final skill = section['skill'] as SkillType;
    final score = (section['score'] ?? 0.0) as double;
    final percentage = (section['percentage'] ?? 0.0) as double;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getSkillColor(skill).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getSkillColor(skill).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _getSkillColor(skill),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _getSkillIcon(skill),
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.emoji + ' ' + _getSkillName(skill),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_getSkillColor(skill)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            examType == ExamType.ielts ? score.toStringAsFixed(1) : score.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: _getSkillColor(skill),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalysis(Map<String, dynamic> results) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analysis',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          _buildAnalysisItem(
            Icons.trending_up,
            'Strongest Area',
            'Reading comprehension',
            Colors.green,
          ),
          _buildAnalysisItem(
            Icons.trending_down,
            'Needs Improvement',
            'Listening skills',
            Colors.orange,
          ),
          _buildAnalysisItem(
            Icons.timer,
            'Time Management',
            'Good - completed on time',
            Colors.blue,
          ),
          _buildAnalysisItem(
            Icons.check_circle,
            'Consistency',
            'Stable performance across sections',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(IconData icon, String title, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 24.w),
              SizedBox(width: 8.w),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRecommendationItem('Practice more listening exercises with different accents'),
          _buildRecommendationItem('Focus on time management for reading sections'),
          _buildRecommendationItem('Review grammar rules for writing tasks'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.blue[700], size: 16.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> actualResults) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/mockTest', extra: {'examType': examType});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Take Another Test'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                backgroundColor: Colors.purple,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to detailed results page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedResultsPage(testResults: actualResults),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Xem chi tiết bài làm'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  Map<String, dynamic> _generateSampleResults() {
    final isIELTS = examType == ExamType.ielts;
    
    return {
      'overallBand': isIELTS ? 7.5 : 0.0,
      'percentage': isIELTS ? 0.0 : 850.0,
      'correct': isIELTS ? 35 : 165,
      'wrong': isIELTS ? 5 : 35,
      'sections': [
        {
          'skill': SkillType.listening,
          'score': isIELTS ? 7.5 : 420.0,
          'percentage': 85.0,
        },
        {
          'skill': SkillType.reading,
          'score': isIELTS ? 8.0 : 430.0,
          'percentage': 90.0,
        },
        if (isIELTS) ...[
          {
            'skill': SkillType.writing,
            'score': 7.0,
            'percentage': 75.0,
          },
          {
            'skill': SkillType.speaking,
            'score': 7.5,
            'percentage': 85.0,
          },
        ],
      ],
    };
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
}
