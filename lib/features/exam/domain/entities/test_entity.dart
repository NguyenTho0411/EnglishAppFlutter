import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class TestEntity extends Equatable {
  final String id;
  final ExamType examType;
  final String title;
  final String description;
  final List<TestSection> sections;
  final int totalQuestions;
  final int totalTimeLimit; // in minutes
  final DifficultyLevel difficulty;
  final bool isFullTest; // true for complete mock test, false for section practice
  final bool isPremium;
  final int attemptsCount; // Track popularity
  final double averageScore; // Average score from all attempts
  final DateTime createdAt;
  final DateTime updatedAt;

  const TestEntity({
    required this.id,
    required this.examType,
    required this.title,
    required this.description,
    required this.sections,
    required this.totalQuestions,
    required this.totalTimeLimit,
    required this.difficulty,
    this.isFullTest = false,
    this.isPremium = false,
    this.attemptsCount = 0,
    this.averageScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        examType,
        title,
        description,
        sections,
        totalQuestions,
        totalTimeLimit,
        difficulty,
        isFullTest,
        isPremium,
        attemptsCount,
        averageScore,
        createdAt,
        updatedAt,
      ];
}

class TestSection extends Equatable {
  final String id;
  final SkillType skill;
  final String title;
  final String? description;
  final List<String> questionIds; // References to questions
  final int timeLimit; // in minutes, 0 for no limit
  final int orderIndex;

  const TestSection({
    required this.id,
    required this.skill,
    required this.title,
    this.description,
    required this.questionIds,
    required this.timeLimit,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [
        id,
        skill,
        title,
        description,
        questionIds,
        timeLimit,
        orderIndex,
      ];
}
