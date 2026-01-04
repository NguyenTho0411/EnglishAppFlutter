import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/exam_type.dart';

class SpeakingPracticePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${examType.name.toUpperCase()} Speaking Practice'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic_outlined,
                size: 100.w,
                color: Colors.red,
              ),
              SizedBox(height: 20.h),
              Text(
                '🗣️ Speaking Practice',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Coming soon! This feature is under development.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
