import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../models/passage_model.dart';
import '../models/audio_model.dart';
import '../models/test_model.dart';
import '../models/test_attempt_model.dart';
import '../models/skill_progress_model.dart';
import '../../domain/entities/exam_type.dart';

class ExamRemoteDataSource {
  final FirebaseFirestore firestore;

  ExamRemoteDataSource(this.firestore);

  // ==================== QUESTIONS ====================
  Future<List<QuestionModel>> getQuestions({
    required ExamType examType,
    required SkillType skill,
    DifficultyLevel? difficulty,
    int? limit,
  }) async {
    Query query = firestore
        .collection('questions')
        .where('examType', isEqualTo: examType.code)
        .where('skill', isEqualTo: skill.name);

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }

  Future<QuestionModel> getQuestionById(String id) async {
    final doc = await firestore.collection('questions').doc(id).get();
    if (!doc.exists) {
      throw Exception('Question not found');
    }
    return QuestionModel.fromFirestore(doc);
  }

  Future<List<QuestionModel>> getQuestionsByPassage(String passageId) async {
    final snapshot = await firestore
        .collection('questions')
        .where('passageId', isEqualTo: passageId)
        .orderBy('orderIndex')
        .get();
    return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }

  Future<List<QuestionModel>> getQuestionsByAudio(String audioId) async {
    final snapshot = await firestore
        .collection('questions')
        .where('audioId', isEqualTo: audioId)
        .orderBy('orderIndex')
        .get();
    return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }

  // ==================== PASSAGES ====================
  Future<List<PassageModel>> getPassages({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  }) async {
    Query query = firestore.collection('passages').where('examType', isEqualTo: examType.code);

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    if (topic != null) {
      query = query.where('topic', isEqualTo: topic);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PassageModel.fromFirestore(doc)).toList();
  }

  Future<PassageModel> getPassageById(String id) async {
    final doc = await firestore.collection('passages').doc(id).get();
    if (!doc.exists) {
      throw Exception('Passage not found');
    }
    return PassageModel.fromFirestore(doc);
  }

  // ==================== AUDIO ====================
  Future<List<AudioModel>> getAudios({
    required ExamType examType,
    DifficultyLevel? difficulty,
    String? topic,
    int? limit,
  }) async {
    Query query = firestore.collection('audios').where('examType', isEqualTo: examType.code);

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    if (topic != null) {
      query = query.where('topic', isEqualTo: topic);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AudioModel.fromFirestore(doc)).toList();
  }

  Future<AudioModel> getAudioById(String id) async {
    final doc = await firestore.collection('audios').doc(id).get();
    if (!doc.exists) {
      throw Exception('Audio not found');
    }
    return AudioModel.fromFirestore(doc);
  }

  // ==================== TEST ATTEMPTS ====================
  Future<TestAttemptModel> startTestAttempt({
    required String userId,
    required String testId,
    required ExamType examType,
  }) async {
    final attempt = TestAttemptModel(
      id: firestore.collection('test_attempts').doc().id,
      userId: userId,
      testId: testId,
      examType: examType,
      startedAt: DateTime.now(),
      isCompleted: false,
      answers: {},
      sectionScores: {},
      totalScore: 0,
      accuracyRate: 0,
      timeSpentSeconds: 0,
      isPaused: false,
      pauseCount: 0,
    );

    await firestore
        .collection('test_attempts')
        .doc(attempt.id)
        .set(attempt.toFirestore());

    return attempt;
  }

  Future<TestAttemptModel> saveTestAttempt(TestAttemptModel attempt) async {
    await firestore
        .collection('test_attempts')
        .doc(attempt.id)
        .set(attempt.toFirestore(), SetOptions(merge: true));
    return attempt;
  }

  Future<TestAttemptModel> getTestAttempt(String attemptId) async {
    final doc = await firestore.collection('test_attempts').doc(attemptId).get();
    if (!doc.exists) {
      throw Exception('Test attempt not found');
    }
    return TestAttemptModel.fromFirestore(doc);
  }

  Future<List<TestAttemptModel>> getUserTestAttempts({
    required String userId,
    ExamType? examType,
    bool? isCompleted,
    int? limit,
  }) async {
    Query query = firestore
        .collection('test_attempts')
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true);

    if (examType != null) {
      query = query.where('examType', isEqualTo: examType.code);
    }

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TestAttemptModel.fromFirestore(doc)).toList();
  }

  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    final userAnswer = UserAnswerModel(
      questionId: questionId,
      answer: answer,
      isCorrect: isCorrect,
      timeSpentSeconds: timeSpentSeconds,
      answeredAt: DateTime.now(),
    );

    await firestore.collection('test_attempts').doc(attemptId).update({
      'answers.$questionId': userAnswer.toMap(),
    });
  }

  // ==================== SKILL PROGRESS ====================
  Future<SkillProgressModel> getSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  }) async {
    final doc = await firestore
        .collection('user_exam_progress')
        .doc(userId)
        .collection('skills')
        .doc('${examType.code}_${skill.name}')
        .get();

    if (!doc.exists) {
      // Create new progress if doesn't exist
      final newProgress = SkillProgressModel(
        id: doc.id,
        userId: userId,
        examType: examType,
        skill: skill,
        lastPracticeDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore
          .collection('user_exam_progress')
          .doc(userId)
          .collection('skills')
          .doc(doc.id)
          .set(newProgress.toFirestore());
      return newProgress;
    }

    return SkillProgressModel.fromFirestore(doc);
  }

  Future<List<SkillProgressModel>> getAllSkillProgress({
    required String userId,
    ExamType? examType,
  }) async {
    Query query = firestore
        .collection('user_exam_progress')
        .doc(userId)
        .collection('skills');

    if (examType != null) {
      query = query.where('examType', isEqualTo: examType.code);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => SkillProgressModel.fromFirestore(doc)).toList();
  }

  Future<void> updateSkillProgress(SkillProgressModel progress) async {
    await firestore
        .collection('user_exam_progress')
        .doc(progress.userId)
        .collection('skills')
        .doc(progress.id)
        .set(progress.toFirestore(), SetOptions(merge: true));
  }

  Stream<SkillProgressModel> watchSkillProgress({
    required String userId,
    required ExamType examType,
    required SkillType skill,
  }) {
    return firestore
        .collection('user_exam_progress')
        .doc(userId)
        .collection('skills')
        .doc('${examType.code}_${skill.name}')
        .snapshots()
        .map((doc) => SkillProgressModel.fromFirestore(doc));
  }

  // ==================== TESTS ====================
  Future<List<TestModel>> getTests({
    required ExamType examType,
    bool? isFullTest,
    DifficultyLevel? difficulty,
  }) async {
    Query query = firestore
        .collection('tests')
        .where('examType', isEqualTo: examType.code);

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TestModel.fromFirestore(doc)).toList();
  }

  Future<TestModel> getTestById(String id) async {
    final doc = await firestore.collection('tests').doc(id).get();
    if (!doc.exists) {
      throw Exception('Test not found');
    }
    return TestModel.fromFirestore(doc);
  }
}
