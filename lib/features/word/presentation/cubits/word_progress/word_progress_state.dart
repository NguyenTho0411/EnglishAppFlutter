part of 'word_progress_cubit.dart';

enum WordProgressStatus { initial, loading, loaded, error }

class WordProgressState extends Equatable {
  final WordProgressStatus status;
  final List<WordProgressEntity> allProgress;
  final String? errorMessage;

  const WordProgressState({
    required this.status,
    this.allProgress = const [],
    this.errorMessage,
  });

  // Getters for filtered lists
  List<WordProgressEntity> get dueWords =>
      SpacedRepetitionService.getDueWords(allProgress);

  List<WordProgressEntity> get newWords =>
      SpacedRepetitionService.getNewWords(allProgress);

  List<WordProgressEntity> get difficultWords =>
      SpacedRepetitionService.getDifficultWords(allProgress);

  List<WordProgressEntity> get masteredWords =>
      SpacedRepetitionService.getMasteredWords(allProgress);

  Map<String, int> get dailyGoal =>
      SpacedRepetitionService.calculateDailyGoal(allProgress);

  // Stats
  int get totalWords => allProgress.length;

  Map<WordStatus, int> get wordsByStatus {
    final map = <WordStatus, int>{};
    for (var status in WordStatus.values) {
      map[status] = allProgress.where((w) => w.status == status).length;
    }
    return map;
  }

  double get overallAccuracy {
    if (allProgress.isEmpty) return 0;
    final totalCorrect =
        allProgress.fold<int>(0, (sum, w) => sum + w.correctCount);
    final totalIncorrect =
        allProgress.fold<int>(0, (sum, w) => sum + w.incorrectCount);
    final total = totalCorrect + totalIncorrect;
    return total == 0 ? 0 : (totalCorrect / total * 100);
  }

  WordProgressState copyWith({
    WordProgressStatus? status,
    List<WordProgressEntity>? allProgress,
    String? errorMessage,
  }) {
    return WordProgressState(
      status: status ?? this.status,
      allProgress: allProgress ?? this.allProgress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allProgress, errorMessage];
}
