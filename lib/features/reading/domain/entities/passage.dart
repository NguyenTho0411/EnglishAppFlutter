class Passage {
  final String id;
  final String title;
  final int orderIndex;
  final String content;
  final List<Question> questions;

  Passage({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.content,
    required this.questions,
  });

  factory Passage.fromJson(Map<String, dynamic> json) {
    return Passage(
      id: json['id'],
      title: json['title'],
      orderIndex: json['orderIndex'],
      content: json['content'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String type;
  final int orderIndex;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      orderIndex: json['orderIndex'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}