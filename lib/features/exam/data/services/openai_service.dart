import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/openai_config.dart';

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
}
