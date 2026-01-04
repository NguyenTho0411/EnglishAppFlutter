import 'package:equatable/equatable.dart';

class UserAnswerEntity extends Equatable {
  final String questionId;
  final String? selectedAnswer; // For multiple choice (A/B/C/D)
  final String? textAnswer; // For writing
  final String? audioUrl; // For speaking (recorded audio)
  final bool isCorrect; // For auto-graded (Listening/Reading)
  final double? aiScore; // For AI-graded (Writing/Speaking) 0-9
  final String? aiFeedback; // Feedback from OpenAI
  final DateTime answeredAt;

  const UserAnswerEntity({
    required this.questionId,
    this.selectedAnswer,
    this.textAnswer,
    this.audioUrl,
    required this.isCorrect,
    this.aiScore,
    this.aiFeedback,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedAnswer,
        textAnswer,
        audioUrl,
        isCorrect,
        aiScore,
        aiFeedback,
        answeredAt,
      ];
}
