import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/exam_type.dart';

class ListeningPracticePage extends StatelessWidget {
  final ExamType examType;
  final String? audioId;
  final DifficultyLevel? difficulty;

  const ListeningPracticePage({
    super.key,
    required this.examType,
    this.audioId,
    this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${examType.name.toUpperCase()} Listening Practice'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.headphones_outlined,
                size: 100.w,
                color: Colors.orange,
              ),
              SizedBox(height: 20.h),
              Text(
                '🎧 Listening Practice',
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
