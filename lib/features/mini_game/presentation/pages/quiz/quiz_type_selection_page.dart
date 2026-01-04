import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/route_manager.dart';
import '../../../../../app/themes/app_color.dart';
import '../../../../../app/themes/app_text_theme.dart';
import '../../../../../app/widgets/status_bar.dart';
import '../../../../../core/extensions/build_context.dart';
import '../../../../word/domain/entities/word_entity.dart';
import '../../../domain/entities/quiz_type.dart';

class QuizTypeSelectionPage extends StatelessWidget {
  const QuizTypeSelectionPage({super.key, required this.words});

  final List<WordEntity> words;

  @override
  Widget build(BuildContext context) {
    return StatusBar(
      child: Scaffold(
        backgroundColor: context.colors.blue900,
        appBar: AppBar(
          backgroundColor: context.colors.blue900,
          title: Text(
            'Choose Quiz Type',
            style: context.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.w,
              childAspectRatio: 1.2,
            ),
            itemCount: QuizType.values.length,
            itemBuilder: (context, index) {
              final quizType = QuizType.values[index];
              return _QuizTypeCard(
                quizType: quizType,
                onTap: () {
                  context.push(
                    AppRoutes.quiz,
                    extra: {'words': words, 'type': quizType},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizTypeCard extends StatelessWidget {
  const _QuizTypeCard({required this.quizType, required this.onTap});

  final QuizType quizType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.blue500.withOpacity(0.8),
              context.colors.blue500,
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: context.colors.blue500.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(quizType.icon, style: TextStyle(fontSize: 48.sp)),
              SizedBox(height: 12.h),
              Text(
                quizType.name,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
