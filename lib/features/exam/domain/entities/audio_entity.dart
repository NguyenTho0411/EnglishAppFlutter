import 'package:equatable/equatable.dart';
import 'exam_type.dart';

class AudioEntity extends Equatable {
  final String id;
  final ExamType examType;
  final String title;
  final String audioUrl; // Firebase Storage or CDN URL
  final int duration; // in seconds
  final String transcript; // Full transcript
  final List<TranscriptSegment> segments; // Timestamped segments
  final DifficultyLevel difficulty;
  final String topic;
  final List<String> tags;
  final String section; // e.g., "Section 1", "Part A"
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AudioEntity({
    required this.id,
    required this.examType,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.transcript,
    this.segments = const [],
    required this.difficulty,
    required this.topic,
    this.tags = const [],
    required this.section,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        examType,
        title,
        audioUrl,
        duration,
        transcript,
        segments,
        difficulty,
        topic,
        tags,
        section,
        isPremium,
        createdAt,
        updatedAt,
      ];
}

class TranscriptSegment extends Equatable {
  final int startTime; // in seconds
  final int endTime; // in seconds
  final String text;
  final String? speaker; // Optional speaker identification

  const TranscriptSegment({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.speaker,
  });

  @override
  List<Object?> get props => [startTime, endTime, text, speaker];
}
