class IELTSTestResult {
  final String testId;
  final DateTime completedAt;
  
  // Section scores
  final double listeningBand;
  final int listeningCorrect;
  final int listeningTotal;
  
  final double readingBand;
  final int readingCorrect;
  final int readingTotal;
  
  final double writingBand;
  final double writingTask1Score;
  final double writingTask2Score;
  
  final double speakingBand;
  final double speakingPart1Score;
  final double speakingPart2Score;
  final double speakingPart3Score;
  
  // Overall
  final double overallBand;
  
  // Detailed answers
  final Map<String, dynamic> listeningAnswers;
  final Map<String, dynamic> readingAnswers;
  final Map<String, String> writingAnswers;
  final Map<String, String> speakingRecordings;

  IELTSTestResult({
    required this.testId,
    required this.completedAt,
    required this.listeningBand,
    required this.listeningCorrect,
    required this.listeningTotal,
    required this.readingBand,
    required this.readingCorrect,
    required this.readingTotal,
    required this.writingBand,
    required this.writingTask1Score,
    required this.writingTask2Score,
    required this.speakingBand,
    required this.speakingPart1Score,
    required this.speakingPart2Score,
    required this.speakingPart3Score,
    required this.overallBand,
    required this.listeningAnswers,
    required this.readingAnswers,
    required this.writingAnswers,
    required this.speakingRecordings,
  });

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'completedAt': completedAt.toIso8601String(),
      'listeningBand': listeningBand,
      'listeningCorrect': listeningCorrect,
      'listeningTotal': listeningTotal,
      'readingBand': readingBand,
      'readingCorrect': readingCorrect,
      'readingTotal': readingTotal,
      'writingBand': writingBand,
      'writingTask1Score': writingTask1Score,
      'writingTask2Score': writingTask2Score,
      'speakingBand': speakingBand,
      'speakingPart1Score': speakingPart1Score,
      'speakingPart2Score': speakingPart2Score,
      'speakingPart3Score': speakingPart3Score,
      'overallBand': overallBand,
      'listeningAnswers': listeningAnswers,
      'readingAnswers': readingAnswers,
      'writingAnswers': writingAnswers,
      'speakingRecordings': speakingRecordings,
    };
  }

  factory IELTSTestResult.fromMap(Map<String, dynamic> map) {
    return IELTSTestResult(
      testId: map['testId'] ?? '',
      completedAt: DateTime.parse(map['completedAt']),
      listeningBand: (map['listeningBand'] ?? 0.0).toDouble(),
      listeningCorrect: map['listeningCorrect'] ?? 0,
      listeningTotal: map['listeningTotal'] ?? 40,
      readingBand: (map['readingBand'] ?? 0.0).toDouble(),
      readingCorrect: map['readingCorrect'] ?? 0,
      readingTotal: map['readingTotal'] ?? 40,
      writingBand: (map['writingBand'] ?? 0.0).toDouble(),
      writingTask1Score: (map['writingTask1Score'] ?? 0.0).toDouble(),
      writingTask2Score: (map['writingTask2Score'] ?? 0.0).toDouble(),
      speakingBand: (map['speakingBand'] ?? 0.0).toDouble(),
      speakingPart1Score: (map['speakingPart1Score'] ?? 0.0).toDouble(),
      speakingPart2Score: (map['speakingPart2Score'] ?? 0.0).toDouble(),
      speakingPart3Score: (map['speakingPart3Score'] ?? 0.0).toDouble(),
      overallBand: (map['overallBand'] ?? 0.0).toDouble(),
      listeningAnswers: map['listeningAnswers'] ?? {},
      readingAnswers: map['readingAnswers'] ?? {},
      writingAnswers: Map<String, String>.from(map['writingAnswers'] ?? {}),
      speakingRecordings: Map<String, String>.from(map['speakingRecordings'] ?? {}),
    );
  }
}
