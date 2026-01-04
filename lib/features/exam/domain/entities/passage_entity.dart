import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class PassageEntity extends Equatable {
  final String id;
  final ExamType examType;
  final String title;
  final String content;
  final int wordCount;
  final DifficultyLevel difficulty;
  final String topic; // e.g., "Science", "History", "Environment"
  final List<String> tags; // For search and filtering
  final int estimatedReadingTime; // in minutes
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PassageEntity({
    required this.id,
    required this.examType,
    required this.title,
    required this.content,
    required this.wordCount,
    required this.difficulty,
    required this.topic,
    this.tags = const [],
    required this.estimatedReadingTime,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        examType,
        title,
        content,
        wordCount,
        difficulty,
        topic,
        tags,
        estimatedReadingTime,
        isPremium,
        createdAt,
        updatedAt,
      ];
}
