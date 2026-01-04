import '../../../../core/typedef/typedefs.dart';
import '../entities/word_progress_entity.dart';

abstract interface class WordProgressRepository {
  FutureEither<void> saveProgress({
    required String uid,
    required WordProgressEntity progress,
  });

  FutureEither<WordProgressEntity?> getProgress({
    required String uid,
    required String wordId,
  });

  FutureEither<List<WordProgressEntity>> getAllProgress(String uid);

  Stream<List<WordProgressEntity>> watchAllProgress(String uid);

  FutureEither<void> deleteProgress({
    required String uid,
    required String wordId,
  });

  FutureEither<void> deleteAllProgress(String uid);
}
