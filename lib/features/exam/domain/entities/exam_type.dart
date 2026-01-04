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
  speakingPart3('Speaking Part 3'); // Two-way discussion

  final String displayName;

  const QuestionType(this.displayName);
}
