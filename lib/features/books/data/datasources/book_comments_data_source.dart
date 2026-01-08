import 'package:firebase_database/firebase_database.dart';

import '../models/book_comment_model.dart';

class BookCommentsDataSource {
  final FirebaseDatabase _database;

  BookCommentsDataSource(this._database);

  /// Get all comments for a book
  Future<List<BookComment>> getBookComments(String bookId) async {
    try {
      final snapshot = await _database.ref('Books/$bookId/Comments').get();
      
      if (!snapshot.exists) {
        return [];
      }

      final commentsMap = snapshot.value as Map<dynamic, dynamic>;
      final List<BookComment> comments = [];

      commentsMap.forEach((key, value) {
        if (value is Map) {
          final commentData = Map<String, dynamic>.from(value);
          comments.add(BookComment.fromJson(commentData, key.toString()));
        }
      });

      // Sort by timestamp descending (newest first)
      comments.sort((a, b) {
        try {
          final aTime = int.parse(a.timestamp);
          final bTime = int.parse(b.timestamp);
          return bTime.compareTo(aTime);
        } catch (e) {
          return 0;
        }
      });

      return comments;
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  /// Add a new comment to a book
  Future<void> addComment({
    required String bookId,
    required String uid,
    required String comment,
    String? userName,
    String? userAvatar,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final commentRef = _database.ref('Books/$bookId/Comments').push();
      
      await commentRef.set({
        'id': commentRef.key,
        'bookId': bookId,
        'uid': uid,
        'comment': comment,
        'timestamp': timestamp,
        if (userName != null) 'userName': userName,
        if (userAvatar != null) 'userAvatar': userAvatar,
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String bookId, String commentId) async {
    try {
      await _database.ref('Books/$bookId/Comments/$commentId').remove();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
