import '../../domain/entities/word_progress_entity.dart';
import '../../domain/entities/word_status.dart';

class WordProgressModel extends WordProgressEntity {
  const WordProgressModel({
    required super.wordId,
    required super.word,
    required super.status,
    required super.correctCount,
    required super.incorrectCount,
    required super.consecutiveCorrect,
    super.lastReviewed,
    super.nextReview,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WordProgressModel.fromEntity(WordProgressEntity entity) {
    return WordProgressModel(
      wordId: entity.wordId,
      word: entity.word,
      status: entity.status,
      correctCount: entity.correctCount,
      incorrectCount: entity.incorrectCount,
      consecutiveCorrect: entity.consecutiveCorrect,
      lastReviewed: entity.lastReviewed,
      nextReview: entity.nextReview,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory WordProgressModel.fromFirestore(Map<String, dynamic> map) {
    return WordProgressModel(
      wordId: map['wordId'] as String,
      word: map['word'] as String,
      status: WordStatusExtension.fromFirestore(map['status'] as String),
      correctCount: map['correctCount'] as int,
      incorrectCount: map['incorrectCount'] as int,
      consecutiveCorrect: map['consecutiveCorrect'] as int,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReviewed'] as int)
          : null,
      nextReview: map['nextReview'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextReview'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'wordId': wordId,
      'word': word,
      'status': status.toFirestore(),
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'consecutiveCorrect': consecutiveCorrect,
      'lastReviewed': lastReviewed?.millisecondsSinceEpoch,
      'nextReview': nextReview?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
