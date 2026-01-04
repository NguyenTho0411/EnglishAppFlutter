import '../../../../core/typedef/typedefs.dart';
import '../../../../core/usecases/usecases.dart';
import '../entities/word_progress_entity.dart';
import '../repositories/word_progress_repository.dart';

class GetAllWordProgressUsecase extends Usecases<List<WordProgressEntity>, String> {
  final WordProgressRepository repository;

  GetAllWordProgressUsecase(this.repository);

  @override
  FutureEither<List<WordProgressEntity>> call(String uid) {
    return repository.getAllProgress(uid);
  }
}
