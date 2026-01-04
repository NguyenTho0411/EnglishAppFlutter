import 'package:equatable/equatable.dart';

class SpeakingTaskEntity extends Equatable {
  final String id;
  final int partNumber; // 1, 2, or 3
  final String prompt;
  final List<String> subQuestions; // Follow-up questions
  final int preparationTime; // seconds (only for Part 2)
  final int speakingTime; // seconds
  final List<String> assessmentCriteria; // Fluency, Lexical Resource, Grammar, Pronunciation
  final int orderIndex;

  const SpeakingTaskEntity({
    required this.id,
    required this.partNumber,
    required this.prompt,
    required this.subQuestions,
    required this.preparationTime,
    required this.speakingTime,
    required this.assessmentCriteria,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [
        id,
        partNumber,
        prompt,
        subQuestions,
        preparationTime,
        speakingTime,
        assessmentCriteria,
        orderIndex,
      ];
}
