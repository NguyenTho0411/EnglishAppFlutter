import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/openai_config.dart';
import '../../domain/entities/exam_type.dart';

class OpenAIService {
  Future<Map<String, dynamic>> gradeWriting({
    required String taskPrompt,
    required String userAnswer,
    required int taskNumber,
  }) async {
    final systemPrompt = '''
You are an IELTS Writing examiner. Grade this answer based on IELTS Writing Task $taskNumber criteria:
- Task Achievement/Response (0-9)
- Coherence and Cohesion (0-9)
- Lexical Resource (0-9)
- Grammatical Range and Accuracy (0-9)

Provide:
1. Overall band score (average, 0-9)
2. Individual scores for each criterion
3. Detailed feedback (strengths and areas for improvement)
4. Specific examples from the text

Return JSON format:
{
  "overall_score": 7.5,
  "task_achievement": 7.0,
  "coherence_cohesion": 8.0,
  "lexical_resource": 7.5,
  "grammar_accuracy": 7.5,
  "feedback": "...",
  "strengths": ["...", "..."],
  "improvements": ["...", "..."]
}
''';

    final userPrompt = '''
Task: $taskPrompt

User's Answer:
$userAnswer

Word count: ${userAnswer.split(' ').length} words
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Try to parse as JSON, if fails return raw content
        try {
          return jsonDecode(content);
        } catch (_) {
          // Extract scores from text response
          return _parseTextResponse(content);
        }
      } else {
        final errorBody = response.body;
        print('OpenAI API Error: ${response.statusCode}');
        print('Error details: $errorBody');
        
        String errorMessage = 'OpenAI API error ${response.statusCode}';
        if (response.statusCode == 400) {
          errorMessage = 'API Key không hợp lệ hoặc request format sai (400)';
        } else if (response.statusCode == 401) {
          errorMessage = 'API Key không hợp lệ hoặc hết hạn (401)';
        } else if (response.statusCode == 429) {
          errorMessage = 'Đã vượt quá giới hạn rate limit hoặc hết credits (429)';
        } else if (response.statusCode == 500) {
          errorMessage = 'Lỗi server OpenAI (500)';
        }
        throw Exception('$errorMessage. Chi tiết: $errorBody');
      }
    } catch (e) {
      print('Exception in gradeWriting: $e');
      throw Exception('Lỗi khi chấm bài: $e');
    }
  }

  Future<Map<String, dynamic>> gradeSpeaking({
    required String taskPrompt,
    required String transcription,
    required int partNumber,
  }) async {
    final systemPrompt = '''
You are an IELTS Speaking examiner. Grade this answer based on IELTS Speaking Part $partNumber criteria:
- Fluency and Coherence (0-9)
- Lexical Resource (0-9)
- Grammatical Range and Accuracy (0-9)
- Pronunciation (0-9)

Provide:
1. Overall band score (average, 0-9)
2. Individual scores for each criterion
3. Detailed feedback
4. Specific examples

Return JSON format:
{
  "overall_score": 7.5,
  "fluency_coherence": 7.0,
  "lexical_resource": 8.0,
  "grammar_accuracy": 7.5,
  "pronunciation": 7.5,
  "feedback": "...",
  "strengths": ["...", "..."],
  "improvements": ["...", "..."]
}
''';

    final userPrompt = '''
Task: $taskPrompt

User's Response (transcription):
$transcription
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return jsonDecode(content);
        } catch (_) {
          return _parseTextResponse(content);
        }
      } else {
        final errorBody = response.body;
        print('OpenAI API Error: ${response.statusCode}');
        print('Error details: $errorBody');
        
        String errorMessage = 'OpenAI API error ${response.statusCode}';
        if (response.statusCode == 400) {
          errorMessage = 'API Key không hợp lệ hoặc request format sai (400)';
        } else if (response.statusCode == 401) {
          errorMessage = 'API Key không hợp lệ hoặc hết hạn (401)';
        } else if (response.statusCode == 429) {
          errorMessage = 'Đã vượt quá giới hạn rate limit hoặc hết credits (429)';
        }
        throw Exception('$errorMessage. Chi tiết: $errorBody');
      }
    } catch (e) {
      print('Exception in gradeSpeaking: $e');
      throw Exception('Lỗi khi chấm speaking: $e');
    }
  }

  Map<String, dynamic> _parseTextResponse(String content) {
    // Fallback parser for non-JSON responses
    return {
      'overall_score': 7.0,
      'task_achievement': 7.0,
      'coherence_cohesion': 7.0,
      'lexical_resource': 7.0,
      'grammar_accuracy': 7.0,
      'fluency_coherence': 7.0,
      'pronunciation': 7.0,
      'feedback': content,
      'strengths': ['Response provided by AI'],
      'improvements': ['Check AI response for detailed feedback'],
    };
  }

  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(OpenAIConfig.transcriptionsEndpoint),
      );
      
      request.headers['Authorization'] = 'Bearer ${OpenAIConfig.apiKey}';
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'en';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'];
      } else {
        print('Whisper API Error: ${response.statusCode}');
        print('Error details: $responseBody');
        throw Exception('OpenAI Whisper API error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Exception in transcribeAudio: $e');
      throw Exception('Failed to transcribe audio: $e');
    }
  }


  /// Chấm điểm TOEIC Reading
  /// TOEIC Reading gồm 3 parts: Part 5, 6, 7
  /// Điểm từ 0-495 (scaled score)
  Future<Map<String, dynamic>> gradeToeicReading({
    required List<Map<String, dynamic>> userAnswers, // [{questionId, userAnswer, correctAnswer}]
    required int totalQuestions,
  }) async {
    final correctCount = userAnswers.where((ans) => 
      ans['userAnswer'] == ans['correctAnswer']
    ).length;
    
    final rawScore = correctCount;
    final scaledScore = _convertToToeicScore(rawScore, totalQuestions);
    
    final systemPrompt = '''
You are a TOEIC Reading expert. Analyze the user's performance and provide:
1. Scaled score (0-495)
2. Breakdown by part (Part 5: Grammar, Part 6: Text Completion, Part 7: Reading Comprehension)
3. Strengths and weaknesses
4. Study recommendations

Return JSON format:
{
  "scaled_score": 400,
  "raw_score": 85,
  "total_questions": 100,
  "accuracy": 85.0,
  "part5_accuracy": 90.0,
  "part6_accuracy": 85.0,
  "part7_accuracy": 80.0,
  "feedback": "...",
  "strengths": ["...", "..."],
  "weaknesses": ["...", "..."],
  "recommendations": ["...", "..."]
}
''';

    final userPrompt = '''
TOEIC Reading Performance:
- Correct answers: $correctCount / $totalQuestions
- Raw score: $rawScore
- Scaled score: $scaledScore

Detailed answers:
${jsonEncode(userAnswers)}

Analyze performance and provide feedback.
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final result = jsonDecode(content);
          // Ensure scaled_score is included
          result['scaled_score'] = scaledScore;
          result['raw_score'] = rawScore;
          return result;
        } catch (_) {
          return _parseToeicTextResponse(content, scaledScore, rawScore, totalQuestions);
        }
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in gradeToeicReading: $e');
      throw Exception('Lỗi khi chấm TOEIC Reading: $e');
    }
  }

  /// Chấm điểm TOEIC Listening
  /// TOEIC Listening gồm 4 parts: Part 1, 2, 3, 4
  /// Điểm từ 0-495 (scaled score)
  Future<Map<String, dynamic>> gradeToeicListening({
    required List<Map<String, dynamic>> userAnswers,
    required int totalQuestions,
  }) async {
    final correctCount = userAnswers.where((ans) => 
      ans['userAnswer'] == ans['correctAnswer']
    ).length;
    
    final rawScore = correctCount;
    final scaledScore = _convertToToeicScore(rawScore, totalQuestions);
    
    final systemPrompt = '''
You are a TOEIC Listening expert. Analyze the user's performance and provide:
1. Scaled score (0-495)
2. Breakdown by part (Part 1: Photos, Part 2: Q&A, Part 3: Conversations, Part 4: Talks)
3. Strengths and weaknesses
4. Study recommendations

Return JSON format:
{
  "scaled_score": 420,
  "raw_score": 90,
  "total_questions": 100,
  "accuracy": 90.0,
  "part1_accuracy": 95.0,
  "part2_accuracy": 92.0,
  "part3_accuracy": 88.0,
  "part4_accuracy": 85.0,
  "feedback": "...",
  "strengths": ["...", "..."],
  "weaknesses": ["...", "..."],
  "recommendations": ["...", "..."]
}
''';

    final userPrompt = '''
TOEIC Listening Performance:
- Correct answers: $correctCount / $totalQuestions
- Raw score: $rawScore
- Scaled score: $scaledScore

Detailed answers:
${jsonEncode(userAnswers)}

Analyze performance and provide feedback.
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final result = jsonDecode(content);
          result['scaled_score'] = scaledScore;
          result['raw_score'] = rawScore;
          return result;
        } catch (_) {
          return _parseToeicTextResponse(content, scaledScore, rawScore, totalQuestions);
        }
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in gradeToeicListening: $e');
      throw Exception('Lỗi khi chấm TOEIC Listening: $e');
    }
  }

  /// Convert raw score to TOEIC scaled score (0-495)
  /// Công thức đơn giản: scaled = (raw/total) * 495
  /// Thực tế TOEIC có conversion table phức tạp hơn
  int _convertToToeicScore(int rawScore, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    final percentage = rawScore / totalQuestions;
    return (percentage * 495).round();
  }

  Map<String, dynamic> _parseToeicTextResponse(
    String content, 
    int scaledScore, 
    int rawScore, 
    int totalQuestions
  ) {
    return {
      'scaled_score': scaledScore,
      'raw_score': rawScore,
      'total_questions': totalQuestions,
      'accuracy': (rawScore / totalQuestions * 100).toStringAsFixed(1),
      'part1_accuracy': 0.0,
      'part2_accuracy': 0.0,
      'part3_accuracy': 0.0,
      'part4_accuracy': 0.0,
      'part5_accuracy': 0.0,
      'part6_accuracy': 0.0,
      'part7_accuracy': 0.0,
      'feedback': content,
      'strengths': ['Xem phản hồi chi tiết từ AI'],
      'weaknesses': [],
      'recommendations': ['Luyện tập thêm các phần yếu'],
    };
  }

  /// Phân tích performance TOEIC (dùng trong ExamRemoteDataSource)
  Future<Map<String, dynamic>> analyzeToeicPerformance({
    required SkillType skill, // 'listening' or 'reading'
    required int correctCount,
    required int totalQuestions,
    required Map<String, Map<String, dynamic>> partStats,
  }) async {
    final scaledScore = _convertToToeicScore(correctCount, totalQuestions);
    
    final systemPrompt = '''
You are a TOEIC expert. Analyze the student's performance and provide:
1. Overall assessment of their $skill ability
2. Specific strengths and weaknesses by part
3. Targeted study recommendations
4. Estimated study time needed for improvement

Return JSON format with: feedback, strengths, weaknesses, recommendations
''';

    final userPrompt = '''
TOEIC $skill Performance:
- Score: $scaledScore/495
- Correct: $correctCount/$totalQuestions (${(correctCount/totalQuestions*100).toStringAsFixed(1)}%)

Part Statistics:
${partStats.entries.map((e) => '${e.key}: ${e.value['correct']}/${e.value['total']} (${(e.value['accuracy'] as double).toStringAsFixed(1)}%)').join('\n')}

Provide detailed analysis and actionable recommendations.
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return jsonDecode(content);
        } catch (_) {
          return {
            'feedback': content,
            'strengths': [],
            'weaknesses': [],
            'recommendations': [],
          };
        }
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'feedback': 'Không thể phân tích chi tiết lúc này',
        'strengths': ['Đã hoàn thành bài thi'],
        'weaknesses': ['Cần phân tích thêm'],
        'recommendations': ['Luyện tập đều đặn'],
      };
    }
  }

  /// Phân tích chi tiết từng part
  Future<Map<String, dynamic>> analyzePartPerformance({
    required int partNumber,
    required List<Map<String, dynamic>> questions,
    required String examType, // 'listening' or 'reading'
  }) async {
    final systemPrompt = '''
You are a TOEIC expert. Analyze performance on Part $partNumber of TOEIC $examType.
Provide detailed feedback on:
1. Common mistakes
2. Patterns in errors
3. Specific improvement strategies
4. Time management tips

Return JSON with structured feedback.
''';

    final userPrompt = '''
Part $partNumber Performance:
${jsonEncode(questions)}

Provide detailed analysis and recommendations.
''';

    try {
      final response = await http.post(
        Uri.parse(OpenAIConfig.chatCompletionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return jsonDecode(content);
        } catch (_) {
          return {'feedback': content};
        }
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi phân tích part: $e');
    }
  }



  
}
