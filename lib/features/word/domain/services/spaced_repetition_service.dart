import '../entities/word_progress_entity.dart';
import '../entities/word_status.dart';

class SpacedRepetitionService {
  /// Calculate next review date based on consecutive correct answers
  /// Uses modified SuperMemo SM-2 algorithm
  static DateTime calculateNextReview({
    required int consecutiveCorrect,
    DateTime? lastReviewed,
  }) {
    final now = lastReviewed ?? DateTime.now();
    
    switch (consecutiveCorrect) {
      case 0:
        // First attempt or recent mistake - review in 10 minutes
        return now.add(const Duration(minutes: 10));
      case 1:
        // Second correct - review in 1 hour
        return now.add(const Duration(hours: 1));
      case 2:
        // Third correct - review tomorrow
        return now.add(const Duration(days: 1));
      case 3:
        // Fourth correct - review in 3 days
        return now.add(const Duration(days: 3));
      case 4:
        // Fifth correct - review in 1 week
        return now.add(const Duration(days: 7));
      case 5:
        // Sixth correct - review in 2 weeks
        return now.add(const Duration(days: 14));
      case 6:
        // Seventh correct - review in 1 month
        return now.add(const Duration(days: 30));
      default:
        // Mastered - review in 2 months
        return now.add(const Duration(days: 60));
    }
  }

  /// Determine word status based on performance
  static WordStatus determineStatus(WordProgressEntity progress) {
    // Check if difficult (low accuracy with enough attempts)
    if (progress.isDifficult) {
      return WordStatus.difficult;
    }

    // Check consecutive correct count
    if (progress.consecutiveCorrect >= 5) {
      return WordStatus.mastered;
    } else if (progress.consecutiveCorrect >= 3) {
      return WordStatus.reviewing;
    } else if (progress.correctCount > 0) {
      return WordStatus.learning;
    }

    return WordStatus.newWord;
  }

  /// Update progress after answer
  static WordProgressEntity updateProgress({
    required WordProgressEntity current,
    required bool isCorrect,
  }) {
    final now = DateTime.now();
    
    final newCorrectCount = isCorrect ? current.correctCount + 1 : current.correctCount;
    final newIncorrectCount = isCorrect ? current.incorrectCount : current.incorrectCount + 1;
    final newConsecutiveCorrect = isCorrect ? current.consecutiveCorrect + 1 : 0;

    // Calculate next review date
    final nextReview = calculateNextReview(
      consecutiveCorrect: newConsecutiveCorrect,
      lastReviewed: now,
    );

    // Create updated progress
    final updated = current.copyWith(
      correctCount: newCorrectCount,
      incorrectCount: newIncorrectCount,
      consecutiveCorrect: newConsecutiveCorrect,
      lastReviewed: now,
      nextReview: nextReview,
      updatedAt: now,
    );

    // Determine new status
    final newStatus = determineStatus(updated);

    return updated.copyWith(status: newStatus);
  }

  /// Get words due for review today
  static List<WordProgressEntity> getDueWords(List<WordProgressEntity> allWords) {
    return allWords.where((word) => word.isDue).toList();
  }

  /// Get new words (not yet studied)
  static List<WordProgressEntity> getNewWords(List<WordProgressEntity> allWords) {
    return allWords.where((word) => word.status == WordStatus.newWord).toList();
  }

  /// Get difficult words (need extra practice)
  static List<WordProgressEntity> getDifficultWords(List<WordProgressEntity> allWords) {
    return allWords.where((word) => word.status == WordStatus.difficult).toList();
  }

  /// Get mastered words
  static List<WordProgressEntity> getMasteredWords(List<WordProgressEntity> allWords) {
    return allWords.where((word) => word.status == WordStatus.mastered).toList();
  }

  /// Calculate daily study goal (20 words/day recommended)
  static Map<String, int> calculateDailyGoal(List<WordProgressEntity> allWords) {
    final dueCount = getDueWords(allWords).length;
    final newCount = getNewWords(allWords).length;
    
    return {
      'due': dueCount,
      'new': newCount.clamp(0, 10), // Max 10 new words per day
      'total': (dueCount + newCount.clamp(0, 10)).clamp(0, 20),
    };
  }
}
