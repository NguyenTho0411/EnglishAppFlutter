import 'package:cloud_firestore/cloud_firestore.dart';
import 'exam_remote_data_source.dart';
import '../models/question_model.dart';
import '../models/test_attempt_model.dart';
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/toeic_part.dart' hide ToeicPart;
import '../services/openai_service.dart';

// Biến nó thành một Class kế thừa
class ToeicRemoteDataSource extends ExamRemoteDataSource {
  // Khởi tạo và truyền firestore lên class cha
  ToeicRemoteDataSource(super.firestore);
  

  /// Lấy câu hỏi theo TOEIC Part
  Future<List<QuestionModel>> getQuestionsByToeicPart({
    required ToeicPart part,
    DifficultyLevel? difficulty,
    int? limit,
  }) async {
    Query query = firestore
        .collection('questions')
        .where('examType', isEqualTo: 'toeic')
        .where('skill', isEqualTo: part.skill.name)
        .where('toeicPart', isEqualTo: part.partNumber);

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    query = query.orderBy('orderIndex');

    if (limit != null) query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }

  /// Nộp và chấm điểm TOEIC Listening
  Future<Map<String, dynamic>> submitToeicListening({
    required String attemptId,
    required String userId,
    required Map<String, UserAnswerModel> answers,
  }) async {
    // Vì kế thừa nên bạn gọi được các hàm của class cha như getTestAttempt
    final attempt = await getTestAttempt(attemptId);
    
    int correctCount = 0;
    int totalTimeSpent = 0;
    
    for (var entry in answers.entries) {
      final userAnswer = entry.value;
      if (userAnswer.isCorrect) correctCount++;
      totalTimeSpent += userAnswer.timeSpentSeconds;
    }

    final totalQuestions = answers.length;
    final rawScore = correctCount;
    final scaledScore = _convertToToeicScore(rawScore, totalQuestions);
    final accuracy = (totalQuestions > 0) ? (correctCount / totalQuestions * 100) : 0.0;

    final partStats = await _calculatePartStats(answers, SkillType.listening);

    Map<String, dynamic>? aiFeedback;
    try {
      aiFeedback = await OpenAIService().analyzeToeicPerformance(
        skill: SkillType.listening,
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        partStats: partStats,
      );
    } catch (e) { print('AI Error: $e'); }

    final updatedAttempt = attempt.copyWith(
      isCompleted: false,
      completedAt: DateTime.now(),
      answers: answers,
      sectionScores: {
        ...attempt.sectionScores,
        SkillType.listening: SectionScoreModel(
          skill: SkillType.listening,
          totalQuestions: totalQuestions,
          correctAnswers: correctCount,
          accuracy: accuracy,
          rawScore: rawScore,
          bandScore: scaledScore.toDouble(),
          timeSpentSeconds: totalTimeSpent,
        ),
      },
      totalScore: scaledScore.toDouble(),
      accuracyRate: accuracy,
    );

    await saveTestAttempt(TestAttemptModel.fromEntity(updatedAttempt));
    
    return {
      'attemptId': attemptId,
      'scaledScore': scaledScore,
      'rawScore': rawScore,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'partStats': partStats,
      'aiFeedback': aiFeedback,
    };
  }

Future<Map<String, dynamic>> getToeicStatistics(String userId) async {
    // 1. Lấy dữ liệu từ các bài thi Full Test
    final attempts = await getUserTestAttempts(
      userId: userId,
      examType: ExamType.toeic,
      isCompleted: true,
    );

    // 2. Lấy dữ liệu từ các bài luyện tập lẻ (Practice)
    final practiceSnap = await firestore
        .collection('practice_results')
        .where('userId', isEqualTo: userId)
        .get();

    // Tính toán số liệu từ Full Tests
    final fullScores = attempts.map((a) => a.totalScore).toList();
    
    // Tính toán số liệu từ Practice
    final practiceAccuracies = practiceSnap.docs
        .map((doc) => (doc.data()['accuracy'] as num).toDouble())
        .toList();

    // Logic tính Best Score (ví dụ lấy từ Full Test cao nhất)
    final bestScore = fullScores.isEmpty 
        ? 0 
        : fullScores.reduce((a, b) => a > b ? a : b).round();

    // Logic tính trung bình Accuracy (kết hợp cả hai hoặc tùy bạn chọn)
    double totalAcc = 0;
    if (practiceAccuracies.isNotEmpty) {
      totalAcc = practiceAccuracies.reduce((a, b) => a + b) / practiceAccuracies.length;
    }

    return {
      'totalAttempts': attempts.length,
      'totalPracticeSessions': practiceSnap.docs.length,
      'averageScore': fullScores.isEmpty ? 0 : (fullScores.reduce((a, b) => a + b) / fullScores.length).round(),
      'bestScore': bestScore,
      'averageAccuracy': totalAcc.round(), // Con số này dùng cho biểu đồ tròn %
    };
  }
  
  

  Future<Map<String, dynamic>> submitToeicReading({
    required String attemptId,
    required String userId,
    required Map<String, UserAnswerModel> answers,
  }) async {
    // Logic tương tự Listening nhưng dành cho Reading
    // Bạn hãy paste logic Reading của bạn vào đây
    return {'status': 'success'};
  }

  // ... (Bạn paste nốt submitToeicReading và getToeicStatistics vào đây)

  // ==================== PRIVATE HELPERS ====================
  // Giữ các hàm helper chấm điểm ở đây để class gọn gàng
  int _convertToToeicScore(int correctAnswers, int totalQuestions) {
    // Logic chấm điểm của bạn...
    return 10; 
  }

  Future<Map<String, Map<String, dynamic>>> _calculatePartStats(
    Map<String, UserAnswerModel> answers,
    SkillType skill,
  ) async {
    // Logic tính stats...
    return {};
  }
/// Lưu kết quả luyện tập lẻ (theo Part)
  Future<void> savePracticeResult({
    required String userId,
    required String skill,
    required int correctCount,
    required int totalCount,
    required int timeSpentSeconds,
    int? partNumber,
  }) async {
    await firestore.collection('practice_results').add({
      'userId': userId,
      'skill': skill,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'accuracy': totalCount > 0 ? (correctCount / totalCount * 100).round() : 0,
      'timeSpentSeconds': timeSpentSeconds,
      'partNumber': partNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  
}