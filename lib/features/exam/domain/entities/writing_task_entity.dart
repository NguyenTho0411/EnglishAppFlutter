import 'package:equatable/equatable.dart';

class WritingTaskEntity extends Equatable {
  final String id;
  final int taskNumber; // 1 or 2
  final String prompt;
  final String? chartImageUrl; // For Task 1
  final int minimumWords;
  final List<String> assessmentCriteria; // Task Achievement, Coherence, Lexical Resource, Grammar
  final int orderIndex;

  const WritingTaskEntity({
    required this.id,
    required this.taskNumber,
    required this.prompt,
    this.chartImageUrl,
    required this.minimumWords,
    required this.assessmentCriteria,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [
        id,
        taskNumber,
        prompt,
        chartImageUrl,
        minimumWords,
        assessmentCriteria,
        orderIndex,
      ];
}
