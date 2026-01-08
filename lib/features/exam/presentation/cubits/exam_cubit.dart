import 'package:flutter_application_1/features/exam/data/models/test_attempt_model.dart';
import 'package:flutter_application_1/features/exam/domain/entities/question_entity.dart';
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
        final questionsResult = await repository.getQuestionsByPassage(passageId);
        
        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(
              passage: passage,
              questions: questions,
            ));
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
        final questionsResult = await repository.getQuestionsByPassage(passage.id);
        
        questionsResult.fold(
          (failure) {
            emit(ExamErrorState(failure.message));
          },
          (questions) {
            emit(ExamLoadedState(
              passage: passage,
              questions: questions,
            ));
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
            emit(ExamLoadedState(
              audio: audio,
              questions: questions,
            ));
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
            emit(ExamLoadedState(
              audio: audio,
              questions: questions,
            ));
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
        description: 'Full-length practice test with all sections. Simulates real exam conditions.',
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
          questionIds: List.generate(100, (i) => 'q_listening_${testNumber}_$i'),
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
    
    result.fold(
      (failure) => emit(ExamErrorState(failure.message)),
      (attempt) async {
        // Load test details
        final testResult = await repository.getTestById(testId);
        testResult.fold(
          (failure) => emit(ExamErrorState(failure.message)),
          (test) => emit(TestAttemptStartedState(attempt: attempt, test: test)),
        );
      },
    );
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
    
    result.fold(
      (failure) => emit(ExamErrorState(failure.message)),
      (_) {
        // Answer submitted successfully
        // Could emit a success state or update current state
      },
    );
  }

  Future<void> completeTest(String attemptId) async {
    final result = await repository.completeTest(attemptId);
    
    result.fold(
      (failure) => emit(ExamErrorState(failure.message)),
      (_) {
        // Test completed successfully
        // Navigate to results page
      },
    );
  }

Future<void> getToeicStatistics(String userId) async {
  emit(const ExamLoadingState()); 
  
  // Lưu ý: repository phải trả về Result/Either (Clean Architecture)
  final result = await repository.getToeicStatistics(userId); 
  
  result.fold(
    (failure) => emit(ExamErrorState(failure.message)),
    (stats) {
      emit(ToeicStatisticsLoadedState(
        bestScore: (stats['bestScore'] as num? ?? 0).toInt(),
        averageScore: (stats['averageScore'] as num? ?? 0).toInt(),
        totalTests: (stats['totalAttempts'] as num? ?? 0).toInt(),
        // Nếu bạn muốn lấy accuracy cho cái vòng tròn 78%, hãy thêm field vào ToeicStatisticsLoadedState
      ));
    },
  );
}
// Trong class ExamCubit extends Cubit<ExamState>
/// Load Questions by TOEIC Part (with Passage for Part 7)
Future<void> loadToeicQuestionsByPart({
  required ToeicPart part,
  DifficultyLevel? difficulty,
  int limit = 30,
}) async {
  emit(const ExamLoadingState());
  
  final result = await repository.getQuestionsByToeicPart(
    part: part,
    difficulty: difficulty,
    limit: limit,
  );
  
  await result.fold(
    (failure) async => emit(ExamErrorState(failure.message)),
    (questions) async {
      if (questions.isEmpty) {
        emit(ExamErrorState('No questions available for ${part.title}. Please seed data first.'));
        return;
      }

      // If Part 7 and has passageId, load passage content
      if (part.partNumber == 7 && questions.first.passageId != null) {
        final passageResult = await repository.getPassageById(questions.first.passageId!);
        passageResult.fold(
          (failure) {
            // If passage loading fails, still show questions
            emit(ExamLoadedState(questions: questions));
          },
          (passage) {
            // Load passage successfully
            emit(ExamLoadedState(questions: questions, passage: passage));
          },
        );
      } else {
        emit(ExamLoadedState(questions: questions));
      }
    },
  );
}

// Trong ExamCubit.dart
Future<void> savePracticeResult({
  required String userId,
  required List<QuestionEntity> questions,
  required Map<int, String> userAnswers,
  required int timeSpentSeconds,
}) async {
  int correctCount = 0;
  for (int i = 0; i < questions.length; i++) {
    if (userAnswers[i] == questions[i].correctAnswer) {
      correctCount++;
    }
  }

  final result = await repository.savePracticeResult(
    userId: userId,
    skill: SkillType.reading,
    correctCount: correctCount,
    totalCount: questions.length,
    timeSpentSeconds: timeSpentSeconds,
  );

  result.fold(
    (failure) {
      print('Failed to save practice result: ${failure.message}');
      // Don't emit error, just log it
    },
    (_) {
      // Reload statistics after saving
      loadToeicStatistics(userId);
    },
  );

}



/// Load tất cả Listening questions (Part 1-4)
Future<void> loadToeicListeningQuestions({
  DifficultyLevel? difficulty,
}) async {
  emit(const ExamLoadingState());
  
  final result = await repository.getQuestions(
    examType: ExamType.toeic,
    skill: SkillType.listening,
    difficulty: difficulty,
    limit: 100, // 100 câu Listening
  );
  
  result.fold(
    (failure) => emit(ExamErrorState(failure.message)),
    (questions) {
      if (questions.isEmpty) {
        emit(const ExamErrorState('No listening questions available'));
      } else {
        emit(ExamLoadedState(questions: questions));
      }
    },
  );
}

Future<void> loadToeicReadingQuestions({
  DifficultyLevel? difficulty,
}) async {
  emit(const ExamLoadingState());
  
  final result = await repository.getQuestions(
    examType: ExamType.toeic,
    skill: SkillType.reading,
    difficulty: difficulty,
    limit: 100,
  );
  
  result.fold(
    (failure) => emit(ExamErrorState(failure.message)),
    (questions) {
      if (questions.isEmpty) {
        emit(const ExamErrorState('No reading questions available. Please seed data first.'));
      } else {
        emit(ExamLoadedState(questions: questions));
      }
    },
  );
}

/// Submit TOEIC Listening
Future<void> submitToeicListening({
  required String attemptId,
  required String userId,
  required Map<String, UserAnswerModel> answers,
}) async {
  emit(const ExamLoadingState());
  
  final result = await repository.submitToeicListening(
    attemptId: attemptId,
    userId: userId,
    answers: answers,
  );
  
  result.fold(
    (failure) => emit(ExamErrorState(failure.message)),
    (resultData) => emit(ToeicSubmissionSuccessState(resultData)),
  );
}

/// Submit TOEIC Reading
Future<void> submitToeicReading({
  required String attemptId,
  required String userId,
  required Map<String, UserAnswerModel> answers,
}) async {
  emit(const ExamLoadingState());
  
  final result = await repository.submitToeicReading(
    attemptId: attemptId,
    userId: userId,
    answers: answers,
  );
  
  result.fold(
    (failure) => emit(ExamErrorState(failure.message)),
    (resultData) => emit(ToeicSubmissionSuccessState(resultData)),
  );
}
Future<void> loadToeicStatistics(String userId) async {

  
  try {
    final result = await repository.getToeicStatistics(userId);
    
    result.fold(
      (failure) {
        print('Failed to load TOEIC statistics: ${failure.message}');
      },
      (stats) {
        // ✅ Emit vào ExamLoadedState thay vì state riêng
        final currentState = state;
        if (currentState is ExamLoadedState) {
          // Giữ questions, chỉ update stats
          emit(ExamLoadedState(
            passage: currentState.passage,
            audio: currentState.audio,
            questions: currentState.questions,
            currentAttempt: currentState.currentAttempt,
            bestScore: (stats['bestScore'] as num? ?? 0).toInt(),
            averageScore: (stats['averageScore'] as num? ?? 0).toInt(),
            totalTests: (stats['totalAttempts'] as num? ?? 0).toInt(),
          ));
        } else {
          // Chưa có questions, chỉ emit stats
          emit(ExamLoadedState(
            bestScore: (stats['bestScore'] as num? ?? 0).toInt(),
            averageScore: (stats['averageScore'] as num? ?? 0).toInt(),
            totalTests: (stats['totalAttempts'] as num? ?? 0).toInt(),
          ));
        }
      },
    );
  } catch (e) {
    print('Error loading TOEIC statistics: $e');
    // Không emit error, chỉ log
  }
}

int calculateCorrectAnswers(Map<int, String> userAnswers) {
    // Truy cập biến 'state' của Cubit
    final currentState = state; 
    
    if (currentState is ExamLoadedState) {
      int count = 0;
      final questions = currentState.questions;

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final userSelected = userAnswers[i];

        // So sánh đáp án: trim() để xóa khoảng trắng, toUpperCase() để đồng nhất format
        if (userSelected != null && 
            userSelected.trim().toUpperCase() == question.correctAnswer?.trim().toUpperCase()) {
          count++;
        }
      }
      return count;
    }
    return 0; // Trả về 0 nếu chưa load được câu hỏi
  }


  void selectPracticeAnswer(String questionId, String answer) {
    final currentState = state;
    if (currentState is ExamLoadedState) {
      // Tạo map mới từ map cũ để trigger state change
      final newAnswers = Map<String, String>.from(currentState.practiceAnswers);
      newAnswers[questionId] = answer;

      emit(currentState.copyWith(practiceAnswers: newAnswers));
    }
  }


  void resetPracticeSession() {
    final currentState = state;
    if (currentState is ExamLoadedState) {
      emit(currentState.copyWith(practiceAnswers: {})); // Xóa sạch map
    }
  }
  
  // 3. Hàm Save kết quả (Chỉ lưu điểm số lên Firebase rồi reset)
  Future<void> submitPracticeAndSaveScore({
    required String userId,
    required List<QuestionEntity> questions,
    required int timeSpentSeconds,
  }) async {
    final currentState = state;
    if (currentState is! ExamLoadedState) return;

    final userAnswers = currentState.practiceAnswers;
    
    // Tính điểm
    int correctCount = 0;
    for (var q in questions) {
      // So sánh đáp án (Question ID phải khớp)
      if (userAnswers[q.id] == q.correctAnswer) {
        correctCount++;
      }
    }

    // Lưu thống kê nhẹ nhàng (chỉ để vẽ biểu đồ)
    await repository.savePracticeResult(
      userId: userId,
      skill: SkillType.reading, // Hoặc listening tùy ngữ cảnh
      correctCount: correctCount,
      totalCount: questions.length,
      timeSpentSeconds: timeSpentSeconds,
    );
    
    // Lưu xong thì KHÔNG reset ngay, để user còn xem lại bài (Review)
    // Việc reset sẽ làm khi user bấm nút "Thoát" hoặc "Làm lại"
    
    // Reload lại thống kê mới nhất
    loadToeicStatistics(userId);
  }

Future<void> loadFullTestDetails(String testId) async {
    emit(const ExamLoadingState());

    // 1. Lấy thông tin bài Test
    final testResult = await repository.getTestById(testId);

    await testResult.fold(
      (failure) async => emit(ExamErrorState(failure.message)),
      (test) async {
        // 2. Lấy danh sách câu hỏi dựa trên questionIds trong bài test
        // Lưu ý: Repository cần có hàm getQuestionsByIds (hoặc bạn loop gọi từng câu - hơi chậm)
        // Cách tốt nhất là Repository nên hỗ trợ query "whereIn"
        
        final questionsResult = await repository.getQuestionsByTestId(testId);
        
        questionsResult.fold(
          (failure) => emit(ExamErrorState(failure.message)),
          (questions) {
            // Sắp xếp câu hỏi theo thứ tự (nếu cần)
            questions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
            
            emit(ExamLoadedState(
              questions: questions,
              // Có thể truyền thêm test entity vào state nếu cần
            ));
          },
        );
      },
    );
  }


  
}





