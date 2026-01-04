import 'dart:math';
import 'package:collection/collection.dart';
import '../../../word/domain/entities/word_entity.dart';
import 'quiz_type.dart';

extension _ListExtension<T> on List<T> {
  T? get randomOrNull => isEmpty ? null : this[Random().nextInt(length)];
}

class QuizEntity {
  final QuizType type;
  final String word;
  final String question;
  final List<String> answers;
  String selectedAnswer;
  
  QuizEntity({
    required this.type,
    required this.word,
    required this.question,
    required this.answers,
    this.selectedAnswer = '',
  });

  bool get isCorrect => selectedAnswer == word;

  /// Original quiz: Meaning → Word
  factory QuizEntity.meaningToWord({
    required WordEntity wordEntity,
    required List<String> allWords,
  }) {
    final meaningEntity = wordEntity.meanings.randomOrNull ?? wordEntity.meanings.first;
    final wrongAnswers = List<String>.from(allWords)
      ..remove(wordEntity.word)
      ..shuffle()
      ..take(3);
    
    final answers = List<String>.from(wrongAnswers)
      ..insert(Random().nextInt(4), wordEntity.word);

    return QuizEntity(
      type: QuizType.meaningToWord,
      word: wordEntity.word,
      question: "(${meaningEntity.type.toLowerCase()}) ${meaningEntity.meaning}",
      answers: answers,
    );
  }

  /// Reverse quiz: Word → Meaning
  factory QuizEntity.wordToMeaning({
    required WordEntity wordEntity,
    required List<WordEntity> allWordEntities,
  }) {
    final correctMeaning = wordEntity.meanings.randomOrNull ?? wordEntity.meanings.first;
    
    // Get 3 wrong meanings from other words
    final wrongMeanings = allWordEntities
        .where((w) => w.word != wordEntity.word)
        .map((w) => w.meanings.randomOrNull ?? w.meanings.first)
        .where((m) => m.meaning != correctMeaning.meaning)
        .take(3)
        .map((m) => "(${m.type.toLowerCase()}) ${m.meaning}")
        .toList();

    final correctAnswer = "(${correctMeaning.type.toLowerCase()}) ${correctMeaning.meaning}";
    final answers = List<String>.from(wrongMeanings)
      ..insert(Random().nextInt(min(4, wrongMeanings.length + 1)), correctAnswer);

    return QuizEntity(
      type: QuizType.wordToMeaning,
      word: correctAnswer, // The correct answer is the meaning
      question: wordEntity.word.toUpperCase(),
      answers: answers,
    );
  }

  /// Listening quiz: Audio → Word
  factory QuizEntity.listening({
    required WordEntity wordEntity,
    required List<String> allWords,
  }) {
    final wrongAnswers = List<String>.from(allWords)
      ..remove(wordEntity.word)
      ..shuffle()
      ..take(3);
    
    final answers = List<String>.from(wrongAnswers)
      ..insert(Random().nextInt(4), wordEntity.word);

    return QuizEntity(
      type: QuizType.listening,
      word: wordEntity.word,
      question: "🎧 Listen and choose the correct word",
      answers: answers,
    );
  }

  /// Fill in the blank: Sentence with missing word
  factory QuizEntity.fillInTheBlank({
    required WordEntity wordEntity,
    required List<String> allWords,
  }) {
    final exampleEntity = wordEntity.meanings
        .expand((m) => m.examples)
        .firstWhereOrNull((e) => e.toLowerCase().contains(wordEntity.word.toLowerCase()));
    
    String question;
    if (exampleEntity != null) {
      // Replace word with blank in example sentence
      question = exampleEntity.replaceAll(
        RegExp(wordEntity.word, caseSensitive: false),
        '______',
      );
    } else {
      // Fallback: Create generic sentence
      final meaning = wordEntity.meanings.randomOrNull ?? wordEntity.meanings.first;
      question = "Complete: The ______ is ${meaning.meaning}";
    }

    final wrongAnswers = List<String>.from(allWords)
      ..remove(wordEntity.word)
      ..shuffle()
      ..take(3);
    
    final answers = List<String>.from(wrongAnswers)
      ..insert(Random().nextInt(4), wordEntity.word);

    return QuizEntity(
      type: QuizType.fillInTheBlank,
      word: wordEntity.word,
      question: question,
      answers: answers,
    );
  }

  /// Generate quiz list based on type
  static List<QuizEntity> generateQuizzes({
    required QuizType type,
    required List<WordEntity> words,
  }) {
    final allWords = words.map((e) => e.word).toList();

    return words.map((wordEntity) {
      switch (type) {
        case QuizType.meaningToWord:
          return QuizEntity.meaningToWord(
            wordEntity: wordEntity,
            allWords: allWords,
          );
        case QuizType.wordToMeaning:
          return QuizEntity.wordToMeaning(
            wordEntity: wordEntity,
            allWordEntities: words,
          );
        case QuizType.listening:
          return QuizEntity.listening(
            wordEntity: wordEntity,
            allWords: allWords,
          );
        case QuizType.fillInTheBlank:
          return QuizEntity.fillInTheBlank(
            wordEntity: wordEntity,
            allWords: allWords,
          );
        default:
          // Fallback to meaning to word
          return QuizEntity.meaningToWord(
            wordEntity: wordEntity,
            allWords: allWords,
          );
      }
    }).toList();
  }
}
