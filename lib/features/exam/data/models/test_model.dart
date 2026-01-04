import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/entities/exam_type.dart';

class TestModel extends TestEntity {
  const TestModel({
    required super.id,
    required super.examType,
    required super.title,
    required super.description,
    required super.sections,
    required super.totalQuestions,
    required super.totalTimeLimit,
    required super.difficulty,
    required super.isPremium,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TestModel.fromEntity(TestEntity entity) {
    return TestModel(
      id: entity.id,
      examType: entity.examType,
      title: entity.title,
      description: entity.description,
      sections: entity.sections,
      totalQuestions: entity.totalQuestions,
      totalTimeLimit: entity.totalTimeLimit,
      difficulty: entity.difficulty,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory TestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TestModel(
      id: doc.id,
      examType: ExamType.fromCode(data['examType'] as String),
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      sections: (data['sections'] as List<dynamic>)
          .map((s) => TestSectionModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      totalQuestions: data['totalQuestions'] as int,
      totalTimeLimit: data['totalTimeLimit'] as int,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => DifficultyLevel.intermediate,
      ),
      isPremium: data['isPremium'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examType': examType.code,
      'title': title,
      'description': description,
      'sections': sections.map((s) => TestSectionModel.fromEntity(s).toMap()).toList(),
      'totalQuestions': totalQuestions,
      'totalTimeLimit': totalTimeLimit,
      'difficulty': difficulty.name,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class TestSectionModel extends TestSection {
  const TestSectionModel({
    required super.id,
    required super.skill,
    required super.title,
    required super.questionIds,
    required super.timeLimit,
    required super.orderIndex,
  });

  factory TestSectionModel.fromEntity(TestSection entity) {
    return TestSectionModel(
      id: entity.id,
      skill: entity.skill,
      title: entity.title,
      questionIds: entity.questionIds,
      timeLimit: entity.timeLimit,
      orderIndex: entity.orderIndex,
    );
  }

  factory TestSectionModel.fromMap(Map<String, dynamic> map) {
    return TestSectionModel(
      id: map['id'] as String,
      skill: SkillType.values.firstWhere(
        (e) => e.name == map['skill'],
        orElse: () => SkillType.reading,
      ),
      title: map['title'] as String,
      questionIds: List<String>.from(map['questionIds'] as List),
      timeLimit: map['timeLimit'] as int,
      orderIndex: map['orderIndex'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skill': skill.name,
      'title': title,
      'questionIds': questionIds,
      'timeLimit': timeLimit,
      'orderIndex': orderIndex,
    };
  }
}
