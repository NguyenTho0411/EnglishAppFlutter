 import 'package:flutter/material.dart';
enum ExamType {
  ielts('IELTS', 'International English Language Testing System'),
  toeic('TOEIC', 'Test of English for International Communication');

  final String code;
  final String displayName;

  const ExamType(this.code, this.displayName);

  static ExamType fromCode(String code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => ExamType.ielts,
    );
  }
}

enum SkillType {
  listening('Listening', '🎧'),
  reading('Reading', '📖'),
  writing('Writing', '✍️'),
  speaking('Speaking', '🗣️');
  
  final String name;
  final String emoji;

  const SkillType(this.name, this.emoji);
}

enum DifficultyLevel {
  beginner('Beginner', 1),
  intermediate('Intermediate', 2),
  advanced('Advanced', 3),
  expert('Expert', 4);

  final String name;
  final int level;

  const DifficultyLevel(this.name, this.level);
}

enum QuestionType {
  // Reading
  multipleChoice('Multiple Choice'),
  trueFalseNotGiven('True/False/Not Given'),
  yesNoNotGiven('Yes/No/Not Given'),
  matchingHeadings('Matching Headings'),
  matchingInformation('Matching Information'),
  matchingFeatures('Matching Features'),
  sentenceCompletion('Sentence Completion'),
  summaryCompletion('Summary Completion'),
  noteCompletion('Note Completion'),
  tableCompletion('Table Completion'),
  flowChartCompletion('Flow Chart Completion'),
  diagramCompletion('Diagram Completion'),
  shortAnswer('Short Answer Questions'),

  // Listening
  listeningMultipleChoice('Listening Multiple Choice'),
  listeningMatchingHeadings('Listening Matching'),
  listeningFormCompletion('Form Completion'),
  listeningNoteCompletion('Listening Note Completion'),
  listeningTableCompletion('Listening Table Completion'),
  listeningFlowChartCompletion('Listening Flow Chart'),
  listeningSentenceCompletion('Listening Sentence Completion'),
  listeningShortAnswer('Listening Short Answer'),
  mapLabelCompletion('Map/Plan/Diagram Labeling'),

  // Writing
  writingTask1Academic('Academic Writing Task 1'), // Graph, chart, diagram
  writingTask1General('General Writing Task 1'), // Letter
  writingTask2('Writing Task 2'), // Essay

  // Speaking
  speakingPart1('Speaking Part 1'), // Introduction & interview
  speakingPart2('Speaking Part 2'), // Individual long turn
  speakingPart3('Speaking Part 3'), // Two-way discussion

  // TOEIC Listening
  toeicPhotographs('Photographs'), // Part 1
  toeicQuestionResponse('Question - Response'), // Part 2
  toeicConversations('Conversations'), // Part 3
  toeicTalks('Talks'), // Part 4

  // TOEIC Reading
  toeicIncompleteSentences('Incomplete Sentences'), // Part 5
  toeicTextCompletion('Text Completion'), // Part 6
  toeicReadingComprehension('Reading Comprehension'); // Part 7

  final String displayName;

  const QuestionType(this.displayName);


}

// ============================================
// THÊM VÀO CUỐI FILE exam_type.dart
// ============================================

// 1. THÊM METHODS VÀO ExamType (thêm vào trong class ExamType)
extension ExamTypeExtensions on ExamType {
  /// Max score cho mỗi loại thi
  int get maxScore {
    switch (this) {
      case ExamType.ielts:
        return 9; // Band 0-9
      case ExamType.toeic:
        return 990; // Score 10-990
    }
  }

  /// Min score
  int get minScore {
    switch (this) {
      case ExamType.ielts:
        return 0;
      case ExamType.toeic:
        return 10;
    }
  }

  /// Description
  String get description {
    switch (this) {
      case ExamType.ielts:
        return 'International English Language Testing System';
      case ExamType.toeic:
        return 'Test of English for International Communication';
    }
  }
}

// 2. THÊM METHODS VÀO SkillType
extension SkillTypeExtensions on SkillType {
  /// Số câu hỏi cho từng skill theo exam type
  int getQuestionCount(ExamType examType) {
    if (examType == ExamType.ielts) {
      switch (this) {
        case SkillType.listening:
          return 40;
        case SkillType.reading:
          return 40;
        case SkillType.writing:
          return 2; // 2 tasks
        case SkillType.speaking:
          return 3; // 3 parts
      }
    } else if (examType == ExamType.toeic) {
      switch (this) {
        case SkillType.listening:
          return 100;
        case SkillType.reading:
          return 100;
        case SkillType.writing:
          return 0; // TOEIC không có writing trong bài thi chính
        case SkillType.speaking:
          return 0; // TOEIC không có speaking trong bài thi chính
      }
    }
    return 0;
  }

  /// Thời gian làm bài (phút)
  int getDuration(ExamType examType) {
    if (examType == ExamType.ielts) {
      switch (this) {
        case SkillType.listening:
          return 40;
        case SkillType.reading:
          return 60;
        case SkillType.writing:
          return 60;
        case SkillType.speaking:
          return 15;
      }
    } else if (examType == ExamType.toeic) {
      switch (this) {
        case SkillType.listening:
          return 45;
        case SkillType.reading:
          return 75;
        case SkillType.writing:
          return 0;
        case SkillType.speaking:
          return 0;
      }
    }
    return 0;
  }
}

// 3. THÊM METHODS VÀO DifficultyLevel
extension DifficultyLevelExtensions on DifficultyLevel {
  /// Score range cho TOEIC
  String getToeicScoreRange() {
    switch (this) {
      case DifficultyLevel.beginner:
        return '10-400';
      case DifficultyLevel.intermediate:
        return '405-600';
      case DifficultyLevel.advanced:
        return '605-800';
      case DifficultyLevel.expert:
        return '805-990';
    }
  }

  /// Band range cho IELTS
  String getIeltsBandRange() {
    switch (this) {
      case DifficultyLevel.beginner:
        return '1.0-4.0';
      case DifficultyLevel.intermediate:
        return '4.5-6.0';
      case DifficultyLevel.advanced:
        return '6.5-8.0';
      case DifficultyLevel.expert:
        return '8.5-9.0';
    }
  }
}

// 4. THÊM ENUM MỚI: ToeicPart (TOEIC có cấu trúc 7 parts)
enum ToeicPart {
  // Listening
  part1(1, 'Photographs', 'Look at pictures and choose the best description', 6, SkillType.listening),
  part2(2, 'Question-Response', 'Listen to questions and choose the best response', 25, SkillType.listening),
  part3(3, 'Conversations', 'Listen to conversations and answer questions', 39, SkillType.listening),
  part4(4, 'Talks', 'Listen to talks and answer questions', 30, SkillType.listening),
  
  // Reading
  part5(5, 'Incomplete Sentences', 'Complete sentences with correct grammar', 30, SkillType.reading),
  part6(6, 'Text Completion', 'Complete texts with correct words or phrases', 16, SkillType.reading),
  part7(7, 'Reading Comprehension', 'Read passages and answer comprehension questions', 54, SkillType.reading);

  final int partNumber;
  final String title;
  final String description;
  final int questionCount;
  final SkillType skill;

  const ToeicPart(this.partNumber, this.title, this.description, this.questionCount, this.skill);

  /// Get part by number
  static ToeicPart fromNumber(int number) {
    return values.firstWhere(
      (part) => part.partNumber == number,
      orElse: () => ToeicPart.part1,
    );
  }

  /// Get icon for each part
  IconData get icon {
    switch (this) {
      case ToeicPart.part1:
        return Icons.photo_camera;
      case ToeicPart.part2:
        return Icons.question_answer;
      case ToeicPart.part3:
        return Icons.people;
      case ToeicPart.part4:
        return Icons.record_voice_over;
      case ToeicPart.part5:
        return Icons.text_fields;
      case ToeicPart.part6:
        return Icons.article;
      case ToeicPart.part7:
        return Icons.menu_book;
    }
  }

  /// Get color for each part
  Color get color {
    switch (this) {
      case ToeicPart.part1:
        return Colors.orange;
      case ToeicPart.part2:
        return Colors.deepOrange;
      case ToeicPart.part3:
        return Colors.orange.shade700;
      case ToeicPart.part4:
        return Colors.amber;
      case ToeicPart.part5:
        return Colors.blue;
      case ToeicPart.part6:
        return Colors.lightBlue;
      case ToeicPart.part7:
        return Colors.indigo;
    }
  }

  /// Check if this is a listening part
  bool get isListening => skill == SkillType.listening;

  /// Check if this is a reading part
  bool get isReading => skill == SkillType.reading;

  /// Get all listening parts
  static List<ToeicPart> get listeningParts => [part1, part2, part3, part4];

  /// Get all reading parts
  static List<ToeicPart> get readingParts => [part5, part6, part7];
}

// 5. THÊM EXTENSION VÀO QuestionType
extension QuestionTypeExtensions on QuestionType {
  /// Check if this is a TOEIC question type
  bool get isToeicQuestion {
    return this == QuestionType.toeicPhotographs ||
           this == QuestionType.toeicQuestionResponse ||
           this == QuestionType.toeicConversations ||
           this == QuestionType.toeicTalks ||
           this == QuestionType.toeicIncompleteSentences ||
           this == QuestionType.toeicTextCompletion ||
           this == QuestionType.toeicReadingComprehension;
  }

  /// Check if this is an IELTS question type
  bool get isIeltsQuestion => !isToeicQuestion;

  /// Get corresponding TOEIC part
  ToeicPart? get toeicPart {
    switch (this) {
      case QuestionType.toeicPhotographs:
        return ToeicPart.part1;
      case QuestionType.toeicQuestionResponse:
        return ToeicPart.part2;
      case QuestionType.toeicConversations:
        return ToeicPart.part3;
      case QuestionType.toeicTalks:
        return ToeicPart.part4;
      case QuestionType.toeicIncompleteSentences:
        return ToeicPart.part5;
      case QuestionType.toeicTextCompletion:
        return ToeicPart.part6;
      case QuestionType.toeicReadingComprehension:
        return ToeicPart.part7;
      default:
        return null;
    }
  }

  /// Get skill type
  SkillType get skillType {
    if (this == QuestionType.toeicPhotographs ||
        this == QuestionType.toeicQuestionResponse ||
        this == QuestionType.toeicConversations ||
        this == QuestionType.toeicTalks ||
        displayName.contains('Listening')) {
      return SkillType.listening;
    } else if (displayName.contains('Writing')) {
      return SkillType.writing;
    } else if (displayName.contains('Speaking')) {
      return SkillType.speaking;
    } else {
      return SkillType.reading;
    }
  }
}

// 6. HELPER FUNCTIONS
class ToeicHelper {
  /// Convert raw score to TOEIC scaled score (0-495)
  static int convertToScaledScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    
    final percentage = correctAnswers / totalQuestions;
    
    // Simplified TOEIC conversion table
    if (percentage >= 0.96) return 495;
    if (percentage >= 0.92) return 475;
    if (percentage >= 0.88) return 455;
    if (percentage >= 0.84) return 435;
    if (percentage >= 0.80) return 415;
    if (percentage >= 0.76) return 395;
    if (percentage >= 0.72) return 375;
    if (percentage >= 0.68) return 355;
    if (percentage >= 0.64) return 335;
    if (percentage >= 0.60) return 315;
    if (percentage >= 0.56) return 295;
    if (percentage >= 0.52) return 275;
    if (percentage >= 0.48) return 255;
    if (percentage >= 0.44) return 235;
    if (percentage >= 0.40) return 215;
    if (percentage >= 0.36) return 195;
    if (percentage >= 0.32) return 175;
    if (percentage >= 0.28) return 155;
    if (percentage >= 0.24) return 135;
    if (percentage >= 0.20) return 115;
    if (percentage >= 0.16) return 95;
    if (percentage >= 0.12) return 75;
    if (percentage >= 0.08) return 55;
    if (percentage >= 0.04) return 35;
    return 10;
  }

  /// Get CEFR level from TOEIC score
  static String getCEFRLevel(int totalScore) {
    if (totalScore >= 945) return 'C1';
    if (totalScore >= 785) return 'B2';
    if (totalScore >= 550) return 'B1';
    if (totalScore >= 225) return 'A2';
    if (totalScore >= 120) return 'A1';
    return 'Below A1';
  }

  /// Get performance description
  static String getPerformanceDescription(int scaledScore) {
    if (scaledScore >= 450) return 'Excellent';
    if (scaledScore >= 400) return 'Very Good';
    if (scaledScore >= 350) return 'Good';
    if (scaledScore >= 300) return 'Fair';
    if (scaledScore >= 250) return 'Limited';
    return 'Beginner';
  }
}
