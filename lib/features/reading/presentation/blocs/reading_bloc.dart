import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_reading_passages.dart';
import '../../domain/entities/passage.dart';

abstract class ReadingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadReadingPassages extends ReadingEvent {}

class SelectPassage extends ReadingEvent {
  final Passage passage;

  SelectPassage(this.passage);

  @override
  List<Object> get props => [passage];
}

abstract class ReadingState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReadingInitial extends ReadingState {}

class ReadingLoading extends ReadingState {}

class ReadingLoaded extends ReadingState {
  final List<Passage> passages;

  ReadingLoaded(this.passages);

  @override
  List<Object> get props => [passages];
}

class ReadingError extends ReadingState {
  final String message;

  ReadingError(this.message);

  @override
  List<Object> get props => [message];
}

class PassageSelected extends ReadingState {
  final Passage passage;

  PassageSelected(this.passage);

  @override
  List<Object> get props => [passage];
}

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final GetReadingPassages getReadingPassages;

  ReadingBloc(this.getReadingPassages) : super(ReadingInitial()) {
    on<LoadReadingPassages>(_onLoadReadingPassages);
    on<SelectPassage>(_onSelectPassage);
  }

  Future<void> _onLoadReadingPassages(
      LoadReadingPassages event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final passages = await getReadingPassages();
      emit(ReadingLoaded(passages));
    } catch (e) {
      emit(ReadingError(e.toString()));
    }
  }

  void _onSelectPassage(SelectPassage event, Emitter<ReadingState> emit) {
    emit(PassageSelected(event.passage));
  }
}