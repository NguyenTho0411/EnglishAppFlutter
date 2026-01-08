import 'package:firebase_database/firebase_database.dart';

import '../models/book_model.dart';

class BooksRemoteDataSource {
  final FirebaseDatabase _database;

  BooksRemoteDataSource(this._database);

  /// Get all books from Firebase Realtime Database
  Future<List<BookModel>> getAllBooks() async {
    try {
      final snapshot = await _database.ref('Books').get();
      
      if (!snapshot.exists) {
        return [];
      }

      final booksMap = snapshot.value as Map<dynamic, dynamic>;
      final List<BookModel> books = [];

      booksMap.forEach((key, value) {
        if (value is Map) {
          final bookData = Map<String, dynamic>.from(value);
          books.add(BookModel.fromJson(bookData, key.toString()));
        }
      });

      // Sort by timestamp descending (newest first)
      books.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return books;
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// Increment view count for a book
  Future<void> incrementViewCount(String bookId) async {
    try {
      final ref = _database.ref('Books/$bookId/viewCount');
      final snapshot = await ref.get();
      final currentCount = (snapshot.value as int?) ?? 0;
      await ref.set(currentCount + 1);
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  /// Increment download count for a book
  Future<void> incrementDownloadCount(String bookId) async {
    try {
      final ref = _database.ref('Books/$bookId/downloadsCount');
      final snapshot = await ref.get();
      final currentCount = (snapshot.value as int?) ?? 0;
      await ref.set(currentCount + 1);
    } catch (e) {
      throw Exception('Failed to increment download count: $e');
    }
  }

  /// Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final snapshot = await _database.ref('Books/$bookId').get();
      
      if (!snapshot.exists) {
        return null;
      }

      final bookData = Map<String, dynamic>.from(snapshot.value as Map);
      return BookModel.fromJson(bookData, bookId);
    } catch (e) {
      throw Exception('Failed to fetch book: $e');
    }
  }
}
