import '../entities/passage.dart';

abstract class ReadingRepository {
  Future<List<Passage>> getReadingPassages();
  Future<Passage> getPassageById(String id);
}