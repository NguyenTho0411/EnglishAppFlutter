import '../entities/book.dart';

abstract class BooksRepository {
  Future<List<Book>> getAllBooks();
  Future<Book?> getBookById(String bookId);
  Future<void> incrementViewCount(String bookId);
  Future<void> incrementDownloadCount(String bookId);
}
