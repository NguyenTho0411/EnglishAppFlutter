import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/exam/data/models/audio_model.dart';
import 'package:flutter_application_1/features/exam/data/models/passage_model.dart';
import 'package:flutter_application_1/features/exam/data/models/question_model.dart';
import 'package:flutter_application_1/features/exam/data/models/test_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

// Import các model và entity của bạn
import '../../domain/entities/exam_type.dart';
import '../../domain/entities/question_entity.dart';


class ToeicDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  Future<void> seedFullTest(String testTitle) async {
    print("🚀 Bắt đầu tạo đề thi: $testTitle...");
    
    final String testId = 'toeic_test_${DateTime.now().millisecondsSinceEpoch}';
    List<String> questionIds = [];

    // --- LISTENING (Part 1 - 4) ---
    print("📸 Creating Part 1...");
    questionIds.addAll(await _seedPart1(testId));

    print("🗣️ Creating Part 2...");
    questionIds.addAll(await _seedPart2(testId));

    print("💬 Creating Part 3...");
    questionIds.addAll(await _seedGroupedListening(testId, 3, 13));

    print("🎤 Creating Part 4...");
    questionIds.addAll(await _seedGroupedListening(testId, 4, 10));

    // --- READING (Part 5 - 7) ---
    print("📝 Creating Part 5...");
    questionIds.addAll(await _seedPart5(testId));

    print("📖 Creating Part 6...");
    questionIds.addAll(await _seedGroupedReading(testId, 6, 4, 4));

    print("📚 Creating Part 7...");
    questionIds.addAll(await _seedGroupedReading(testId, 7, 10, 3)); 
    questionIds.addAll(await _seedGroupedReading(testId, 7, 5, 5));

   print("📊 [DEBUG] Tổng số câu hỏi đã tạo: ${questionIds.length}");

    // 1. Kiểm tra số lượng câu hỏi trước khi cắt list
    if (questionIds.length < 200) {
      print("❌ [ERROR] Không đủ 200 câu hỏi! Chỉ có ${questionIds.length} câu.");
    }

    try {
      // 2. Tạo Model
      final testModel = TestModel(
        id: testId,
        examType: ExamType.toeic,
        title: testTitle,
        description: 'Đề thi mô phỏng Full Test TOEIC (200 câu). Được tạo tự động.',
        sections: [
          TestSectionModel(
            id: 'sec_listening_$testId',
            skill: SkillType.listening,
            title: 'Listening Comprehension',
            questionIds: questionIds.sublist(0, 100), // Lấy 100 câu đầu
            timeLimit: 45,
            orderIndex: 0,
          ),
          TestSectionModel(
            id: 'sec_reading_$testId',
            skill: SkillType.reading,
            title: 'Reading Comprehension',
            questionIds: questionIds.sublist(100, 200), // Lấy 100 câu sau (An toàn hơn)
            timeLimit: 75,
            orderIndex: 1,
          ),
        ],
        totalQuestions: 200,
        totalTimeLimit: 120,
        difficulty: DifficultyLevel.intermediate,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print("⏳ [DEBUG] Đang đẩy Test Model lên Firestore...");
    // Lưu Test vào Firestore
    await _firestore.collection('tests').doc(testId).set(testModel.toFirestore());

    print("✅ Đã tạo xong đề thi: $testId với ${questionIds.length} câu hỏi.");
  } catch (e) {
      print("❌ [ERROR] Lỗi khi tạo đề thi: $e");
    }
  }

  // ==========================================================
  // HELPER FUNCTIONS
  // ==========================================================

  // --- Part 1: Photographs ---
  Future<List<String>> _seedPart1(String testId) async {
    List<String> ids = [];
    for (int i = 0; i < 6; i++) {
      // 1. Tạo Audio
      final audioId = _uuid.v4();
      final audio = _createDummyAudio(audioId, "Audio for Part 1 Q${i+1}", 1);
      await _firestore.collection('audios').doc(audioId).set(audio.toFirestore());

      // 2. Tạo Question
      final qId = _uuid.v4();
      final question = _createQuestion(
        id: qId,
        skill: SkillType.listening,
        part: 1,
        index: i,
        text: "Look at the picture marked Number ${i+1} in your test book.",
        audioId: audioId,
        metadata: {
          'imageUrl': 'https://placehold.co/600x400/png?text=TOEIC+Part+1+Image+${i+1}'
        }
      );
      await _firestore.collection('questions').doc(qId).set(question.toFirestore());
      ids.add(qId);
    }
    return ids;
  }

  // --- Part 2: Question-Response ---
  Future<List<String>> _seedPart2(String testId) async {
    List<String> ids = [];
    for (int i = 0; i < 25; i++) {
      final audioId = _uuid.v4();
      final audio = _createDummyAudio(audioId, "Audio for Part 2 Q${i+7}", 2);
      await _firestore.collection('audios').doc(audioId).set(audio.toFirestore());

      final qId = _uuid.v4();
      final question = _createQuestion(
        id: qId,
        skill: SkillType.listening,
        part: 2,
        index: 6 + i, // Bắt đầu từ câu 7
        text: "Mark your answer on your answer sheet.",
        audioId: audioId,
        options: ['A', 'B', 'C'], // Part 2 chỉ có 3 đáp án
        correctAnswer: ['A', 'B', 'C'][_random.nextInt(3)],
      );
      await _firestore.collection('questions').doc(qId).set(question.toFirestore());
      ids.add(qId);
    }
    return ids;
  }

  // --- Part 3 & 4 (Grouped Listening) ---
  Future<List<String>> _seedGroupedListening(String testId, int part, int groupCount) async {
    List<String> ids = [];
    int startIndex = (part == 3) ? 32 : 71; // Part 3 bắt đầu câu 32, Part 4 câu 71

    for (int i = 0; i < groupCount; i++) {
      // 1. Tạo 1 Audio chung cho cả nhóm 3 câu
      final audioId = _uuid.v4();
      final audio = _createDummyAudio(audioId, "Conversation/Talk ${i+1} for Part $part", part);
      await _firestore.collection('audios').doc(audioId).set(audio.toFirestore());

      // 2. Tạo 3 câu hỏi liên quan đến Audio này
      for (int j = 0; j < 3; j++) {
        final qId = _uuid.v4();
        final question = _createQuestion(
          id: qId,
          skill: SkillType.listening,
          part: part,
          index: startIndex + (i * 3) + j,
          text: "What does the speaker imply about...?",
          audioId: audioId, // Link chung audioId
        );
        await _firestore.collection('questions').doc(qId).set(question.toFirestore());
        ids.add(qId);
      }
    }
    return ids;
  }

  // --- Part 5: Incomplete Sentences ---
  Future<List<String>> _seedPart5(String testId) async {
    List<String> ids = [];
    for (int i = 0; i < 30; i++) {
      final qId = _uuid.v4();
      final question = _createQuestion(
        id: qId,
        skill: SkillType.reading,
        part: 5,
        index: 101 + i, // Bắt đầu câu 101
        text: "The new employee _____ highly recommended by the manager.",
        metadata: {
          'optionsText': {
            'A': 'come',
            'B': 'comes',
            'C': 'coming',
            'D': 'came'
          }
        }
      );
      await _firestore.collection('questions').doc(qId).set(question.toFirestore());
      ids.add(qId);
    }
    return ids;
  }

  // --- Part 6 & 7 (Grouped Reading) ---
  Future<List<String>> _seedGroupedReading(String testId, int part, int groupCount, int questionsPerGroup) async {
    List<String> ids = [];
    int startIndex = (part == 6) ? 131 : 147; 
    // Lưu ý: index này chỉ là tương đối để demo, thực tế cần biến global count

    for (int i = 0; i < groupCount; i++) {
      // 1. Tạo 1 Passage chung
      final passageId = _uuid.v4();
      final passage = _createDummyPassage(passageId, "Passage for Part $part Group ${i+1}");
      await _firestore.collection('passages').doc(passageId).set(passage.toFirestore());

      // 2. Tạo các câu hỏi liên quan
      for (int j = 0; j < questionsPerGroup; j++) {
        final qId = _uuid.v4();
        final question = _createQuestion(
          id: qId,
          skill: SkillType.reading,
          part: part,
          index: 0, // Set 0 rồi sort sau hoặc dùng biến đếm toàn cục
          text: part == 6 ? "Choose the best word [___]" : "According to the passage...",
          passageId: passageId, // Link chung passageId
        );
        await _firestore.collection('questions').doc(qId).set(question.toFirestore());
        ids.add(qId);
      }
    }
    return ids;
  }

  // --- Helpers tạo Model ---

  AudioModel _createDummyAudio(String id, String title, int part) {
    return AudioModel(
      id: id,
      examType: ExamType.toeic,
      title: title,
      // URL file âm thanh mẫu (hoặc dùng link thật của bạn)
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: 120,
      transcript: "This is a transcript for $title...",
      difficulty: DifficultyLevel.intermediate,
      topic: 'Business',
      section: 'Part $part',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  PassageModel _createDummyPassage(String id, String title) {
    return PassageModel(
      id: id,
      examType: ExamType.toeic,
      title: title,
      content: """
      To: All Staff
      From: Management
      Subject: New Policy

      We are pleased to announce that starting next month, the cafeteria will be open...
      
      This change is being implemented to accommodate...
      
      Thank you,
      Management
      """,
      wordCount: 150,
      difficulty: DifficultyLevel.intermediate,
      topic: 'Business Email',
      estimatedReadingTime: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  QuestionModel _createQuestion({
    required String id,
    required SkillType skill,
    required int part,
    required int index,
    required String text,
    String? audioId,
    String? passageId,
    List<String>? options,
    String? correctAnswer,
    Map<String, dynamic>? metadata,
  }) {
    final opts = options ?? ['A', 'B', 'C', 'D'];
    final correct = correctAnswer ?? opts[_random.nextInt(opts.length)];
    
    // Nếu không có metadata (Part 6,7), tạo dummy text cho options
    final meta = metadata ?? {
      'optionsText': {
        'A': 'Option A content',
        'B': 'Option B content',
        'C': 'Option C content',
        'D': 'Option D content',
      }
    };

    return QuestionModel(
      id: id,
      examType: ExamType.toeic,
      skill: skill,
      questionType: QuestionType.multipleChoice, // Set mặc định
      difficulty: DifficultyLevel.intermediate,
      section: skill == SkillType.listening ? 'Listening' : 'Reading',
      part: part,
      orderIndex: index,
      questionText: text,
      options: opts,
      correctAnswer: correct,
      explanation: "This is the explanation for why $correct is correct.",
      audioId: audioId,
      passageId: passageId,
      metadata: meta,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}