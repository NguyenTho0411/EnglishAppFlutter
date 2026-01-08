import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/passage_entity.dart';
import '../../domain/entities/exam_type.dart';

class PassageModel extends PassageEntity {
  const PassageModel({
    required super.id,
    required super.examType,
    required super.title,
    required super.content,
    required super.wordCount,
    required super.difficulty,
    required super.topic,
    super.tags,
    required super.estimatedReadingTime,
    super.isPremium,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PassageModel.fromEntity(PassageEntity entity) {
    return PassageModel(
      id: entity.id,
      examType: entity.examType,
      title: entity.title,
      content: entity.content,
      wordCount: entity.wordCount,
      difficulty: entity.difficulty,
      topic: entity.topic,
      tags: entity.tags,
      estimatedReadingTime: entity.estimatedReadingTime,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PassageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    T safeEnum<T>(List<T> values, bool Function(T) test, T defaultValue) {
      try {
        return values.firstWhere(test, orElse: () => defaultValue);
      } catch (_) {
        return defaultValue;
      }
    }
    
    return PassageModel(
      id: doc.id,
      examType: safeEnum(
        ExamType.values, 
        (e) => e.code == data['examType'], 
        ExamType.toeic
      ),
      title: data['title'] as String? ?? 'Untitled',
      content: data['content'] as String? ?? '',
      wordCount: data['wordCount'] as int? ?? 0,
difficulty: safeEnum(
  DifficultyLevel.values,
  (e) => e.name.toLowerCase() ==
      (data['difficulty'] as String? ?? '').toLowerCase(),
  DifficultyLevel.intermediate,
),

      topic: data['topic'] as String? ?? 'General',
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      estimatedReadingTime: data['estimatedReadingTime'] as int? ?? 0,
      isPremium: data['isPremium'] as bool? ?? false,
      
     createdAt: data['createdAt'] == null
    ? DateTime.fromMillisecondsSinceEpoch(0)
    : (data['createdAt'] as Timestamp).toDate(),
updatedAt: data['updatedAt'] == null
    ? DateTime.fromMillisecondsSinceEpoch(0)
    : (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examType': examType.code,
      'title': title,
      'content': content,
      'wordCount': wordCount,
      'difficulty': difficulty.name,
      'topic': topic,
      'tags': tags,
      'estimatedReadingTime': estimatedReadingTime,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
