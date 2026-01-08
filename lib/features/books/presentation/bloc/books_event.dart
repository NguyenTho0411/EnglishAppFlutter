part of 'books_bloc.dart';

abstract class BooksEvent extends Equatable {
  const BooksEvent();

  @override
  List<Object> get props => [];
}

class LoadBooksEvent extends BooksEvent {
  const LoadBooksEvent();
}

class IncrementViewCountEvent extends BooksEvent {
  final String bookId;

  const IncrementViewCountEvent(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class IncrementDownloadCountEvent extends BooksEvent {
  final String bookId;

  const IncrementDownloadCountEvent(this.bookId);

  @override
  List<Object> get props => [bookId];
}
