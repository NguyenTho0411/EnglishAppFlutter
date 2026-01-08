import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/exam/data/data_sources/toeic_remote_data_source.dart';
import 'package:flutter_application_1/features/exam/data/models/test_attempt_model.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/passage_entity.dart';
import '../../domain/entities/audio_entity.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/entities/test_attempt_entity.dart';
import '../../domain/entities/skill_progress_entity.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/repositories/exam_repository.dart';
import '../data_sources/exam_remote_data_source.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;
  final ToeicRemoteDataSource toeicDataSource;
  
  ExamRepositoryImpl(this.remoteDataSource, this.toeicDataSource);

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    required ExamType examType,
    required SkillType skill,
    DifficultyLevel? difficulty,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getQuestions(
        examType: examType,
        skill: skill,
        difficulty: difficulty,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuestionEntity>> getQuestionById(String id) async {
    try {
      final result = await remoteDataSource.getQuestionById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByPassage(String passageId) async {
    try {
      final result = await remoteDataSource.getQuestionsByPassage(passageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByAudio(String audioId) async {
    try {
      final result = await remoteDataSource.getQuestionsByAudio(audioId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PassageEntity>>> getPassages({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getPassages(
        examType: examType,
        difficulty: difficulty,
        topic: topic,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PassageEntity>> getPassageById(String id) async {
    try {
      final result = await remoteDataSource.getPassageById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> getAudios({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getAudios(
        examType: examType,
        difficulty: difficulty,
        topic: topic,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AudioEntity>> getAudioById(String id) async {
    try {
      final result = await remoteDataSource.getAudioById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TestEntity>>> getTests({
    required ExamType examType,
    bool? isFullTest,
    DifficultyLevel? difficulty,
  }) async {
    try {
      final result = await remoteDataSource.getTests(
        examType: examType,
        isFullTest: isFullTest,
        difficulty: difficulty,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  @override
  Future<Either<Failure, TestEntity>> getTestById(String id) async {
    try {
      final result = await remoteDataSource.getTestById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TestAttemptEntity>> startTestAttempt({
    required String userId,
    required String testId,
    required ExamType examType,
  }) async {
    try {
      final result = await remoteDataSource.startTestAttempt(
        userId: userId,
        testId: testId,
        examType: examType,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TestAttemptEntity>> saveTestAttempt(TestAttemptEntity attempt) async {
    try {
      final result = await remoteDataSource.saveTestAttempt(attempt as dynamic);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TestAttemptEntity>> getTestAttempt(String attemptId) async {
    try {
      final result = await remoteDataSource.getTestAttempt(attemptId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TestAttemptEntity>>> getUserTestAttempts({
    required String userId,
    ExamType? examType,
    bool? isCompleted,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getUserTestAttempts(
        userId: userId,
        examType: examType,
        isCompleted: isCompleted,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeSpentSeconds,
  }) async {
    try {
      // Get question to check if answer is correct
      final questionResult = await getQuestionById(questionId);
      bool isCorrect = false;
      
      questionResult.fold(
        (failure) => throw Exception('Question not found'),
        (question) {
          isCorrect = question.isCorrectAnswer(answer);
        },
      );

      await remoteDataSource.submitAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answer: answer,
        isCorrect: isCorrect,
        timeSpentSeconds: timeSpentSeconds,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeTest(String attemptId) async {
    try {
      // TODO: Implement completeTest logic
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SkillProgressEntity>> getSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  }) async {
    try {
      final result = await remoteDataSource.getSkillProgress(
        userId: userId,
        examType: examType,
        skill: skill,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SkillProgressEntity>>> getAllSkillProgress({
    required String userId,
    ExamType? examType,
  }) async {
    try {
      final result = await remoteDataSource.getAllSkillProgress(
        userId: userId,
        examType: examType,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSkillProgress(SkillProgressEntity progress) async {
    try {
      await remoteDataSource.updateSkillProgress(progress as dynamic);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, SkillProgressEntity>> watchSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  }) {
    try {
      return remoteDataSource
          .watchSkillProgress(
            userId: userId,
            examType: examType,
            skill: skill,
          )
          .map((progress) => Right<Failure, SkillProgressEntity>(progress))
          .handleError((error) => Left<Failure, SkillProgressEntity>(
                ServerFailure(error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

@override
  Future<Either<Failure, Map<String, dynamic>>> submitToeicListening({
    required String attemptId,
    required String userId,
    required Map<String, UserAnswerModel> answers,
  }) async {
    try {
      final result = await toeicDataSource.submitToeicListening(
        attemptId: attemptId,
        userId: userId,
        answers: answers,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure("Lỗi khi nộp bài nghe TOEIC: $e"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitToeicReading({
    required String attemptId,
    required String userId,
    required Map<String, UserAnswerModel> answers,
  }) async {
    try {
      final result = await toeicDataSource.submitToeicReading(
        attemptId: attemptId,
        userId: userId,
        answers: answers,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure("Lỗi khi nộp bài đọc TOEIC: $e"));
    }
  }

  // Giữ nguyên các hàm override khác của bạn bên dưới...
  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByToeicPart({
    required ToeicPart part,
    DifficultyLevel? difficulty,
    int? limit,
  }) async {
    try {
      final models = await toeicDataSource.getQuestionsByToeicPart(
        part: part,
        difficulty: difficulty,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure("Lỗi tải câu hỏi theo Part: $e"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getToeicStatistics(String userId) async {
    try {
      final result = await toeicDataSource.getToeicStatistics(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure("Lỗi tải thống kê: $e"));
    }
  }

@override
Future<Either<Failure, Unit>> savePracticeResult({
  required String userId,
  required SkillType skill,
  required int correctCount,
  required int totalCount,
  required int timeSpentSeconds,
  int? partNumber,
}) async {
  try {
    // Gọi thông qua toeicDataSource thay vì gọi trực tiếp firestore
    await toeicDataSource.savePracticeResult(
      userId: userId,
      skill: skill.name, // Convert enum sang String
      correctCount: correctCount,
      totalCount: totalCount,
      timeSpentSeconds: timeSpentSeconds,
      partNumber: partNumber,
    );
    
    return const Right(unit);
  } catch (e) {
    // Trả về Left kèm theo Failure đúng format Clean Architecture bạn đang dùng
    return Left(ServerFailure("Lỗi khi lưu kết quả luyện tập: $e"));
  }
}


@override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByTestId(String testId) async {
    try {
      print("🔍 [DEBUG] Bắt đầu lấy câu hỏi cho TestID: $testId");

      // 1. Lấy thông tin bài Test từ RemoteDataSource
      // Lưu ý: remoteDataSource trả về Model (dữ liệu thô), không phải Either
      final testModel = await remoteDataSource.getTestById(testId);
      
      // Kiểm tra dữ liệu (Nếu datasource không throw lỗi thì code chạy tiếp)
      print("✅ [DEBUG] Tìm thấy Test: ${testModel.title}");
      print("   -> Số lượng Sections: ${testModel.sections.length}");

      // 2. Lấy danh sách ID câu hỏi từ các section của bài test
      List<String> allQuestionIds = [];
      for (var section in testModel.sections) {
        if (section.questionIds.isNotEmpty) {
          allQuestionIds.addAll(section.questionIds);
        }
      }

      print("📦 [DEBUG] Tổng số ID câu hỏi cần lấy: ${allQuestionIds.length}");

      if (allQuestionIds.isEmpty) {
        return const Right([]); // Trả về rỗng nếu bài test chưa có câu hỏi
      }

      // 3. Gọi RemoteDataSource để lấy chi tiết từng câu hỏi
      // Dùng Future.wait để chạy song song (Parallel) giúp tải nhanh hơn
      final futures = allQuestionIds.map((id) => remoteDataSource.getQuestionById(id));
      
      // Chờ tất cả các request hoàn tất
      final results = await Future.wait(futures);
      
      // 4. Chuyển đổi Model sang Entity (Nếu cần)
      // Vì QuestionModel kế thừa QuestionEntity nên có thể cast hoặc dùng trực tiếp
      final questions = results.map((model) => model as QuestionEntity).toList();

      print("✅ [DEBUG] Đã tải thành công ${questions.length} câu hỏi.");

      return Right(questions);

    } catch (e) {
      print("❌ [DEBUG] Lỗi tại getQuestionsByTestId: $e");
      return Left(ServerFailure(e.toString()));
    }
  }

}

