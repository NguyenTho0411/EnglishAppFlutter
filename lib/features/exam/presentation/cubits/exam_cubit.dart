import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/exam_repository.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/test_entity.dart';
import 'exam_state.dart';

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository repository;

  ExamCubit(this.repository) : super(const ExamInitialState());

  // ==================== READING ====================
  Future<void> loadPassageById(String passageId) async {
    emit(const ExamLoadingState());

    final passageResult = await repository.getPassageById(passageId);

    await passageResult.fold(
      (failure) async {
        emit(ExamErrorState(failure.message));
      },
      (passage) async {
        // Load questions for this passage
        final questionsResult = await repository.getQuestionsByPassage(
          passageId,
        );

        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(passage: passage, questions: questions));
          },
        );
      },
    );
  }

  Future<void> loadRandomPassage({
    required ExamType examType,
    DifficultyLevel? difficulty,
  }) async {
    emit(const ExamLoadingState());

    final passagesResult = await repository.getPassages(
      examType: examType,
      difficulty: difficulty,
      limit: 1,
    );

    await passagesResult.fold(
      (failure) async {
        emit(ExamErrorState(failure.message));
      },
      (passages) async {
        if (passages.isEmpty) {
          emit(const ExamErrorState('No passages available'));
          return;
        }

        final passage = passages.first;

        // Load questions for this passage
        final questionsResult = await repository.getQuestionsByPassage(
          passage.id,
        );

        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(passage: passage, questions: questions));
          },
        );
      },
    );
  }

  Future<void> saveReadingProgress({
    required String passageId,
    required Map<String, String> answers,
    required int timeSpentSeconds,
  }) async {
    // TODO: Implement progress saving
    // This will calculate accuracy and update skill progress
  }

  // ==================== LISTENING ====================
  Future<void> loadAudioById(String audioId) async {
    emit(const ExamLoadingState());

    final audioResult = await repository.getAudioById(audioId);

    await audioResult.fold(
      (failure) async {
        emit(ExamErrorState(failure.message));
      },
      (audio) async {
        // Load questions for this audio
        final questionsResult = await repository.getQuestionsByAudio(audioId);

        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(audio: audio, questions: questions));
          },
        );
      },
    );
  }

  Future<void> loadRandomAudio({
    required ExamType examType,
    DifficultyLevel? difficulty,
  }) async {
    emit(const ExamLoadingState());

    final audiosResult = await repository.getAudios(
      examType: examType,
      difficulty: difficulty,
      limit: 1,
    );

    await audiosResult.fold(
      (failure) async {
        emit(ExamErrorState(failure.message));
      },
      (audios) async {
        if (audios.isEmpty) {
          emit(const ExamErrorState('No audio files available'));
          return;
        }

        final audio = audios.first;

        // Load questions for this audio
        final questionsResult = await repository.getQuestionsByAudio(audio.id);

        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(audio: audio, questions: questions));
          },
        );
      },
    );
  }

  // ==================== SKILL PROGRESS ====================
  Future<void> loadAllSkillProgress({
    required String userId,
    ExamType? examType,
  }) async {
    emit(const ExamLoadingState());

    final result = await repository.getAllSkillProgress(
      userId: userId,
      examType: examType,
    );

    result.fold(
      (failure) => emit(ExamErrorState(failure.message)),
      (progress) => emit(SkillProgressLoadedState(progress)),
    );
  }

  Future<void> loadSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  }) async {
    emit(const ExamLoadingState());

    final result = await repository.getSkillProgress(
      userId: userId,
      examType: examType,
      skill: skill,
    );

    result.fold(
      (failure) => emit(ExamErrorState(failure.message)),
      (progress) => emit(SkillProgressLoadedState([progress])),
    );
  }

  // ==================== TEST ATTEMPTS ====================
  // ==================== MOCK TESTS ====================
  Future<void> loadTests(ExamType examType) async {
    emit(const ExamLoadingState());

    final result = await repository.getTests(examType: examType);

    result.fold(
      (failure) {
        // If Firestore fails, generate sample tests instead of showing error
        final sampleTests = _generateSampleTests(examType);
        emit(TestListLoadedState(sampleTests));
      },
      (tests) {
        // If no tests found, generate samples
        if (tests.isEmpty) {
          final sampleTests = _generateSampleTests(examType);
          emit(TestListLoadedState(sampleTests));
        } else {
          emit(TestListLoadedState(tests));
        }
      },
    );
  }

  List<TestEntity> _generateSampleTests(ExamType examType) {
    return List.generate(5, (index) {
      final testNumber = index + 1;
      return TestEntity(
        id: 'test_${examType.code.toLowerCase()}_$testNumber',
        examType: examType,
        title: '${examType.code} Practice Test $testNumber',
        description:
            'Full-length practice test with all sections. Simulates real exam conditions.',
        sections: _generateSections(examType, testNumber),
        totalQuestions: examType == ExamType.ielts ? 85 : 200,
        totalTimeLimit: examType == ExamType.ielts ? 175 : 120,
        difficulty: DifficultyLevel.values[index % 4],
        isPremium: index >= 2,
        createdAt: DateTime.now().subtract(Duration(days: index * 7)),
        updatedAt: DateTime.now(),
      );
    });
  }

  List<TestSection> _generateSections(ExamType examType, int testNumber) {
    if (examType == ExamType.ielts) {
      return [
        TestSection(
          id: 'section_listening_$testNumber',
          skill: SkillType.listening,
          title: 'Listening',
          questionIds: List.generate(40, (i) => 'q_listening_${testNumber}_$i'),
          timeLimit: 40,
          orderIndex: 0,
        ),
        TestSection(
          id: 'section_reading_$testNumber',
          skill: SkillType.reading,
          title: 'Reading',
          questionIds: List.generate(40, (i) => 'q_reading_${testNumber}_$i'),
          timeLimit: 60,
          orderIndex: 1,
        ),
        TestSection(
          id: 'section_writing_$testNumber',
          skill: SkillType.writing,
          title: 'Writing',
          questionIds: List.generate(2, (i) => 'q_writing_${testNumber}_$i'),
          timeLimit: 60,
          orderIndex: 2,
        ),
        TestSection(
          id: 'section_speaking_$testNumber',
          skill: SkillType.speaking,
          title: 'Speaking',
          questionIds: List.generate(3, (i) => 'q_speaking_${testNumber}_$i'),
          timeLimit: 15,
          orderIndex: 3,
        ),
      ];
    } else {
      // TOEIC
      return [
        TestSection(
          id: 'section_listening_$testNumber',
          skill: SkillType.listening,
          title: 'Listening',
          questionIds: List.generate(
            100,
            (i) => 'q_listening_${testNumber}_$i',
          ),
          timeLimit: 45,
          orderIndex: 0,
        ),
        TestSection(
          id: 'section_reading_$testNumber',
          skill: SkillType.reading,
          title: 'Reading',
          questionIds: List.generate(100, (i) => 'q_reading_${testNumber}_$i'),
          timeLimit: 75,
          orderIndex: 1,
        ),
      ];
    }
  }

  Future<void> startTest({
    required String testId,
    required ExamType examType,
  }) async {
    // Get current user - you may need to inject AuthBloc or get userId differently
    // For now, using a placeholder
    const userId = 'current_user_id';

    emit(const ExamLoadingState());

    final result = await repository.startTestAttempt(
      userId: userId,
      testId: testId,
      examType: examType,
    );

    result.fold((failure) => emit(ExamErrorState(failure.message)), (
      attempt,
    ) async {
      // Load test details
      final testResult = await repository.getTestById(testId);
      testResult.fold(
        (failure) => emit(ExamErrorState(failure.message)),
        (test) => emit(TestAttemptStartedState(attempt: attempt, test: test)),
      );
    });
  }

  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeSpentSeconds,
  }) async {
    final result = await repository.submitAnswer(
      attemptId: attemptId,
      questionId: questionId,
      answer: answer,
      timeSpentSeconds: timeSpentSeconds,
    );

    result.fold((failure) => emit(ExamErrorState(failure.message)), (_) {
      // Answer submitted successfully
      // Could emit a success state or update current state
    });
  }

  Future<void> completeTest(String attemptId) async {
    final result = await repository.completeTest(attemptId);

    result.fold((failure) => emit(ExamErrorState(failure.message)), (_) {
      // Test completed successfully
      // Navigate to results page
    });
  }
}
