import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_type.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.examType,
    required super.skill,
    required super.questionType,
    required super.difficulty,
    required super.section,
    required super.part,
    required super.orderIndex,
    required super.questionText,
    super.options,
    super.correctAnswer,
    super.correctAnswers,
    super.explanation,
    super.passageId,
    super.audioId,
    super.metadata,
    super.isPremium,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      examType: entity.examType,
      skill: entity.skill,
      questionType: entity.questionType,
      difficulty: entity.difficulty,
      section: entity.section,
      part: entity.part,
      orderIndex: entity.orderIndex,
      questionText: entity.questionText,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      correctAnswers: entity.correctAnswers,
      explanation: entity.explanation,
      passageId: entity.passageId,
      audioId: entity.audioId,
      metadata: entity.metadata,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    T safeEnum<T>(List<T> values, bool Function(T) test, T defaultValue) {
    return values.cast<T?>().firstWhere((e) => e != null && test(e), orElse: () => defaultValue)!;
  }
    return QuestionModel(
    id: doc.id,
    // Fix lỗi No Element bằng cách cung cấp default value
    examType: safeEnum(ExamType.values, (e) => e.code == data['examType'], ExamType.toeic),
    skill: safeEnum(SkillType.values, (e) => e.name == data['skill'], SkillType.listening),
    questionType: safeEnum(QuestionType.values, (e) => e.displayName == data['questionType'], QuestionType.toeicPhotographs),
    difficulty: safeEnum(DifficultyLevel.values, (e) => e.name == data['difficulty'], DifficultyLevel.intermediate),
    section: data['section'] as String? ?? '',
    part: data['part'] as int? ?? 1,
    orderIndex: data['orderIndex'] as int? ?? 0,
    questionText: data['questionText'] as String? ?? '',
    options: data['options'] != null ? List<String>.from(data['options']) : null,
    correctAnswer: data['correctAnswer'] as String?,
    correctAnswers: data['correctAnswers'] != null ? List<String>.from(data['correctAnswers']) : null,
    explanation: data['explanation'] as String?,
    passageId: data['passageId'] as String?,
    
    audioId: (data['audioId'] ?? data['audioUrl']) as String?, 
    
    metadata: data['metadata'] as Map<String, dynamic>?,
    isPremium: data['isPremium'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examType': examType.code,
      'skill': skill.name,
      'questionType': questionType.displayName,
      'difficulty': difficulty.name,
      'section': section,
      'part': part,
      'orderIndex': orderIndex,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'passageId': passageId,
      'audioId': audioId,
      'metadata': metadata,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Khúc này dùng để fix lỗi ở Repository
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      examType: examType,
      skill: skill,
      questionType: questionType,
      difficulty: difficulty,
      section: section,
      part: part,
      orderIndex: orderIndex,
      questionText: questionText,
      options: options,
      correctAnswer: correctAnswer,
      correctAnswers: correctAnswers,
      explanation: explanation,
      passageId: passageId,
      audioId: audioId,
      metadata: metadata,
      isPremium: isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  
}
