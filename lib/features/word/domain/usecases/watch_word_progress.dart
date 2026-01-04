import '../entities/word_progress_entity.dart';
import '../repositories/word_progress_repository.dart';

class WatchWordProgressUsecase {
  final WordProgressRepository repository;

  WatchWordProgressUsecase(this.repository);

  Stream<List<WordProgressEntity>> call(String uid) {
    return repository.watchAllProgress(uid);
  }
}
