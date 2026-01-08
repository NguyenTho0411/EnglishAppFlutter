
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/question_model.dart';
// import '../models/test_attempt_model.dart';
// import '../../domain/entities/exam_type.dart';
// import '../services/openai_service.dart';
// import '..///data_sources/exam_remote_data_source.dart';
// import '..//models/question_model_extentions.dart';
// extension ToeicDataSource on ExamRemoteDataSource {
  
//   /// Lấy câu hỏi theo TOEIC Part
//   Future<List<QuestionModel>> getQuestionsByToeicPart({
//     required ToeicPart part,
//     DifficultyLevel? difficulty,
//     int? limit,
//   }) async {
//     Query query = firestore
//         .collection('questions')
//         .where('examType', isEqualTo: 'toeic')
//         .where('skill', isEqualTo: part.skill.name)
//         .where('toeicPart', isEqualTo: part.partNumber);

//     if (difficulty != null) {
//       query = query.where('difficulty', isEqualTo: difficulty.name);
//     }

//     query = query.orderBy('orderIndex');

//     if (limit != null) {
//       query = query.limit(limit);
//     }

//     final snapshot = await query.get();
//     return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
//   }

// /// Nộp và chấm điểm TOEIC Listening
//   Future<Map<String, dynamic>> submitToeicListening({
//     required String attemptId,
//     required String userId,
//     required Map<String, UserAnswerModel> answers,
//   }) async {
//     final attempt = await getTestAttempt(attemptId);
    
//     int correctCount = 0;
//     int totalTimeSpent = 0; // Thêm biến tính tổng thời gian
    
//     for (var entry in answers.entries) {
//       final userAnswer = entry.value;
//       if (userAnswer.isCorrect) correctCount++;
//       totalTimeSpent += userAnswer.timeSpentSeconds; // Cộng dồn thời gian
//     }

//     final totalQuestions = answers.length;
//     final rawScore = correctCount;
//     final scaledScore = _convertToToeicScore(rawScore, totalQuestions);
//     final accuracy = (totalQuestions > 0) ? (correctCount / totalQuestions * 100) : 0.0;

//     final partStats = await _calculatePartStats(answers, SkillType.listening);

//     Map<String, dynamic>? aiFeedback;
//     try {
//       aiFeedback = await OpenAIService().analyzeToeicPerformance(
//         skill: SkillType.listening,
//         correctCount: correctCount,
//         totalQuestions: totalQuestions,
//         partStats: partStats,
//       );
//     } catch (e) { print('AI Error: $e'); }

//     // Cập nhật attempt theo Model mới
//     final updatedAttempt = attempt.copyWith(
//       isCompleted: false, // Thường Listening xong vẫn còn Reading nên chưa Complete hẳn
//       completedAt: DateTime.now(),
//       answers: answers,
//       sectionScores: {
//         ...attempt.sectionScores,
//         // Dùng enum SkillType.listening làm key và truyền đầy đủ tham số
//         SkillType.listening: SectionScoreModel(
//           skill: SkillType.listening,
//           totalQuestions: totalQuestions,
//           correctAnswers: correctCount,
//           accuracy: accuracy,
//           rawScore: rawScore,
//           bandScore: scaledScore.toDouble(), // TOEIC Scaled Score map vào bandScore
//           timeSpentSeconds: totalTimeSpent, // Tham số mới thêm vào cuối
//         ),
//       },
//       totalScore: scaledScore.toDouble(),
//       accuracyRate: accuracy,
//     );

//     await saveTestAttempt(TestAttemptModel.fromEntity(updatedAttempt));
    
//     return {
//       'attemptId': attemptId,
//       'scaledScore': scaledScore,
//       'rawScore': rawScore,
//       'totalQuestions': totalQuestions,
//       'accuracy': accuracy,
//       'partStats': partStats,
//       'aiFeedback': aiFeedback,
//     };
//   }


//   /// Nộp và chấm điểm TOEIC Reading
//   Future<Map<String, dynamic>> submitToeicReading({
//     required String attemptId,
//     required String userId,
//     required Map<String, UserAnswerModel> answers,
//   }) async {
//     // 1. Lấy dữ liệu bài làm hiện tại
//     final attempt = await getTestAttempt(attemptId);
    
//     // 2. Tính toán kết quả Reading
//     int correctCount = 0;
//     int totalTimeSpent = 0;
    
//     for (var entry in answers.entries) {
//       final userAnswer = entry.value;
//       if (userAnswer.isCorrect) correctCount++;
//       totalTimeSpent += userAnswer.timeSpentSeconds;
//     }

//     final totalQuestions = answers.length;
//     final rawScore = correctCount;
//     final scaledScore = _convertToToeicScore(rawScore, totalQuestions);
//     final accuracy = (totalQuestions > 0) ? (correctCount / totalQuestions * 100) : 0.0;

//     // 3. Tính thống kê chi tiết theo Part
//     final partStats = await _calculatePartStats(answers, SkillType.reading);

//     // 4. Gọi OpenAI phân tích kết quả Reading
//     Map<String, dynamic>? aiFeedback;
//     try {
//       final openAIService = OpenAIService();
//       aiFeedback = await openAIService.analyzeToeicPerformance(
//         skill: SkillType.reading,
//         correctCount: correctCount,
//         totalQuestions: totalQuestions,
//         partStats: partStats,
//       );
//     } catch (e) {
//       print('AI Error Reading: $e');
//     }

//     // 5. Tính toán tổng điểm cuối cùng
//     final listeningScore = attempt.sectionScores[SkillType.listening]?.bandScore ?? 0.0;
//     final finalTotalScore = listeningScore + scaledScore;

//     // 6. Cập nhật đối tượng Attempt
//     final updatedAttempt = attempt.copyWith(
//       isCompleted: true, // Đã hoàn thành cả bài thi
//       completedAt: DateTime.now(),
//       answers: {...attempt.answers, ...answers}, // Gộp đáp án của cả Listening và Reading
//       sectionScores: {
//         ...attempt.sectionScores,
//         SkillType.reading: SectionScoreModel(
//           skill: SkillType.reading,
//           totalQuestions: totalQuestions,
//           correctAnswers: correctCount,
//           accuracy: accuracy,
//           rawScore: rawScore,
//           bandScore: scaledScore.toDouble(),
//           timeSpentSeconds: totalTimeSpent, // Tham số thêm vào cuối
//         ),
//       },
//       totalScore: finalTotalScore,
//       accuracyRate: (attempt.sectionScores.containsKey(SkillType.listening)) 
//           ? (attempt.accuracyRate + accuracy) / 2 
//           : accuracy,
//     );

//     // 7. Lưu vào Firestore (Cast từ Entity sang Model)
//     await saveTestAttempt(TestAttemptModel.fromEntity(updatedAttempt));

//     // 8. Trả về kết quả cho UI
//     return {
//       'attemptId': attemptId,
//       'scaledScore': scaledScore,
//       'rawScore': rawScore,
//       'totalQuestions': totalQuestions,
//       'accuracy': accuracy,
//       'partStats': partStats,
//       'aiFeedback': aiFeedback,
//     };
//   }

//  /// Nộp full TOEIC test (cả Listening và Reading)
//   Future<Map<String, dynamic>> submitFullToeicTest({
//     required String attemptId,
//     required String userId,
//   }) async {
//     final attempt = await getTestAttempt(attemptId);
    
//     if (!attempt.isCompleted) {
//       throw Exception('Test not completed yet');
//     }

//     // Sửa lỗi: Dùng SkillType enum làm key và bandScore làm giá trị điểm
//     final listeningScore = attempt.sectionScores[SkillType.listening]?.bandScore ?? 0.0;
//     final readingScore = attempt.sectionScores[SkillType.reading]?.bandScore ?? 0.0;
    
//     final totalScore = listeningScore + readingScore;

//     // Cập nhật tiến trình học tập của User
//     await _updateToeicProgress(
//       userId: userId,
//       totalScore: totalScore.toInt(),
//       listeningScore: listeningScore.toInt(),
//       readingScore: readingScore.toInt(),
//     );

//     return {
//       'attemptId': attemptId,
//       'listeningScore': listeningScore,
//       'readingScore': readingScore,
//       'totalScore': totalScore,
//       'attempt': attempt,
//     };
//   }

//   /// Lấy thống kê TOEIC của user
//   Future<Map<String, dynamic>> getToeicStatistics(String userId) async {
//     final attempts = await getUserTestAttempts(
//       userId: userId,
//       examType: ExamType.toeic,
//       isCompleted: true,
//     );

//     if (attempts.isEmpty) {
//       return {
//         'totalAttempts': 0,
//         'averageScore': 0,
//         'bestScore': 0,
//         'latestScore': 0,
//         'improvement': 0,
//         'listeningAverage': 0,
//         'readingAverage': 0,
//       };
//     }

//     // 1. Tính toán thống kê tổng quát
//     final scores = attempts.map((a) => a.totalScore).toList();
//     final avgScore = scores.reduce((a, b) => a + b) / scores.length;
//     final bestScore = scores.reduce((a, b) => a > b ? a : b);
//     final latestScore = scores.first; // Giả định list đã được sort theo thời gian mới nhất
//     final improvement = scores.length > 1 ? latestScore - scores.last : 0;

//     // 2. Tính điểm trung bình theo từng phần (Listening / Reading)
//     double listeningAvg = 0;
//     double readingAvg = 0;
//     int listeningCount = 0;
//     int readingCount = 0;

//     for (var attempt in attempts) {
//       // SỬA LỖI: Dùng SkillType.listening thay vì 'listening'
//       if (attempt.sectionScores.containsKey(SkillType.listening)) {
//         // SỬA LỖI: Dùng .bandScore thay vì .scaledScore
//         listeningAvg += attempt.sectionScores[SkillType.listening]!.bandScore;
//         listeningCount++;
//       }
      
//       // SỬA LỖI: Dùng SkillType.reading thay vì 'reading'
//       if (attempt.sectionScores.containsKey(SkillType.reading)) {
//         // SỬA LỖI: Dùng .bandScore thay vì .scaledScore
//         readingAvg += attempt.sectionScores[SkillType.reading]!.bandScore;
//         readingCount++;
//       }
//     }

//     if (listeningCount > 0) listeningAvg /= listeningCount;
//     if (readingCount > 0) readingAvg /= readingCount;

//     return {
//       'totalAttempts': attempts.length,
//       'averageScore': avgScore.round(),
//       'bestScore': bestScore.round(),
//       'latestScore': latestScore.round(),
//       'improvement': improvement.round(),
//       'listeningAverage': listeningAvg.round(),
//       'readingAverage': readingAvg.round(),
//       'recentAttempts': attempts.take(5).toList(),
//       'scoreHistory': scores,
//     };
//   }
//   // ==================== PRIVATE HELPERS ====================

//   /// Convert raw score to TOEIC scaled score (0-495)
//   int _convertToToeicScore(int correctAnswers, int totalQuestions) {
//     if (totalQuestions == 0) return 0;
    
//     // TOEIC conversion table approximation
//     // Actual TOEIC uses complex conversion table, this is simplified
//     final percentage = correctAnswers / totalQuestions;
    
//     if (percentage >= 0.96) return 495;
//     if (percentage >= 0.92) return 475;
//     if (percentage >= 0.88) return 455;
//     if (percentage >= 0.84) return 435;
//     if (percentage >= 0.80) return 415;
//     if (percentage >= 0.76) return 395;
//     if (percentage >= 0.72) return 375;
//     if (percentage >= 0.68) return 355;
//     if (percentage >= 0.64) return 335;
//     if (percentage >= 0.60) return 315;
//     if (percentage >= 0.56) return 295;
//     if (percentage >= 0.52) return 275;
//     if (percentage >= 0.48) return 255;
//     if (percentage >= 0.44) return 235;
//     if (percentage >= 0.40) return 215;
//     if (percentage >= 0.36) return 195;
//     if (percentage >= 0.32) return 175;
//     if (percentage >= 0.28) return 155;
//     if (percentage >= 0.24) return 135;
//     if (percentage >= 0.20) return 115;
//     if (percentage >= 0.16) return 95;
//     if (percentage >= 0.12) return 75;
//     if (percentage >= 0.08) return 55;
//     if (percentage >= 0.04) return 35;
//     return 10;
//   }

//   /// Tính toán thống kê theo từng part
//   Future<Map<String, Map<String, dynamic>>> _calculatePartStats(
//     Map<String, UserAnswerModel> answers,
//     SkillType skill,
//   ) async {
//     final Map<String, Map<String, dynamic>> partStats = {};
    
//     // Group answers by part
//     for (var entry in answers.entries) {
//       final questionId = entry.key;
//       final userAnswer = entry.value;
      
//       // Get question to determine part
//       try {
//         final question = await getQuestionById(questionId);
//         final partKey = 'part${question.toeicPart ?? 0}';
        
//         if (!partStats.containsKey(partKey)) {
//           partStats[partKey] = {
//             'correct': 0,
//             'total': 0,
//             'accuracy': 0.0,
//           };
//         }
        
//         partStats[partKey]!['total'] = (partStats[partKey]!['total'] as int) + 1;
//         if (userAnswer.isCorrect) {
//           partStats[partKey]!['correct'] = (partStats[partKey]!['correct'] as int) + 1;
//         }
//       } catch (e) {
//         print('Error getting question $questionId: $e');
//       }
//     }
    
//     // Calculate accuracy for each part
//     partStats.forEach((key, value) {
//       final correct = value['correct'] as int;
//       final total = value['total'] as int;
//       value['accuracy'] = total > 0 ? (correct / total * 100) : 0.0;
//     });
    
//     return partStats;
//   }

//   /// Update TOEIC progress
//   Future<void> _updateToeicProgress({
//     required String userId,
//     required int totalScore,
//     required int listeningScore,
//     required int readingScore,
//   }) async {
//     final progressRef = firestore
//         .collection('user_exam_progress')
//         .doc(userId)
//         .collection('toeic_progress')
//         .doc('overall');

//     final doc = await progressRef.get();
    
//     if (doc.exists) {
//       final data = doc.data()!;
//       final attempts = (data['totalAttempts'] as int? ?? 0) + 1;
//       final currentBest = data['bestScore'] as int? ?? 0;
      
//       await progressRef.update({
//         'totalAttempts': attempts,
//         'latestScore': totalScore,
//         'bestScore': totalScore > currentBest ? totalScore : currentBest,
//         'lastPracticeDate': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } else {
//       await progressRef.set({
//         'userId': userId,
//         'totalAttempts': 1,
//         'latestScore': totalScore,
//         'bestScore': totalScore,
//         'averageScore': totalScore,
//         'listeningBest': listeningScore,
//         'readingBest': readingScore,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }
// }