enum WordStatus {
  /// Từ mới, chưa học lần nào
  newWord,
  
  /// Đang học (< 3 lần đúng liên tiếp)
  learning,
  
  /// Đã thuộc, cần ôn tập định kỳ
  reviewing,
  
  /// Từ hay sai, cần chú ý đặc biệt
  difficult,
  
  /// Đã thuộc vững (>= 5 lần đúng liên tiếp)
  mastered,
}

extension WordStatusExtension on WordStatus {
  String get displayName {
    switch (this) {
      case WordStatus.newWord:
        return 'New';
      case WordStatus.learning:
        return 'Learning';
      case WordStatus.reviewing:
        return 'Reviewing';
      case WordStatus.difficult:
        return 'Difficult';
      case WordStatus.mastered:
        return 'Mastered';
    }
  }
  
  String get emoji {
    switch (this) {
      case WordStatus.newWord:
        return '🆕';
      case WordStatus.learning:
        return '📚';
      case WordStatus.reviewing:
        return '🔄';
      case WordStatus.difficult:
        return '⚠️';
      case WordStatus.mastered:
        return '⭐';
    }
  }
  
  String toFirestore() {
    return name;
  }
  
  static WordStatus fromFirestore(String value) {
    return WordStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WordStatus.newWord,
    );
  }
}
