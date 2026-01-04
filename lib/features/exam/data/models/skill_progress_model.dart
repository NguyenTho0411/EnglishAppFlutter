import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/skill_progress_entity.dart';
import '../../domain/entities/exam_type.dart';

class SkillProgressModel extends SkillProgressEntity {
  const SkillProgressModel({
    required super.id,
    required super.userId,
    required super.examType,
    required super.skill,
    super.currentBandScore,
    super.estimatedScore,
    super.totalAttempts,
    super.totalQuestionsAnswered,
    super.totalCorrectAnswers,
    super.overallAccuracy,
    super.totalTimeSpentSeconds,
    required super.lastPracticeDate,
    super.questionsByDifficulty,
    super.accuracyByType,
    super.weakTopics,
    super.strongTopics,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SkillProgressModel.fromEntity(SkillProgressEntity entity) {
    return SkillProgressModel(
      id: entity.id,
      userId: entity.userId,
      examType: entity.examType,
      skill: entity.skill,
      currentBandScore: entity.currentBandScore,
      estimatedScore: entity.estimatedScore,
      totalAttempts: entity.totalAttempts,
      totalQuestionsAnswered: entity.totalQuestionsAnswered,
      totalCorrectAnswers: entity.totalCorrectAnswers,
      overallAccuracy: entity.overallAccuracy,
      totalTimeSpentSeconds: entity.totalTimeSpentSeconds,
      lastPracticeDate: entity.lastPracticeDate,
      questionsByDifficulty: entity.questionsByDifficulty,
      accuracyByType: entity.accuracyByType,
      weakTopics: entity.weakTopics,
      strongTopics: entity.strongTopics,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory SkillProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillProgressModel(
      id: doc.id,
      userId: data['userId'] as String,
      examType: ExamType.values.firstWhere((e) => e.code == data['examType']),
      skill: SkillType.values.firstWhere((e) => e.name == data['skill']),
      currentBandScore: (data['currentBandScore'] as num?)?.toDouble() ?? 0.0,
      estimatedScore: (data['estimatedScore'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: data['totalAttempts'] as int? ?? 0,
      totalQuestionsAnswered: data['totalQuestionsAnswered'] as int? ?? 0,
      totalCorrectAnswers: data['totalCorrectAnswers'] as int? ?? 0,
      overallAccuracy: (data['overallAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpentSeconds: data['totalTimeSpentSeconds'] as int? ?? 0,
      lastPracticeDate: (data['lastPracticeDate'] as Timestamp).toDate(),
      questionsByDifficulty: (data['questionsByDifficulty'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              DifficultyLevel.values.firstWhere((e) => e.name == key),
              value as int,
            ),
          ) ??
          {},
      accuracyByType: (data['accuracyByType'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              QuestionType.values.firstWhere((e) => e.displayName == key),
              (value as num).toDouble(),
            ),
          ) ??
          {},
      weakTopics: List<String>.from(data['weakTopics'] ?? []),
      strongTopics: List<String>.from(data['strongTopics'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'examType': examType.code,
      'skill': skill.name,
      'currentBandScore': currentBandScore,
      'estimatedScore': estimatedScore,
      'totalAttempts': totalAttempts,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'overallAccuracy': overallAccuracy,
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'lastPracticeDate': Timestamp.fromDate(lastPracticeDate),
      'questionsByDifficulty': questionsByDifficulty.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'accuracyByType': accuracyByType.map(
        (key, value) => MapEntry(key.displayName, value),
      ),
      'weakTopics': weakTopics,
      'strongTopics': strongTopics,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
