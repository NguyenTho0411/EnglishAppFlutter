import 'package:equatable/equatable.dart';
import 'word_status.dart';

class WordProgressEntity extends Equatable {
  final String wordId;
  final String word;
  final WordStatus status;
  final int correctCount;
  final int incorrectCount;
  final int consecutiveCorrect;
  final DateTime? lastReviewed;
  final DateTime? nextReview;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const WordProgressEntity({
    required this.wordId,
    required this.word,
    required this.status,
    required this.correctCount,
    required this.incorrectCount,
    required this.consecutiveCorrect,
    this.lastReviewed,
    this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new word progress for first time learning
  factory WordProgressEntity.newWord({
    required String wordId,
    required String word,
  }) {
    final now = DateTime.now();
    return WordProgressEntity(
      wordId: wordId,
      word: word,
      status: WordStatus.newWord,
      correctCount: 0,
      incorrectCount: 0,
      consecutiveCorrect: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if word is due for review
  bool get isDue {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!);
  }

  /// Get accuracy rate (0-100)
  double get accuracyRate {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0;
    return (correctCount / total * 100);
  }

  /// Check if considered difficult (< 60% accuracy with >= 5 attempts)
  bool get isDifficult {
    final total = correctCount + incorrectCount;
    return total >= 5 && accuracyRate < 60;
  }

  WordProgressEntity copyWith({
    String? wordId,
    String? word,
    WordStatus? status,
    int? correctCount,
    int? incorrectCount,
    int? consecutiveCorrect,
    DateTime? lastReviewed,
    DateTime? nextReview,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordProgressEntity(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      status: status ?? this.status,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        wordId,
        word,
        status,
        correctCount,
        incorrectCount,
        consecutiveCorrect,
        lastReviewed,
        nextReview,
        createdAt,
        updatedAt,
      ];
}
