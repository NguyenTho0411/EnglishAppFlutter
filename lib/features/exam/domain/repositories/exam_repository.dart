import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/question_entity.dart';
import '../entities/passage_entity.dart';
import '../entities/audio_entity.dart';
import '../entities/test_entity.dart';
import '../entities/test_attempt_entity.dart';
import '../entities/skill_progress_entity.dart';
import '../entities/exam_type.dart';

abstract class ExamRepository {
  // Questions
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    required ExamType examType,
    required SkillType skill,
    DifficultyLevel? difficulty,
    int? limit,
  });

  Future<Either<Failure, QuestionEntity>> getQuestionById(String id);

  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByPassage(String passageId);

  Future<Either<Failure, List<QuestionEntity>>> getQuestionsByAudio(String audioId);

  // Passages
  Future<Either<Failure, List<PassageEntity>>> getPassages({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  });

  Future<Either<Failure, PassageEntity>> getPassageById(String id);

  // Audio
  Future<Either<Failure, List<AudioEntity>>> getAudios({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  });

  Future<Either<Failure, AudioEntity>> getAudioById(String id);

  // Tests
  Future<Either<Failure, List<TestEntity>>> getTests({
    required ExamType examType,
    bool? isFullTest,
    DifficultyLevel? difficulty,
  });

  Future<Either<Failure, TestEntity>> getTestById(String id);

  // Test Attempts
  Future<Either<Failure, TestAttemptEntity>> startTestAttempt({
    required String userId,
    required String testId,
    required ExamType examType,
  });

  Future<Either<Failure, TestAttemptEntity>> saveTestAttempt(TestAttemptEntity attempt);

  Future<Either<Failure, TestAttemptEntity>> getTestAttempt(String attemptId);

  Future<Either<Failure, List<TestAttemptEntity>>> getUserTestAttempts({
    required String userId,
    ExamType? examType,
    bool? isCompleted,
    int? limit,
  });

  Future<Either<Failure, Unit>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeSpentSeconds,
  });

  Future<Either<Failure, Unit>> completeTest(String attemptId);

  // Skill Progress
  Future<Either<Failure, SkillProgressEntity>> getSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  });

  Future<Either<Failure, List<SkillProgressEntity>>> getAllSkillProgress({
    required String userId,
    ExamType? examType,
  });

  Future<Either<Failure, Unit>> updateSkillProgress(SkillProgressEntity progress);

  Stream<Either<Failure, SkillProgressEntity>> watchSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  });
}
