import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class TestAttemptEntity extends Equatable {
  final String id;
  final String userId;
  final String testId;
  final ExamType examType;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, UserAnswer> answers; // questionId -> answer
  final Map<SkillType, SectionScore> sectionScores;
  final double totalScore;
  final double accuracyRate;
  final int timeSpentSeconds;
  final bool isPaused;
  final int pauseCount;
  final DateTime? lastResumedAt;

  const TestAttemptEntity({
    required this.id,
    required this.userId,
    required this.testId,
    required this.examType,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.answers = const {},
    this.sectionScores = const {},
    this.totalScore = 0.0,
    this.accuracyRate = 0.0,
    this.timeSpentSeconds = 0,
    this.isPaused = false,
    this.pauseCount = 0,
    this.lastResumedAt,
  });

  TestAttemptEntity copyWith({
    String? id,
    String? userId,
    String? testId,
    ExamType? examType,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
    Map<String, UserAnswer>? answers,
    Map<SkillType, SectionScore>? sectionScores,
    double? totalScore,
    double? accuracyRate,
    int? timeSpentSeconds,
    bool? isPaused,
    int? pauseCount,
    DateTime? lastResumedAt,
  }) {
    return TestAttemptEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      examType: examType ?? this.examType,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      answers: answers ?? this.answers,
      sectionScores: sectionScores ?? this.sectionScores,
      totalScore: totalScore ?? this.totalScore,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      isPaused: isPaused ?? this.isPaused,
      pauseCount: pauseCount ?? this.pauseCount,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        testId,
        examType,
        startedAt,
        completedAt,
        isCompleted,
        answers,
        sectionScores,
        totalScore,
        accuracyRate,
        timeSpentSeconds,
        isPaused,
        pauseCount,
        lastResumedAt,
      ];
}

class UserAnswer extends Equatable {
  final String questionId;
  final String answer; // User's answer
  final bool isCorrect;
  final int timeSpentSeconds;
  final DateTime answeredAt;

  const UserAnswer({
    required this.questionId,
    required this.answer,
    required this.isCorrect,
    required this.timeSpentSeconds,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        answer,
        isCorrect,
        timeSpentSeconds,
        answeredAt,
      ];
}

class SectionScore extends Equatable {
  final SkillType skill;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final double bandScore; // For IELTS (0-9)
  final int rawScore; // For TOEIC (0-495)
  final int timeSpentSeconds;

  const SectionScore({
    required this.skill,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    this.bandScore = 0.0,
    this.rawScore = 0,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [
        skill,
        totalQuestions,
        correctAnswers,
        accuracy,
        bandScore,
        rawScore,
        timeSpentSeconds,
      ];
}
