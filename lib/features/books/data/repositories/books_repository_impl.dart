import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';
import '../datasources/books_remote_data_source.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksRemoteDataSource remoteDataSource;

  BooksRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Book>> getAllBooks() async {
    return await remoteDataSource.getAllBooks();
  }

  @override
  Future<Book?> getBookById(String bookId) async {
    return await remoteDataSource.getBookById(bookId);
  }

  @override
  Future<void> incrementViewCount(String bookId) async {
    await remoteDataSource.incrementViewCount(bookId);
  }

  @override
  Future<void> incrementDownloadCount(String bookId) async {
    await remoteDataSource.incrementDownloadCount(bookId);
  }
}
