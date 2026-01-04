enum QuizType {
  /// Original: Meaning → Word
  meaningToWord,
  
  /// Reverse: Word → Meaning
  wordToMeaning,
  
  /// Listening: Audio → Word
  listening,
  
  /// Fill in the blank: Sentence with missing word
  fillInTheBlank,
  
  /// Synonym/Antonym matching
  synonymAntonym,
  
  /// Sentence building (arrange words)
  sentenceBuilding,
}

extension QuizTypeExtension on QuizType {
  String get name {
    switch (this) {
      case QuizType.meaningToWord:
        return 'Meaning to Word';
      case QuizType.wordToMeaning:
        return 'Word to Meaning';
      case QuizType.listening:
        return 'Listening Quiz';
      case QuizType.fillInTheBlank:
        return 'Fill in the Blank';
      case QuizType.synonymAntonym:
        return 'Synonym/Antonym';
      case QuizType.sentenceBuilding:
        return 'Sentence Building';
    }
  }
  
  String get icon {
    switch (this) {
      case QuizType.meaningToWord:
        return '📖';
      case QuizType.wordToMeaning:
        return '🔄';
      case QuizType.listening:
        return '🎧';
      case QuizType.fillInTheBlank:
        return '✏️';
      case QuizType.synonymAntonym:
        return '🔗';
      case QuizType.sentenceBuilding:
        return '🧩';
    }
  }
}
