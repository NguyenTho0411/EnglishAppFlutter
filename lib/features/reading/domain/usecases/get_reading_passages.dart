import '../entities/passage.dart';
import '../repositories/reading_repository.dart';

class GetReadingPassages {
  final ReadingRepository repository;

  GetReadingPassages(this.repository);

  Future<List<Passage>> call() async {
    return await repository.getReadingPassages();
  }
}