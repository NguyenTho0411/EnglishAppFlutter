import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audio_entity.dart';
import '../../domain/entities/exam_type.dart';

class AudioModel extends AudioEntity {
  const AudioModel({
    required super.id,
    required super.examType,
    required super.title,
    required super.audioUrl,
    required super.duration,
    required super.transcript,
    super.segments,
    required super.difficulty,
    required super.topic,
    super.tags,
    required super.section,
    super.isPremium,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AudioModel.fromEntity(AudioEntity entity) {
    return AudioModel(
      id: entity.id,
      examType: entity.examType,
      title: entity.title,
      audioUrl: entity.audioUrl,
      duration: entity.duration,
      transcript: entity.transcript,
      segments: entity.segments,
      difficulty: entity.difficulty,
      topic: entity.topic,
      tags: entity.tags,
      section: entity.section,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory AudioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AudioModel(
      id: doc.id,
      examType: ExamType.values.firstWhere((e) => e.code == data['examType']),
      title: data['title'] as String,
      audioUrl: data['audioUrl'] as String,
      duration: data['duration'] as int,
      transcript: data['transcript'] as String,
      segments: (data['segments'] as List?)
              ?.map((s) => TranscriptSegmentModel.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      difficulty: DifficultyLevel.values.firstWhere((e) => e.name == data['difficulty']),
      topic: data['topic'] as String,
      tags: List<String>.from(data['tags'] ?? []),
      section: data['section'] as String,
      isPremium: data['isPremium'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examType': examType.code,
      'title': title,
      'audioUrl': audioUrl,
      'duration': duration,
      'transcript': transcript,
      'segments': segments.map((s) => TranscriptSegmentModel.fromEntity(s).toMap()).toList(),
      'difficulty': difficulty.name,
      'topic': topic,
      'tags': tags,
      'section': section,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class TranscriptSegmentModel extends TranscriptSegment {
  const TranscriptSegmentModel({
    required super.startTime,
    required super.endTime,
    required super.text,
    super.speaker,
  });

  factory TranscriptSegmentModel.fromEntity(TranscriptSegment entity) {
    return TranscriptSegmentModel(
      startTime: entity.startTime,
      endTime: entity.endTime,
      text: entity.text,
      speaker: entity.speaker,
    );
  }

  factory TranscriptSegmentModel.fromMap(Map<String, dynamic> map) {
    return TranscriptSegmentModel(
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      text: map['text'] as String,
      speaker: map['speaker'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
      'speaker': speaker,
    };
  }
}
