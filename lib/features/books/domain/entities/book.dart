import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String url;
  final String publisher;
  final String language;
  final String isbn;
  final String categoryId;
  final String uid;
  final int pages;
  final int timestamp;
  final int? viewCount;
  final int? downloadsCount;
  final String publishDate;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.url,
    required this.publisher,
    required this.language,
    required this.isbn,
    required this.categoryId,
    required this.uid,
    required this.pages,
    required this.timestamp,
    this.viewCount,
    this.downloadsCount,
    required this.publishDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        url,
        publisher,
        language,
        isbn,
        categoryId,
        uid,
        pages,
        timestamp,
        viewCount,
        downloadsCount,
        publishDate,
      ];
}
