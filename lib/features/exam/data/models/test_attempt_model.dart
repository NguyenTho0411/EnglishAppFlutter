import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test_attempt_entity.dart';
import '../../domain/entities/exam_type.dart';

class TestAttemptModel extends TestAttemptEntity {
  const TestAttemptModel({
    required super.id,
    required super.userId,
    required super.testId,
    required super.examType,
    required super.startedAt,
    super.completedAt,
    super.isCompleted,
    super.answers,
    super.sectionScores,
    super.totalScore,
    super.accuracyRate,
    super.timeSpentSeconds,
    super.isPaused,
    super.pauseCount,
    super.lastResumedAt,
  });

  factory TestAttemptModel.fromEntity(TestAttemptEntity entity) {
    return TestAttemptModel(
      id: entity.id,
      userId: entity.userId,
      testId: entity.testId,
      examType: entity.examType,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      isCompleted: entity.isCompleted,
      answers: entity.answers,
      sectionScores: entity.sectionScores,
      totalScore: entity.totalScore,
      accuracyRate: entity.accuracyRate,
      timeSpentSeconds: entity.timeSpentSeconds,
      isPaused: entity.isPaused,
      pauseCount: entity.pauseCount,
      lastResumedAt: entity.lastResumedAt,
    );
  }

  factory TestAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestAttemptModel(
      id: doc.id,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      examType: ExamType.values.firstWhere((e) => e.code == data['examType']),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      isCompleted: data['isCompleted'] as bool? ?? false,
      answers: (data['answers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, UserAnswerModel.fromMap(value as Map<String, dynamic>)),
          ) ??
          {},
      sectionScores: (data['sectionScores'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              SkillType.values.firstWhere((e) => e.name == key),
              SectionScoreModel.fromMap(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      totalScore: (data['totalScore'] as num?)?.toDouble() ?? 0.0,
      accuracyRate: (data['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      timeSpentSeconds: data['timeSpentSeconds'] as int? ?? 0,
      isPaused: data['isPaused'] as bool? ?? false,
      pauseCount: data['pauseCount'] as int? ?? 0,
      lastResumedAt: data['lastResumedAt'] != null ? (data['lastResumedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'testId': testId,
      'examType': examType.code,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isCompleted': isCompleted,
      'answers': answers.map(
        (key, value) => MapEntry(key, UserAnswerModel.fromEntity(value).toMap()),
      ),
      'sectionScores': sectionScores.map(
        (key, value) => MapEntry(key.name, SectionScoreModel.fromEntity(value).toMap()),
      ),
      'totalScore': totalScore,
      'accuracyRate': accuracyRate,
      'timeSpentSeconds': timeSpentSeconds,
      'isPaused': isPaused,
      'pauseCount': pauseCount,
      'lastResumedAt': lastResumedAt != null ? Timestamp.fromDate(lastResumedAt!) : null,
    };
  }
}

class UserAnswerModel extends UserAnswer {
  const UserAnswerModel({
    required super.questionId,
    required super.answer,
    required super.isCorrect,
    required super.timeSpentSeconds,
    required super.answeredAt,
  });

  factory UserAnswerModel.fromEntity(UserAnswer entity) {
    return UserAnswerModel(
      questionId: entity.questionId,
      answer: entity.answer,
      isCorrect: entity.isCorrect,
      timeSpentSeconds: entity.timeSpentSeconds,
      answeredAt: entity.answeredAt,
    );
  }

  factory UserAnswerModel.fromMap(Map<String, dynamic> map) {
    return UserAnswerModel(
      questionId: map['questionId'] as String,
      answer: map['answer'] as String,
      isCorrect: map['isCorrect'] as bool,
      timeSpentSeconds: map['timeSpentSeconds'] as int,
      answeredAt: (map['answeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'answer': answer,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }
}

class SectionScoreModel extends SectionScore {
  const SectionScoreModel({
    required super.skill,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.accuracy,
    super.bandScore,
    super.rawScore,
    required super.timeSpentSeconds,
  });

  factory SectionScoreModel.fromEntity(SectionScore entity) {
    return SectionScoreModel(
      skill: entity.skill,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      accuracy: entity.accuracy,
      bandScore: entity.bandScore,
      rawScore: entity.rawScore,
      timeSpentSeconds: entity.timeSpentSeconds,
    );
  }

  factory SectionScoreModel.fromMap(Map<String, dynamic> map) {
    return SectionScoreModel(
      skill: SkillType.values.firstWhere((e) => e.name == map['skill']),
      totalQuestions: map['totalQuestions'] as int,
      correctAnswers: map['correctAnswers'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      bandScore: (map['bandScore'] as num?)?.toDouble() ?? 0.0,
      rawScore: map['rawScore'] as int? ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skill': skill.name,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'bandScore': bandScore,
      'rawScore': rawScore,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }
}
