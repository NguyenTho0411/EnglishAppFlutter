import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/passage_entity.dart';
import '../../domain/entities/audio_entity.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/entities/test_attempt_entity.dart';
import '../../domain/entities/skill_progress_entity.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitialState extends ExamState {
  const ExamInitialState();
}

class ExamLoadingState extends ExamState {
  const ExamLoadingState();
}

class ExamLoadedState extends ExamState {
  final PassageEntity? passage;
  final AudioEntity? audio;
  final List<QuestionEntity> questions;
  final TestAttemptEntity? currentAttempt;

  const ExamLoadedState({
    this.passage,
    this.audio,
    this.questions = const [],
    this.currentAttempt,
  });

  ExamLoadedState copyWith({
    PassageEntity? passage,
    AudioEntity? audio,
    List<QuestionEntity>? questions,
    TestAttemptEntity? currentAttempt,
  }) {
    return ExamLoadedState(
      passage: passage ?? this.passage,
      audio: audio ?? this.audio,
      questions: questions ?? this.questions,
      currentAttempt: currentAttempt ?? this.currentAttempt,
    );
  }

  @override
  List<Object?> get props => [passage, audio, questions, currentAttempt];
}

class ExamErrorState extends ExamState {
  final String message;

  const ExamErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Progress states
class SkillProgressLoadedState extends ExamState {
  final List<SkillProgressEntity> progressList;

  const SkillProgressLoadedState(this.progressList);

  @override
  List<Object?> get props => [progressList];
}

// Test states
class TestListLoadedState extends ExamState {
  final List<TestEntity> tests;

  const TestListLoadedState(this.tests);

  @override
  List<Object?> get props => [tests];
}

class TestAttemptStartedState extends ExamState {
  final TestAttemptEntity attempt;
  final TestEntity test;

  const TestAttemptStartedState({
    required this.attempt,
    required this.test,
  });

  @override
  List<Object?> get props => [attempt, test];
}
