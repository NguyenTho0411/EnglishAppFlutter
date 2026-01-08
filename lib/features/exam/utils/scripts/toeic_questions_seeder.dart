import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/exam/data/models/audio_model.dart';
import 'package:flutter_application_1/features/exam/domain/entities/exam_type.dart';

class ToeicQuestionSeeder {
  final FirebaseFirestore firestore;

  ToeicQuestionSeeder(this.firestore);

  Future<void> seedAllToeicQuestions() async {
    print('🚀 Starting TOEIC questions seeding...');

    try {
      await _seedPart1Questions();
      await _seedPart2Questions();
      await _seedPart3Questions();
      await _seedPart4Questions();
      await _seedPart5Questions();
      await _seedPart6Questions();
      await _seedPart7Questions();
      
      print('✅ All TOEIC questions seeded successfully!');
    } catch (e, stackTrace) {
      print('❌ Error seeding questions: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // ==================== HELPER: TẠO AUDIO ====================
  Future<String> _createAudioDirectly(String id, String title, String transcript) async {
    print('   🎵 Creating audio: $id...');
    
    final audioRef = firestore.collection('audios').doc(id);
    
    final audio = AudioModel(
      id: id,
      examType: ExamType.toeic,
      title: title,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: 30,
      transcript: transcript,
      difficulty: DifficultyLevel.intermediate,
      topic: 'General Business',
      section: 'Listening',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await audioRef.set(audio.toFirestore());
    return id;
  }

  // ==================== PART 1: PHOTOGRAPHS (5 câu) ====================
  Future<void> _seedPart1Questions() async {
    print('📸 Seeding Part 1 questions...');

    try {
      final questionsData = [
        {
          'orderIndex': 1,
          'audioId': 'audio_part1_q1',
          'audioTitle': 'Part 1 - Photo 1',
          'transcript': 'A. The woman is opening a door. B. The woman is standing near a window. C. The woman is closing a laptop. D. The woman is walking outside.',
          'imageUrl': 'https://images.unsplash.com/photo-1573164713714-d95e436ab8d6',
          'correctAnswer': 'B',
          'explanation': 'The woman is clearly standing near a window, looking outside.',
          'optionsText': {
            'A': 'The woman is opening a door.',
            'B': 'The woman is standing near a window.',
            'C': 'The woman is closing a laptop.',
            'D': 'The woman is walking outside.'
          }
        },
        {
          'orderIndex': 2,
          'audioId': 'audio_part1_q2',
          'audioTitle': 'Part 1 - Photo 2',
          'transcript': 'A. People are boarding a bus. B. The bus is being repaired. C. Passengers are getting off the bus. D. The bus driver is resting.',
          'imageUrl': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
          'correctAnswer': 'A',
          'explanation': 'Multiple people are clearly boarding the bus through the front door.',
          'optionsText': {
            'A': 'People are boarding a bus.',
            'B': 'The bus is being repaired.',
            'C': 'Passengers are getting off the bus.',
            'D': 'The bus driver is resting.'
          }
        },
        {
          'orderIndex': 3,
          'audioId': 'audio_part1_q3',
          'audioTitle': 'Part 1 - Photo 3',
          'transcript': 'A. A man is painting a wall. B. A man is arranging books on a shelf. C. A man is cleaning windows. D. A man is moving furniture.',
          'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
          'correctAnswer': 'B',
          'explanation': 'The man is organizing books on the bookshelf.',
          'optionsText': {
            'A': 'A man is painting a wall.',
            'B': 'A man is arranging books on a shelf.',
            'C': 'A man is cleaning windows.',
            'D': 'A man is moving furniture.'
          }
        },
        {
          'orderIndex': 4,
          'audioId': 'audio_part1_q4',
          'audioTitle': 'Part 1 - Photo 4',
          'transcript': 'A. The conference room is being cleaned. B. People are attending a meeting. C. The chairs are being rearranged. D. The room is empty.',
          'imageUrl': 'https://images.unsplash.com/photo-1431540015161-0bf868a2d407',
          'correctAnswer': 'B',
          'explanation': 'Several people are seated around the conference table in a meeting.',
          'optionsText': {
            'A': 'The conference room is being cleaned.',
            'B': 'People are attending a meeting.',
            'C': 'The chairs are being rearranged.',
            'D': 'The room is empty.'
          }
        },
        {
          'orderIndex': 5,
          'audioId': 'audio_part1_q5',
          'audioTitle': 'Part 1 - Photo 5',
          'transcript': 'A. A woman is typing on a computer. B. A woman is talking on the phone. C. A woman is drinking coffee. D. A woman is writing notes.',
          'imageUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
          'correctAnswer': 'A',
          'explanation': 'The woman is actively typing on her computer keyboard.',
          'optionsText': {
            'A': 'A woman is typing on a computer.',
            'B': 'A woman is talking on the phone.',
            'C': 'A woman is drinking coffee.',
            'D': 'A woman is writing notes.'
          }
        }
      ];

      for (var q in questionsData) {
        final audioId = await _createAudioDirectly(
          q['audioId'] as String,
          q['audioTitle'] as String,
          q['transcript'] as String
        );

        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.listening.name,
          'section': 'listening',
          'part': 1,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicPhotographs.displayName,
          'questionText': 'Look at the picture marked Number ${q['orderIndex']} in your test book.',
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'],
          'audioId': audioId,
          'difficulty': DifficultyLevel.intermediate.name,
          'metadata': {
            'imageUrl': q['imageUrl'],
            'keywords': ['describing pictures', 'present continuous'],
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Part 1 Question ${q['orderIndex']} created');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 1: $e');
    }
  }

  // ==================== PART 2: QUESTION-RESPONSE (5 câu) ====================
  Future<void> _seedPart2Questions() async {
    print('🗣️ Seeding Part 2 questions...');

    try {
      final questionsData = [
        {
          'orderIndex': 7,
          'audioId': 'audio_part2_q7',
          'audioTitle': 'Part 2 - Q7',
          'transcript': 'Question: When is the deadline for the report? A. By Friday afternoon. B. In the filing cabinet. C. Yes, I finished it.',
          'question': 'When is the deadline for the report?',
          'optionsText': {
            'A': 'By Friday afternoon.',
            'B': 'In the filing cabinet.',
            'C': 'Yes, I finished it.'
          },
          'correctAnswer': 'A',
          'explanation': 'When question requires time response.',
          'keywords': ['wh-questions', 'time expressions']
        },
        {
          'orderIndex': 8,
          'audioId': 'audio_part2_q8',
          'audioTitle': 'Part 2 - Q8',
          'transcript': 'Question: Where is the marketing department? A. They work on campaigns. B. On the third floor. C. Every Monday.',
          'question': 'Where is the marketing department?',
          'optionsText': {
            'A': 'They work on campaigns.',
            'B': 'On the third floor.',
            'C': 'Every Monday.'
          },
          'correctAnswer': 'B',
          'explanation': 'Where question needs location answer.',
          'keywords': ['wh-questions', 'location']
        },
        {
          'orderIndex': 9,
          'audioId': 'audio_part2_q9',
          'audioTitle': 'Part 2 - Q9',
          'transcript': 'Question: Did you send the email to the client? A. At the post office. B. Yes, this morning. C. By express mail.',
          'question': 'Did you send the email to the client?',
          'optionsText': {
            'A': 'At the post office.',
            'B': 'Yes, this morning.',
            'C': 'By express mail.'
          },
          'correctAnswer': 'B',
          'explanation': 'Yes/No question requires yes/no response.',
          'keywords': ['yes-no questions']
        },
        {
          'orderIndex': 10,
          'audioId': 'audio_part2_q10',
          'audioTitle': 'Part 2 - Q10',
          'transcript': 'Question: Who is in charge of the new project? A. Jessica from accounting. B. About 50 dollars. C. Last Tuesday.',
          'question': 'Who is in charge of the new project?',
          'optionsText': {
            'A': 'Jessica from accounting.',
            'B': 'About 50 dollars.',
            'C': 'Last Tuesday.'
          },
          'correctAnswer': 'A',
          'explanation': 'Who question needs person identification.',
          'keywords': ['wh-questions', 'people']
        },
        {
          'orderIndex': 11,
          'audioId': 'audio_part2_q11',
          'audioTitle': 'Part 2 - Q11',
          'transcript': 'Question: How much does the printer cost? A. In the supply room. B. About 300 dollars. C. Two weeks ago.',
          'question': 'How much does the printer cost?',
          'optionsText': {
            'A': 'In the supply room.',
            'B': 'About 300 dollars.',
            'C': 'Two weeks ago.'
          },
          'correctAnswer': 'B',
          'explanation': 'How much question requires price/amount.',
          'keywords': ['wh-questions', 'numbers']
        }
      ];

      for (var q in questionsData) {
        final audioId = await _createAudioDirectly(
          q['audioId'] as String,
          q['audioTitle'] as String,
          q['transcript'] as String
        );

        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.listening.name,
          'section': 'listening',
          'part': 2,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicQuestionResponse.displayName,
          'questionText': '',
          'options': ['A', 'B', 'C'],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'],
          'audioId': audioId,
          'difficulty': DifficultyLevel.intermediate.name,
          'metadata': {
            'transcript': q['optionsText'],
            'keywords': q['keywords']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Part 2 Question ${q['orderIndex']} created');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 2: $e');
    }
  }

  // ==================== PART 3: CONVERSATIONS (5 câu, 1 audio chung) ====================
  Future<void> _seedPart3Questions() async {
    print('📞 Seeding Part 3 questions...');

    try {
      final audioId = await _createAudioDirectly(
        'audio_part3_set1',
        'Part 3 - Conversation 1 (Q32-36)',
        'Woman: Good morning. I am calling about the job opening for marketing manager. Man: Yes, we are still accepting applications. The deadline is next Friday. Woman: Great! Could you tell me what qualifications you are looking for? Man: We need someone with at least 5 years of experience and excellent communication skills. Woman: Perfect. I will send my resume today.'
      );

      final questionsData = [
        {
          'orderIndex': 32,
          'text': 'What is the woman calling about?',
          'optionsText': {
            'A': 'A job opening',
            'B': 'A product order',
            'C': 'A meeting schedule',
            'D': 'A payment issue'
          },
          'correct': 'A'
        },
        {
          'orderIndex': 33,
          'text': 'When is the application deadline?',
          'optionsText': {
            'A': 'This Friday',
            'B': 'Next Friday',
            'C': 'Next Monday',
            'D': 'Next month'
          },
          'correct': 'B'
        },
        {
          'orderIndex': 34,
          'text': 'How many years of experience are required?',
          'optionsText': {
            'A': '3 years',
            'B': '4 years',
            'C': '5 years',
            'D': '6 years'
          },
          'correct': 'C'
        },
        {
          'orderIndex': 35,
          'text': 'What skill is mentioned as important?',
          'optionsText': {
            'A': 'Technical skills',
            'B': 'Communication skills',
            'C': 'Financial skills',
            'D': 'Language skills'
          },
          'correct': 'B'
        },
        {
          'orderIndex': 36,
          'text': 'What will the woman do today?',
          'optionsText': {
            'A': 'Attend an interview',
            'B': 'Call back later',
            'C': 'Send her resume',
            'D': 'Visit the office'
          },
          'correct': 'C'
        }
      ];

      for (var q in questionsData) {
        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.listening.name,
          'section': 'listening',
          'part': 3,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicConversations.displayName,
          'questionText': q['text'],
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correct'],
          'audioId': audioId,
          'difficulty': DifficultyLevel.intermediate.name,
          'explanation': 'See transcript for details.',
          'metadata': {
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Created Question Q${q['orderIndex']}');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 3: $e');
    }
  }

  // ==================== PART 4: TALKS (5 câu, 1 audio chung) ====================
  Future<void> _seedPart4Questions() async {
    print('📢 Seeding Part 4 questions...');

    try {
      final audioId = await _createAudioDirectly(
        'audio_part4_set1',
        'Part 4 - Talk 1 (Q71-75)',
        'Good afternoon, everyone. This is Sarah from Human Resources. I am calling to remind you about our annual company picnic this Saturday at Central Park. The event will start at 10 AM and end at 4 PM. Please bring your family members. We will provide food and drinks. There will also be games and activities for children. If you plan to attend, please confirm by email before Thursday. We look forward to seeing you there.'
      );

      final questionsData = [
        {
          'orderIndex': 71,
          'text': 'Who is the speaker?',
          'optionsText': {
            'A': 'A manager',
            'B': 'An HR representative',
            'C': 'A customer',
            'D': 'A trainer'
          },
          'correct': 'B'
        },
        {
          'orderIndex': 72,
          'text': 'What is the announcement about?',
          'optionsText': {
            'A': 'A training session',
            'B': 'A company picnic',
            'C': 'A business meeting',
            'D': 'A product launch'
          },
          'correct': 'B'
        },
        {
          'orderIndex': 73,
          'text': 'When will the event take place?',
          'optionsText': {
            'A': 'Friday',
            'B': 'Saturday',
            'C': 'Sunday',
            'D': 'Monday'
          },
          'correct': 'B'
        },
        {
          'orderIndex': 74,
          'text': 'What should attendees bring?',
          'optionsText': {
            'A': 'Their own food',
            'B': 'Work documents',
            'C': 'Family members',
            'D': 'Sports equipment'
          },
          'correct': 'C'
        },
        {
          'orderIndex': 75,
          'text': 'When is the confirmation deadline?',
          'optionsText': {
            'A': 'Monday',
            'B': 'Wednesday',
            'C': 'Thursday',
            'D': 'Friday'
          },
          'correct': 'C'
        }
      ];

      for (var q in questionsData) {
        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.listening.name,
          'section': 'listening',
          'part': 4,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicTalks.displayName,
          'questionText': q['text'],
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correct'],
          'audioId': audioId,
          'difficulty': DifficultyLevel.intermediate.name,
          'explanation': 'See transcript for details.',
          'metadata': {
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Created Question Q${q['orderIndex']}');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 4: $e');
    }
  }

  // ==================== PART 5: INCOMPLETE SENTENCES (5 câu) ====================
  Future<void> _seedPart5Questions() async {
    print('✍️ Seeding Part 5 questions...');

    try {
      final questions = [
        {
          'orderIndex': 101,
          'questionText': 'The company _____ a new policy next month.',
          'optionsText': {
            'A': 'implement',
            'B': 'implements',
            'C': 'will implement',
            'D': 'implementing'
          },
          'correctAnswer': 'C',
          'explanation': 'Future tense is needed because of "next month".',
          'grammarPoint': 'future_tense'
        },
        {
          'orderIndex': 102,
          'questionText': 'The project must be completed _____ the end of the month.',
          'optionsText': {
            'A': 'by',
            'B': 'until',
            'C': 'on',
            'D': 'at'
          },
          'correctAnswer': 'A',
          'explanation': '"By" is used with deadlines.',
          'grammarPoint': 'prepositions_time'
        },
        {
          'orderIndex': 103,
          'questionText': 'The manager _____ the meeting yesterday.',
          'optionsText': {
            'A': 'attends',
            'B': 'attended',
            'C': 'will attend',
            'D': 'attending'
          },
          'correctAnswer': 'B',
          'explanation': 'Past tense needed for "yesterday".',
          'grammarPoint': 'past_tense'
        },
        {
          'orderIndex': 104,
          'questionText': 'Please _____ the document carefully before signing.',
          'optionsText': {
            'A': 'to review',
            'B': 'reviewing',
            'C': 'reviewed',
            'D': 'review'
          },
          'correctAnswer': 'D',
          'explanation': 'Imperative form uses base verb.',
          'grammarPoint': 'imperative'
        },
        {
          'orderIndex': 105,
          'questionText': 'The conference room is _____ for the presentation.',
          'optionsText': {
            'A': 'availability',
            'B': 'available',
            'C': 'avail',
            'D': 'availably'
          },
          'correctAnswer': 'B',
          'explanation': '"Available" is the correct adjective form.',
          'grammarPoint': 'word_forms'
        }
      ];

      for (var q in questions) {
        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.reading.name,
          'section': 'reading',
          'part': 5,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicIncompleteSentences.displayName,
          'questionText': q['questionText'],
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'],
          'difficulty': DifficultyLevel.intermediate.name,
          'metadata': {
            'grammarPoint': q['grammarPoint'],
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Part 5 Question ${q['orderIndex']} created');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 5: $e');
    }
  }

  // ==================== PART 6: TEXT COMPLETION (5 câu với passage) ====================
  Future<void> _seedPart6Questions() async {
    print('📝 Seeding Part 6 questions...');

    try {
      final passageRef = await firestore.collection('passages').add({
        'examType': ExamType.toeic.code,
        'part': 6,
        'passageType': 'business_letter',
        'title': 'Letter: Customer Feedback Request',
        'content': '''Dear Valued Customer,

Thank you for choosing our services. We _____(131) appreciate your business and want to ensure your complete satisfaction.

We are _____(132) conducting a customer satisfaction survey. Your feedback will help us improve our services. The survey will only take 5 minutes to complete.

_____(133), we are offering a 10% discount on your next purchase as a token of our appreciation for your time.

Please click the link below to begin. We look forward to _____(134) from you soon.

Best regards,
Customer Service Team''',
        'topic': 'customer_service',
        'difficulty': DifficultyLevel.intermediate.name,
        'wordCount': 95,
        'estimatedReadingTime': 3,
        'tags': ['business', 'letter', 'survey'],
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('📄 Created passage: ${passageRef.id}');

      final questions = [
        {
          'orderIndex': 131,
          'questionText': 'Choose the best word for blank (131)',
          'optionsText': {
            'A': 'great',
            'B': 'greatly',
            'C': 'greater',
            'D': 'greatness'
          },
          'correctAnswer': 'B',
          'explanation': 'Adverb "greatly" modifies the verb "appreciate".',
          'grammarPoint': 'adverbs'
        },
        {
          'orderIndex': 132,
          'questionText': 'Choose the best word for blank (132)',
          'optionsText': {
            'A': 'current',
            'B': 'currently',
            'C': 'currency',
            'D': 'currents'
          },
          'correctAnswer': 'B',
          'explanation': 'Adverb "currently" means "at this time".',
          'grammarPoint': 'time_expressions'
        },
        {
          'orderIndex': 133,
          'questionText': 'Choose the best word for blank (133)',
          'optionsText': {
            'A': 'However',
            'B': 'Therefore',
            'C': 'Additionally',
            'D': 'Nevertheless'
          },
          'correctAnswer': 'C',
          'explanation': '"Additionally" introduces extra information.',
          'grammarPoint': 'transitions'
        },
        {
          'orderIndex': 134,
          'questionText': 'Choose the best word for blank (134)',
          'optionsText': {
            'A': 'hear',
            'B': 'heard',
            'C': 'hearing',
            'D': 'to hear'
          },
          'correctAnswer': 'C',
          'explanation': '"Look forward to" requires gerund (-ing form).',
          'grammarPoint': 'gerunds'
        },
        {
          'orderIndex': 135,
          'questionText': 'What is the main purpose of this letter?',
          'optionsText': {
            'A': 'To announce a new product',
            'B': 'To request customer feedback',
            'C': 'To apologize for an error',
            'D': 'To confirm an order'
          },
          'correctAnswer': 'B',
          'explanation': 'The letter clearly requests customer feedback through a survey.',
          'grammarPoint': 'reading_comprehension'
        }
      ];

      for (var q in questions) {
        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.reading.name,
          'section': 'reading',
          'part': 6,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicTextCompletion.displayName,
          'questionText': q['questionText'],
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'],
          'passageId': passageRef.id,
          'difficulty': DifficultyLevel.intermediate.name,
          'metadata': {
            'passageType': 'business_letter',
            'grammarPoint': q['grammarPoint'],
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Part 6 Question ${q['orderIndex']} created');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 6: $e');
    }
  }

  // ==================== PART 7: READING COMPREHENSION (5 câu với passage) ====================
  Future<void> _seedPart7Questions() async {
    print('📖 Seeding Part 7 questions...');

    try {
      final passageRef = await firestore.collection('passages').add({
        'examType': ExamType.toeic.code,
        'part': 7,
        'passageType': 'email',
        'title': 'Email: Office Relocation Notice',
        'content': '''To: All Staff
From: Facilities Management
Date: January 15
Subject: Office Relocation

Dear Team Members,

We are excited to announce that our company will be relocating to a new office building on March 1st. The new address is 456 Business Park Drive, Suite 300.

The new facility offers several improvements:
- 30% more workspace
- Modern conference rooms with video equipment
- On-site cafeteria and fitness center
- Free parking for all employees

All departments will move on the same day. Professional movers will handle all equipment and furniture. Please pack your personal items in boxes provided by HR by February 25th.

If you have any questions, please contact the Facilities team at ext. 1500.

Thank you for your cooperation.

Best regards,
Facilities Management Team''',
        'topic': 'business_communication',
        'difficulty': DifficultyLevel.intermediate.name,
        'wordCount': 145,
        'estimatedReadingTime': 4,
        'tags': ['office', 'relocation', 'announcement'],
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('📄 Created passage: ${passageRef.id}');

      final questions = [
        {
          'orderIndex': 147,
          'questionText': 'What is the main purpose of the email?',
          'optionsText': {
            'A': 'To announce new hiring',
            'B': 'To announce office relocation',
            'C': 'To introduce new policies',
            'D': 'To request feedback'
          },
          'correctAnswer': 'B',
          'explanation': 'The email announces the office will relocate to a new building.',
          'questionType': 'main_idea'
        },
        {
          'orderIndex': 148,
          'questionText': 'When will the company move to the new office?',
          'optionsText': {
            'A': 'January 15',
            'B': 'February 25',
            'C': 'March 1',
            'D': 'March 15'
          },
          'correctAnswer': 'C',
          'explanation': 'The relocation date is clearly stated as March 1st.',
          'questionType': 'detail'
        },
        {
          'orderIndex': 149,
          'questionText': 'What is NOT mentioned as a feature of the new office?',
          'optionsText': {
            'A': 'More workspace',
            'B': 'Video conference rooms',
            'C': 'Free parking',
            'D': 'Rooftop garden'
          },
          'correctAnswer': 'D',
          'explanation': 'Rooftop garden is not mentioned in the list of improvements.',
          'questionType': 'negative_fact'
        },
        {
          'orderIndex': 150,
          'questionText': 'By when should employees pack their personal items?',
          'optionsText': {
            'A': 'January 15',
            'B': 'February 25',
            'C': 'March 1',
            'D': 'March 15'
          },
          'correctAnswer': 'B',
          'explanation': 'Personal items should be packed by February 25th.',
          'questionType': 'detail'
        },
        {
          'orderIndex': 151,
          'questionText': 'How can employees get more information?',
          'optionsText': {
            'A': 'Email HR department',
            'B': 'Visit the new office',
            'C': 'Call ext. 1500',
            'D': 'Attend a meeting'
          },
          'correctAnswer': 'C',
          'explanation': 'Employees should contact Facilities team at ext. 1500 for questions.',
          'questionType': 'detail'
        }
      ];

      for (var q in questions) {
        await firestore.collection('questions').add({
          'examType': ExamType.toeic.code,
          'skill': SkillType.reading.name,
          'section': 'reading',
          'part': 7,
          'orderIndex': q['orderIndex'],
          'questionType': QuestionType.toeicReadingComprehension.displayName,
          'questionText': q['questionText'],
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'],
          'passageId': passageRef.id,
          'difficulty': DifficultyLevel.intermediate.name,
          'metadata': {
            'passageType': 'email',
            'questionType': q['questionType'],
            'optionsText': q['optionsText']
          },
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('   ✅ Part 7 Question ${q['orderIndex']} created');
      }
    } catch (e) {
      print('   ❌ Error seeding Part 7: $e');
    }
  }
}

// ==================== RUN SEEDER ====================
Future<void> runToeicSeeder() async {
  final firestore = FirebaseFirestore.instance;
  final seeder = ToeicQuestionSeeder(firestore);
  await seeder.seedAllToeicQuestions();
}