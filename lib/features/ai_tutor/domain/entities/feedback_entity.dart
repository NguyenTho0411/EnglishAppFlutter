import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // For context like question, passage, etc.

  const ChatMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, role, content, timestamp, metadata];
}

class WritingFeedbackEntity extends Equatable {
  final String id;
  final String essayText;
  final double overallScore; // Band score 0-9
  final Map<String, double> criteriaScores; // Task Achievement, Coherence, Lexical, Grammar
  final String overallFeedback;
  final List<WritingError> errors;
  final List<String> strengths;
  final List<String> improvements;
  final DateTime createdAt;

  const WritingFeedbackEntity({
    required this.id,
    required this.essayText,
    required this.overallScore,
    required this.criteriaScores,
    required this.overallFeedback,
    required this.errors,
    required this.strengths,
    required this.improvements,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        essayText,
        overallScore,
        criteriaScores,
        overallFeedback,
        errors,
        strengths,
        improvements,
        createdAt,
      ];
}

class WritingError extends Equatable {
  final String type; // grammar, spelling, vocabulary, coherence
  final String text; // The incorrect text
  final String correction; // Suggested correction
  final String explanation;
  final int startIndex;
  final int endIndex;

  const WritingError({
    required this.type,
    required this.text,
    required this.correction,
    required this.explanation,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  List<Object?> get props => [type, text, correction, explanation, startIndex, endIndex];
}

class SpeakingFeedbackEntity extends Equatable {
  final String id;
  final String audioUrl;
  final String transcript;
  final double overallScore; // Band score 0-9
  final Map<String, double> criteriaScores; // Fluency, Lexical, Grammar, Pronunciation
  final String overallFeedback;
  final List<String> strengths;
  final List<String> improvements;
  final int duration; // in seconds
  final int wordCount;
  final double wordsPerMinute;
  final DateTime createdAt;

  const SpeakingFeedbackEntity({
    required this.id,
    required this.audioUrl,
    required this.transcript,
    required this.overallScore,
    required this.criteriaScores,
    required this.overallFeedback,
    required this.strengths,
    required this.improvements,
    required this.duration,
    required this.wordCount,
    required this.wordsPerMinute,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        audioUrl,
        transcript,
        overallScore,
        criteriaScores,
        overallFeedback,
        strengths,
        improvements,
        duration,
        wordCount,
        wordsPerMinute,
        createdAt,
      ];
}
