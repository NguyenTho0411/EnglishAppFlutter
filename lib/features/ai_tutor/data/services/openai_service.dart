import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/feedback_entity.dart';

class OpenAIService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1';
  
  // Use GPT-4 for better quality, or GPT-3.5-turbo for cost efficiency
  final String model = 'gpt-4';  // or 'gpt-3.5-turbo'

  OpenAIService({required this.apiKey});

  // ==================== CHAT ====================
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> messages,
    String? systemPrompt,
    double temperature = 0.7,
  }) async {
    final messagesJson = messages.map((msg) => {
      'role': msg.role,
      'content': msg.content,
    }).toList();

    // Add system prompt if provided
    if (systemPrompt != null) {
      messagesJson.insert(0, {
        'role': 'system',
        'content': systemPrompt,
      });
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messagesJson,
        'temperature': temperature,
        'max_tokens': 1500,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get AI response: ${response.body}');
    }
  }

  // ==================== WRITING FEEDBACK ====================
  Future<WritingFeedbackEntity> getWritingFeedback({
    required String essayText,
    required String task,
    required String examType, // 'IELTS' or 'TOEIC'
  }) async {
    final systemPrompt = '''You are an expert IELTS/TOEIC writing examiner. 
Analyze the following essay and provide detailed feedback.
Return your response in JSON format with the following structure:
{
  "overallScore": <band score 0-9>,
  "criteriaScores": {
    "taskAchievement": <0-9>,
    "coherenceCohesion": <0-9>,
    "lexicalResource": <0-9>,
    "grammaticalRange": <0-9>
  },
  "overallFeedback": "<detailed feedback>",
  "errors": [
    {
      "type": "<grammar|spelling|vocabulary|coherence>",
      "text": "<incorrect text>",
      "correction": "<correction>",
      "explanation": "<why it's wrong>",
      "startIndex": <position>,
      "endIndex": <position>
    }
  ],
  "strengths": ["<strength 1>", "<strength 2>", ...],
  "improvements": ["<improvement 1>", "<improvement 2>", ...]
}''';

    final userPrompt = '''Task: $task

Essay:
$essayText

Please analyze this $examType essay and provide comprehensive feedback.''';

    final messages = [
      ChatMessageEntity(
        id: '1',
        role: 'user',
        content: userPrompt,
        timestamp: DateTime.now(),
      ),
    ];

    final response = await sendChatMessage(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: 0.3, // Lower temperature for more consistent grading
    );

    // Parse JSON response
    final jsonResponse = jsonDecode(response);

    return WritingFeedbackEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      essayText: essayText,
      overallScore: (jsonResponse['overallScore'] as num).toDouble(),
      criteriaScores: Map<String, double>.from(
        (jsonResponse['criteriaScores'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      overallFeedback: jsonResponse['overallFeedback'] as String,
      errors: (jsonResponse['errors'] as List)
          .map((e) => WritingError(
                type: e['type'] as String,
                text: e['text'] as String,
                correction: e['correction'] as String,
                explanation: e['explanation'] as String,
                startIndex: e['startIndex'] as int,
                endIndex: e['endIndex'] as int,
              ))
          .toList(),
      strengths: List<String>.from(jsonResponse['strengths']),
      improvements: List<String>.from(jsonResponse['improvements']),
      createdAt: DateTime.now(),
    );
  }

  // ==================== SPEAKING FEEDBACK ====================
  Future<SpeakingFeedbackEntity> getSpeakingFeedback({
    required String transcript,
    required String question,
    required int durationSeconds,
    required String examType,
  }) async {
    final wordCount = transcript.split(' ').length;
    final wordsPerMinute = (wordCount / (durationSeconds / 60)).toDouble();

    final systemPrompt = '''You are an expert IELTS/TOEIC speaking examiner.
Analyze the following speaking response and provide detailed feedback.
Return your response in JSON format with the following structure:
{
  "overallScore": <band score 0-9>,
  "criteriaScores": {
    "fluency": <0-9>,
    "lexicalResource": <0-9>,
    "grammaticalRange": <0-9>,
    "pronunciation": <0-9>
  },
  "overallFeedback": "<detailed feedback>",
  "strengths": ["<strength 1>", "<strength 2>", ...],
  "improvements": ["<improvement 1>", "<improvement 2>", ...]
}''';

    final userPrompt = '''Question: $question

Transcript:
$transcript

Duration: $durationSeconds seconds
Word Count: $wordCount words
Speaking Rate: ${wordsPerMinute.toStringAsFixed(1)} words/minute

Please analyze this $examType speaking response and provide comprehensive feedback.''';

    final messages = [
      ChatMessageEntity(
        id: '1',
        role: 'user',
        content: userPrompt,
        timestamp: DateTime.now(),
      ),
    ];

    final response = await sendChatMessage(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: 0.3,
    );

    final jsonResponse = jsonDecode(response);

    return SpeakingFeedbackEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      audioUrl: '', // Will be filled by caller
      transcript: transcript,
      overallScore: (jsonResponse['overallScore'] as num).toDouble(),
      criteriaScores: Map<String, double>.from(
        (jsonResponse['criteriaScores'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      overallFeedback: jsonResponse['overallFeedback'] as String,
      strengths: List<String>.from(jsonResponse['strengths']),
      improvements: List<String>.from(jsonResponse['improvements']),
      duration: durationSeconds,
      wordCount: wordCount,
      wordsPerMinute: wordsPerMinute,
      createdAt: DateTime.now(),
    );
  }

  // ==================== EXPLANATION GENERATION ====================
  Future<String> generateExplanation({
    required String question,
    required String correctAnswer,
    String? userAnswer,
    String? passage,
  }) async {
    final systemPrompt = '''You are an expert English teacher.
Explain why the correct answer is right in a clear and educational way.
If the user got it wrong, also explain why their answer was incorrect.
Keep the explanation concise (2-3 sentences) but insightful.''';

    String userPrompt = 'Question: $question\n\nCorrect Answer: $correctAnswer';
    
    if (passage != null && passage.isNotEmpty) {
      userPrompt += '\n\nContext: ${passage.substring(0, passage.length > 200 ? 200 : passage.length)}...';
    }
    
    if (userAnswer != null && userAnswer.isNotEmpty) {
      userPrompt += '\n\nUser\'s Answer: $userAnswer';
    }

    userPrompt += '\n\nPlease explain the correct answer.';

    final messages = [
      ChatMessageEntity(
        id: '1',
        role: 'user',
        content: userPrompt,
        timestamp: DateTime.now(),
      ),
    ];

    return await sendChatMessage(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: 0.5,
    );
  }

  // ==================== TUTOR CHAT ====================
  Future<String> tutorChat({
    required List<ChatMessageEntity> conversationHistory,
    String? context, // Question, passage, or other relevant context
  }) async {
    final systemPrompt = '''You are an expert IELTS/TOEIC tutor and English teacher.
You help students understand exam questions, improve their English skills, and prepare for the exam.
Be encouraging, clear, and educational in your responses.
${context != null ? '\n\nContext: $context' : ''}''';

    return await sendChatMessage(
      messages: conversationHistory,
      systemPrompt: systemPrompt,
      temperature: 0.7,
    );
  }

  // ==================== SCORE PREDICTION ====================
  Future<Map<String, dynamic>> predictScore({
    required String userId,
    required String examType,
    required List<Map<String, dynamic>> recentAttempts,
  }) async {
    final systemPrompt = '''You are an expert IELTS/TOEIC score predictor.
Based on the user's recent practice attempts, predict their likely exam score.
Return your response in JSON format:
{
  "predictedScore": <score>,
  "confidence": <0-100>,
  "analysis": "<brief analysis>",
  "recommendations": ["<rec 1>", "<rec 2>", ...]
}''';

    final attemptsString = recentAttempts.map((a) => 
      'Score: ${a['score']}, Accuracy: ${a['accuracy']}%, Skill: ${a['skill']}'
    ).join('\n');

    final userPrompt = '''Analyze these recent practice attempts for $examType:

$attemptsString

Predict the user's likely exam score and provide recommendations.''';

    final messages = [
      ChatMessageEntity(
        id: '1',
        role: 'user',
        content: userPrompt,
        timestamp: DateTime.now(),
      ),
    ];

    final response = await sendChatMessage(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: 0.3,
    );

    return jsonDecode(response);
  }
}
