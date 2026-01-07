import 'package:dartz/dartz.dart';
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

  ExamRepositoryImpl(this.remoteDataSource);

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
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByPassage(
    String passageId,
  ) async {
    try {
      final result = await remoteDataSource.getQuestionsByPassage(passageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByAudio(
    String audioId,
  ) async {
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
  Future<Either<Failure, TestAttemptEntity>> saveTestAttempt(
    TestAttemptEntity attempt,
  ) async {
    try {
      final result = await remoteDataSource.saveTestAttempt(attempt as dynamic);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TestAttemptEntity>> getTestAttempt(
    String attemptId,
  ) async {
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

      questionResult.fold((failure) => throw Exception('Question not found'), (
        question,
      ) {
        isCorrect = question.isCorrectAnswer(answer);
      });

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
  Future<Either<Failure, Unit>> updateSkillProgress(
    SkillProgressEntity progress,
  ) async {
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
          .watchSkillProgress(userId: userId, examType: examType, skill: skill)
          .map((progress) => Right<Failure, SkillProgressEntity>(progress))
          .handleError(
            (error) => Left<Failure, SkillProgressEntity>(
              ServerFailure(error.toString()),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }
}
