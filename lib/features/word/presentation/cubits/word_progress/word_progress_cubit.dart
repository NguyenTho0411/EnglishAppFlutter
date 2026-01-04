import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/word_progress_entity.dart';
import '../../../domain/entities/word_status.dart';
import '../../../domain/services/spaced_repetition_service.dart';
import '../../../domain/usecases/get_all_word_progress.dart';
import '../../../domain/usecases/save_word_progress.dart';
import '../../../domain/usecases/watch_word_progress.dart';

part 'word_progress_state.dart';

class WordProgressCubit extends Cubit<WordProgressState> {
  final GetAllWordProgressUsecase getAllProgressUsecase;
  final SaveWordProgressUsecase saveProgressUsecase;
  final WatchWordProgressUsecase watchProgressUsecase;

  StreamSubscription? _progressSubscription;

  WordProgressCubit(
    this.getAllProgressUsecase,
    this.saveProgressUsecase,
    this.watchProgressUsecase,
  ) : super(const WordProgressState(status: WordProgressStatus.initial));

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }

  void initProgressStream(String uid) {
    emit(state.copyWith(status: WordProgressStatus.loading));

    _progressSubscription?.cancel();
    _progressSubscription = watchProgressUsecase(uid).listen(
      (progressList) {
        emit(state.copyWith(
          status: WordProgressStatus.loaded,
          allProgress: progressList,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: WordProgressStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> loadAllProgress(String uid) async {
    emit(state.copyWith(status: WordProgressStatus.loading));

    final result = await getAllProgressUsecase(uid);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WordProgressStatus.error,
        errorMessage: failure.message,
      )),
      (progressList) => emit(state.copyWith(
        status: WordProgressStatus.loaded,
        allProgress: progressList,
      )),
    );
  }

  Future<void> updateWordProgress({
    required String uid,
    required String wordId,
    required String word,
    required bool isCorrect,
  }) async {
    // Find existing progress or create new
    var progress = state.allProgress.firstWhere(
      (p) => p.wordId == wordId,
      orElse: () => WordProgressEntity.newWord(wordId: wordId, word: word),
    );

    // Update progress using SRS algorithm
    final updated = SpacedRepetitionService.updateProgress(
      current: progress,
      isCorrect: isCorrect,
    );

    // Save to Firestore
    await saveProgressUsecase((uid, updated));

    print('✅ Word progress updated: $word - ${updated.status.displayName}');
  }

  Future<void> bulkUpdateProgress({
    required String uid,
    required List<MapEntry<String, bool>> results,
  }) async {
    for (var result in results) {
      await updateWordProgress(
        uid: uid,
        wordId: result.key,
        word: result.key,
        isCorrect: result.value,
      );
    }
  }

  void cancelStream() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
  }
}
