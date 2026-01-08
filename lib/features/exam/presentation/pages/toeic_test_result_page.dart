import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes/route_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ToeicTestResultPage extends StatelessWidget {
  final Map<String, dynamic> testResults;

  const ToeicTestResultPage({
    Key? key,
    required this.testResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Lấy điểm số từ Map kết quả
    // TOEIC Full Test chỉ có Listening và Reading
    final listeningScore = testResults['listeningScore'] as int? ?? 0;
    final readingScore = testResults['readingScore'] as int? ?? 0;
    
    // Tính tổng điểm (Nếu không có key totalScore thì cộng tay)
    final totalScore = testResults['totalScore'] as int? ?? (listeningScore + readingScore);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kết Quả Thi Thử'),
        backgroundColor: Colors.blue[800], // Màu xanh TOEIC
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER: TỔNG ĐIỂM
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[800]!,
                    Colors.blue[600]!,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 80.w,
                    color: Colors.amber[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Chúc mừng bạn!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Bạn đã hoàn thành bài thi thử TOEIC',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  
                  // Card điểm tổng
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 40.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL SCORE',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '$totalScore',
                          style: TextStyle(
                            fontSize: 64.sp,
                            fontWeight: FontWeight.w900,
                            color: _getScoreColor(totalScore),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _getScoreColor(totalScore).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _getProficiencyLevel(totalScore), // Ví dụ: Intermediate (B1)
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: _getScoreColor(totalScore),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // CHI TIẾT ĐIỂM THÀNH PHẦN
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiết điểm số',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Card Listening
                  _buildSectionCard(
                    icon: Icons.headphones,
                    title: 'Listening',
                    score: listeningScore,
                    maxScore: 495,
                    correctAnswers: testResults['listeningCorrect'], // Số câu đúng (nếu có)
                    totalQuestions: 100,
                    color: Colors.pinkAccent,
                  ),

                  SizedBox(height: 16.h),

                  // Card Reading
                  _buildSectionCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Reading',
                    score: readingScore,
                    maxScore: 495,
                    correctAnswers: testResults['readingCorrect'],
                    totalQuestions: 100,
                    color: Colors.blueAccent,
                  ),

                  SizedBox(height: 40.h),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chức năng xem lại đang phát triển')),
                            );
                          },
                          icon: const Icon(Icons.history_edu),
                          label: const Text('Xem lại bài'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            side: BorderSide(color: Colors.blue[800]!, width: 2),
                            foregroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Quay về trang chủ
                            context.go(AppRoutes.home); 
                          },
                          icon: const Icon(Icons.home_filled),
                          label: const Text('Về trang chủ'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị từng phần thi (Listening/Reading)
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required int score,
    required int maxScore,
    int? correctAnswers,
    int? totalQuestions,
    required Color color,
  }) {
    // Tính phần trăm để hiển thị thanh progress
    final double progress = score / maxScore;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon tròn
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          SizedBox(width: 16.w),
          
          // Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '$score / $maxScore',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                
                // Thanh Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[100],
                    color: color,
                    minHeight: 8.h,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Số câu đúng (nếu có dữ liệu)
                if (correctAnswers != null && totalQuestions != null)
                  Text(
                    '$correctAnswers / $totalQuestions câu đúng',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logic màu sắc dựa trên điểm số (TOEIC)
  Color _getScoreColor(int score) {
    if (score >= 860) return Colors.orange[800]!; // Gold (Proficiency)
    if (score >= 730) return Colors.green[700]!;  // Green (Advanced)
    if (score >= 470) return Colors.blue[600]!;   // Blue (Intermediate)
    if (score >= 220) return Colors.brown[400]!;  // Brown (Elementary)
    return Colors.red[400]!;                      // Orange/Red (Novice)
  }

  // Logic xếp loại dựa trên điểm số (CEFR Mapping tham khảo)
  String _getProficiencyLevel(int score) {
    if (score >= 860) return 'Professional (C1+)';
    if (score >= 730) return 'Advanced (B2-C1)';
    if (score >= 470) return 'Intermediate (B1-B2)';
    if (score >= 220) return 'Elementary (A2)';
    return 'Novice (A1)';
  }
}