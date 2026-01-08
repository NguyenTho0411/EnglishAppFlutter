import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.url,
    required super.publisher,
    required super.language,
    required super.isbn,
    required super.categoryId,
    required super.uid,
    required super.pages,
    required super.timestamp,
    super.viewCount,
    super.downloadsCount,
    required super.publishDate,
  });

  factory BookModel.fromJson(Map<String, dynamic> json, String id) {
    return BookModel(
      id: id,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      language: json['language'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      pages: json['pages'] as int? ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
      viewCount: json['viewCount'] as int?,
      downloadsCount: json['downloadsCount'] as int?,
      publishDate: json['publishDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'url': url,
      'publisher': publisher,
      'language': language,
      'isbn': isbn,
      'categoryId': categoryId,
      'uid': uid,
      'pages': pages,
      'timestamp': timestamp,
      'viewCount': viewCount,
      'downloadsCount': downloadsCount,
      'publishDate': publishDate,
    };
  }
}
