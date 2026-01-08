// // ============================================
// // CÁCH SỬ DỤNG QuestionModel HIỆN TẠI CHO TOEIC
// // ============================================

// import 'package:cloud_firestore/cloud_firestore.dart';
// import "..//models/question_model.dart";
// import '../../domain/entities/exam_type.dart';


// // ================================
// extension QuestionModelToeicExtensions on QuestionModel {
//   /// Check if this is a TOEIC question
//   bool get isToeicQuestion => examType == ExamType.toeic;

//   /// Get TOEIC part (1-7)
//   ToeicPart? get toeicPart {
//     if (!isToeicQuestion) return null;
//     return ToeicPart.fromNumber(part);
//   }

//   /// Get grammar point (for Part 5, 6)
//   String? get grammarPoint => metadata?['grammarPoint'] as String?;

//   /// Get passage type (for Part 7: email, article, notice, etc.)
//   String? get passageType => metadata?['passageType'] as String?;

//   /// Get keywords/tags
//   List<String>? get keywords {
//     final tags = metadata?['keywords'];
//     if (tags == null) return null;
//     return List<String>.from(tags);
//   }

//   /// Check if this question has an image (Part 1)
//   bool get hasImage => metadata?['imageUrl'] != null;

//   /// Get image URL (for Part 1)
//   String? get imageUrl => metadata?['imageUrl'] as String?;

//   /// Get question text for options (Part 7)
//   Map<String, String>? get optionsText {
//     final optText = metadata?['optionsText'];
//     if (optText == null) return null;
//     return Map<String, String>.from(optText);
//   }
// }

// // 3️⃣ VÍ DỤ TẠO QUESTIONS CHO TỪNG PART
// // ================================

// class ToeicQuestionExamples {
  
//   /// PART 1: Photographs
//   static Map<String, dynamic> createPart1Question({
//     required int orderIndex,
//     required String imageUrl,
//     required String audioId,
//     required List<String> options,
//     required String correctAnswer,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.listening.name,
//       'section': 'listening',
//       'part': 1,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicPhotographs.displayName,
//       'questionText': '', // Part 1 không có text, chỉ có audio
//       'options': options, // ['A', 'B', 'C', 'D']
//       'correctAnswer': correctAnswer,
//       'explanation': 'The correct answer shows what is happening in the photo.',
//       'audioId': audioId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'imageUrl': imageUrl,
//         'optionsText': {
//           'A': 'The man is sitting at a desk.',
//           'B': 'The woman is standing near a window.',
//           'C': 'They are walking together.',
//           'D': 'The room is empty.'
//         },
//         'keywords': ['describing pictures', 'present continuous'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 2: Question-Response
//   static Map<String, dynamic> createPart2Question({
//     required int orderIndex,
//     required String audioId,
//     required List<String> options,
//     required String correctAnswer,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.listening.name,
//       'section': 'listening',
//       'part': 2,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicQuestionResponse.displayName,
//       'questionText': '', // Chỉ có audio
//       'options': options, // ['A', 'B', 'C']
//       'correctAnswer': correctAnswer,
//       'explanation': 'This is the most appropriate response to the question.',
//       'audioId': audioId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'transcript': {
//           'question': 'When is the meeting?',
//           'A': 'At 3 o\'clock.',
//           'B': 'In the conference room.',
//           'C': 'Yes, I will attend.'
//         },
//         'keywords': ['wh-questions', 'time expressions'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 3: Conversations
//   static Map<String, dynamic> createPart3Question({
//     required int orderIndex,
//     required String audioId,
//     required String questionText,
//     required List<String> options,
//     required String correctAnswer,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.listening.name,
//       'section': 'listening',
//       'part': 3,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicConversations.displayName,
//       'questionText': questionText, // "What does the woman suggest?"
//       'options': options, // ['A', 'B', 'C', 'D']
//       'correctAnswer': correctAnswer,
//       'explanation': 'The woman suggests this in the conversation.',
//       'audioId': audioId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'conversationType': 'workplace_discussion',
//         'transcript': 'Man: We need to finish this by Friday...',
//         'keywords': ['suggestions', 'workplace', 'time management'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 4: Talks
//   static Map<String, dynamic> createPart4Question({
//     required int orderIndex,
//     required String audioId,
//     required String questionText,
//     required List<String> options,
//     required String correctAnswer,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.listening.name,
//       'section': 'listening',
//       'part': 4,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicTalks.displayName,
//       'questionText': questionText, // "What is the main purpose of the talk?"
//       'options': options,
//       'correctAnswer': correctAnswer,
//       'explanation': 'The speaker\'s main purpose is clearly stated.',
//       'audioId': audioId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'talkType': 'announcement', // announcement, advertisement, news
//         'transcript': 'Good morning, everyone. I\'d like to announce...',
//         'keywords': ['announcements', 'main idea', 'listening for purpose'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 5: Incomplete Sentences (Grammar)
//   static Map<String, dynamic> createPart5Question({
//     required int orderIndex,
//     required String questionText,
//     required List<String> options,
//     required String correctAnswer,
//     required String grammarPoint,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.reading.name,
//       'section': 'reading',
//       'part': 5,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicIncompleteSentences.displayName,
//       'questionText': questionText, // "The company _____ a new policy next month."
//       'options': options, // ['implement', 'implements', 'will implement', 'implementing']
//       'correctAnswer': correctAnswer, // "will implement"
//       'explanation': 'Future tense is needed because of "next month".',
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'grammarPoint': grammarPoint, // "future_tense"
//         'optionsText': {
//           'A': 'implement',
//           'B': 'implements',
//           'C': 'will implement',
//           'D': 'implementing'
//         },
//         'keywords': ['grammar', 'future tense', 'time expressions'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 6: Text Completion
//   static Map<String, dynamic> createPart6Question({
//     required int orderIndex,
//     required String passageId,
//     required String questionText,
//     required List<String> options,
//     required String correctAnswer,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.reading.name,
//       'section': 'reading',
//       'part': 6,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicTextCompletion.displayName,
//       'questionText': questionText, // Sentence với blank
//       'options': options,
//       'correctAnswer': correctAnswer,
//       'explanation': 'This option fits the context of the passage.',
//       'passageId': passageId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'grammarPoint': 'context_clues',
//         'keywords': ['text completion', 'context', 'grammar in context'],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   /// PART 7: Reading Comprehension
//   static Map<String, dynamic> createPart7Question({
//     required int orderIndex,
//     required String passageId,
//     required String questionText,
//     required List<String> options,
//     required String correctAnswer,
//     required String passageType,
//   }) {
//     return {
//       'examType': ExamType.toeic.code,
//       'skill': SkillType.reading.name,
//       'section': 'reading',
//       'part': 7,
//       'orderIndex': orderIndex,
//       'questionType': QuestionType.toeicReadingComprehension.displayName,
//       'questionText': questionText, // "What is the main purpose of the email?"
//       'options': options,
//       'correctAnswer': correctAnswer,
//       'explanation': 'The passage clearly indicates this.',
//       'passageId': passageId,
//       'difficulty': DifficultyLevel.intermediate.name,
//       'metadata': {
//         'passageType': passageType, // 'email', 'article', 'notice', 'advertisement'
//         'questionType': 'main_idea', // main_idea, detail, inference, vocabulary
//         'keywords': ['reading comprehension', 'main idea', passageType],
//       },
//       'isPremium': false,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }
// }

// // 4️⃣ CÁCH SỬ DỤNG TRONG CODE
// // ================================

// class ToeicQuestionUsageExample {
//   final FirebaseFirestore firestore;

//   ToeicQuestionUsageExample(this.firestore);

//   /// Tạo TOEIC Part 5 question
//   Future<void> createPart5Example() async {
//     final questionData = ToeicQuestionExamples.createPart5Question(
//       orderIndex: 101,
//       questionText: 'The project must be completed _____ the end of the month.',
//       options: ['by', 'until', 'on', 'at'],
//       correctAnswer: 'by',
//       grammarPoint: 'prepositions_time',
//     );

//     await firestore.collection('questions').add(questionData);
//   }

//   /// Lấy questions theo TOEIC part
//   Future<List<QuestionModel>> getQuestionsByPart(int partNumber) async {
//     final snapshot = await firestore
//         .collection('questions')
//         .where('examType', isEqualTo: ExamType.toeic.code)
//         .where('part', isEqualTo: partNumber)
//         .orderBy('orderIndex')
//         .limit(30)
//         .get();

//     return snapshot.docs
//         .map((doc) => QuestionModel.fromFirestore(doc))
//         .toList();
//   }

//   /// Lấy TOEIC Reading questions (Part 5, 6, 7)
//   Future<List<QuestionModel>> getToeicReadingQuestions() async {
//     final snapshot = await firestore
//         .collection('questions')
//         .where('examType', isEqualTo: ExamType.toeic.code)
//         .where('skill', isEqualTo: SkillType.reading.name)
//         .orderBy('part')
//         .orderBy('orderIndex')
//         .get();

//     return snapshot.docs
//         .map((doc) => QuestionModel.fromFirestore(doc))
//         .toList();
//   }

//   /// Sử dụng extension methods
//   void useQuestionExtensions(QuestionModel question) {
//     if (question.isToeicQuestion) {
//       print('TOEIC Part: ${question.toeicPart?.title}');
//       print('Grammar Point: ${question.grammarPoint}');
//       print('Passage Type: ${question.passageType}');
//       print('Has Image: ${question.hasImage}');
//       print('Keywords: ${question.keywords}');
//     }
//   }
// }

// // 5️⃣ FILTER QUESTIONS BY TOEIC PART
// // ================================

// extension ToeicQuestionFilters on List<QuestionModel> {
//   /// Filter by TOEIC part
//   List<QuestionModel> byToeicPart(int partNumber) {
//     return where((q) => q.part == partNumber && q.examType == ExamType.toeic)
//         .toList();
//   }

//   /// Get only listening questions
//   List<QuestionModel> get listeningQuestions {
//     return where((q) => 
//       q.examType == ExamType.toeic && 
//       q.skill == SkillType.listening
//     ).toList();
//   }

//   /// Get only reading questions
//   List<QuestionModel> get readingQuestions {
//     return where((q) => 
//       q.examType == ExamType.toeic && 
//       q.skill == SkillType.reading
//     ).toList();
//   }

//   /// Get questions by grammar point (Part 5, 6)
//   List<QuestionModel> byGrammarPoint(String grammarPoint) {
//     return where((q) => 
//       q.metadata?['grammarPoint'] == grammarPoint
//     ).toList();
//   }

//   /// Get questions by passage type (Part 7)
//   List<QuestionModel> byPassageType(String passageType) {
//     return where((q) => 
//       q.metadata?['passageType'] == passageType
//     ).toList();
//   }
// }