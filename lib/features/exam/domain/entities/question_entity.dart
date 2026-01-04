import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class QuestionEntity extends Equatable {
  final String id;
  final ExamType examType;
  final SkillType skill;
  final QuestionType questionType;
  final DifficultyLevel difficulty;
  final String section; // e.g., "Section 1", "Reading Passage 1"
  final int part; // Part number within section
  final int orderIndex; // Order within passage/section
  final String questionText;
  final List<String>? options; // For multiple choice
  final String? correctAnswer; // Single answer
  final List<String>? correctAnswers; // Multiple answers for matching
  final String? explanation; // AI-generated or manual explanation
  final String? passageId; // Link to reading passage
  final String? audioId; // Link to listening audio
  final Map<String, dynamic>? metadata; // Extra data (time limits, word count, etc.)
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionEntity({
    required this.id,
    required this.examType,
    required this.skill,
    required this.questionType,
    required this.difficulty,
    required this.section,
    required this.part,
    required this.orderIndex,
    required this.questionText,
    this.options,
    this.correctAnswer,
    this.correctAnswers,
    this.explanation,
    this.passageId,
    this.audioId,
    this.metadata,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isCorrectAnswer(String userAnswer) {
    if (correctAnswer != null) {
      return userAnswer.toLowerCase().trim() == correctAnswer!.toLowerCase().trim();
    }
    if (correctAnswers != null) {
      return correctAnswers!
          .map((a) => a.toLowerCase().trim())
          .contains(userAnswer.toLowerCase().trim());
    }
    return false;
  }

  @override
  List<Object?> get props => [
        id,
        examType,
        skill,
        questionType,
        difficulty,
        section,
        part,
        orderIndex,
        questionText,
        options,
        correctAnswer,
        correctAnswers,
        explanation,
        passageId,
        audioId,
        metadata,
        isPremium,
        createdAt,
        updatedAt,
      ];
}
