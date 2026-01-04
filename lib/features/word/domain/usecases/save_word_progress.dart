import '../../../../core/typedef/typedefs.dart';
import '../../../../core/usecases/usecases.dart';
import '../entities/word_progress_entity.dart';
import '../repositories/word_progress_repository.dart';

class SaveWordProgressUsecase extends Usecases<void, (String, WordProgressEntity)> {
  final WordProgressRepository repository;

  SaveWordProgressUsecase(this.repository);

  @override
  FutureEither<void> call((String, WordProgressEntity) params) {
    return repository.saveProgress(
      uid: params.$1,
      progress: params.$2,
    );
  }
}
