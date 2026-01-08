import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';

part 'books_event.dart';
part 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final BooksRepository repository;

  BooksBloc(this.repository) : super(BooksInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<IncrementViewCountEvent>(_onIncrementViewCount);
    on<IncrementDownloadCountEvent>(_onIncrementDownloadCount);
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      final books = await repository.getAllBooks();
      emit(BooksLoaded(books));
    } catch (e) {
      emit(BooksError(e.toString()));
    }
  }

  Future<void> _onIncrementViewCount(
    IncrementViewCountEvent event,
    Emitter<BooksState> emit,
  ) async {
    try {
      await repository.incrementViewCount(event.bookId);
    } catch (e) {
      // Silent fail for analytics
    }
  }

  Future<void> _onIncrementDownloadCount(
    IncrementDownloadCountEvent event,
    Emitter<BooksState> emit,
  ) async {
    try {
      await repository.incrementDownloadCount(event.bookId);
    } catch (e) {
      // Silent fail for analytics
    }
  }
}
