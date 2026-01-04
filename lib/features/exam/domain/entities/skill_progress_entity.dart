import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class SkillProgressEntity extends Equatable {
  final String id;
  final String userId;
  final ExamType examType;
  final SkillType skill;
  final double currentBandScore; // IELTS: 0-9, TOEIC: convert to band
  final double estimatedScore; // TOEIC: 0-495 per section
  final int totalAttempts;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double overallAccuracy;
  final int totalTimeSpentSeconds;
  final DateTime lastPracticeDate;
  final Map<DifficultyLevel, int> questionsByDifficulty;
  final Map<QuestionType, double> accuracyByType; // Track weak areas
  final List<String> weakTopics; // Topics with <70% accuracy
  final List<String> strongTopics; // Topics with >85% accuracy
  final DateTime createdAt;
  final DateTime updatedAt;

  const SkillProgressEntity({
    required this.id,
    required this.userId,
    required this.examType,
    required this.skill,
    this.currentBandScore = 0.0,
    this.estimatedScore = 0.0,
    this.totalAttempts = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.overallAccuracy = 0.0,
    this.totalTimeSpentSeconds = 0,
    required this.lastPracticeDate,
    this.questionsByDifficulty = const {},
    this.accuracyByType = const {},
    this.weakTopics = const [],
    this.strongTopics = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  SkillProgressEntity copyWith({
    String? id,
    String? userId,
    ExamType? examType,
    SkillType? skill,
    double? currentBandScore,
    double? estimatedScore,
    int? totalAttempts,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    double? overallAccuracy,
    int? totalTimeSpentSeconds,
    DateTime? lastPracticeDate,
    Map<DifficultyLevel, int>? questionsByDifficulty,
    Map<QuestionType, double>? accuracyByType,
    List<String>? weakTopics,
    List<String>? strongTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      examType: examType ?? this.examType,
      skill: skill ?? this.skill,
      currentBandScore: currentBandScore ?? this.currentBandScore,
      estimatedScore: estimatedScore ?? this.estimatedScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      totalTimeSpentSeconds: totalTimeSpentSeconds ?? this.totalTimeSpentSeconds,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      questionsByDifficulty: questionsByDifficulty ?? this.questionsByDifficulty,
      accuracyByType: accuracyByType ?? this.accuracyByType,
      weakTopics: weakTopics ?? this.weakTopics,
      strongTopics: strongTopics ?? this.strongTopics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        examType,
        skill,
        currentBandScore,
        estimatedScore,
        totalAttempts,
        totalQuestionsAnswered,
        totalCorrectAnswers,
        overallAccuracy,
        totalTimeSpentSeconds,
        lastPracticeDate,
        questionsByDifficulty,
        accuracyByType,
        weakTopics,
        strongTopics,
        createdAt,
        updatedAt,
      ];
}
