import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../config/openai_config.dart';

class OpenAIService {
  Future<Map<String, dynamic>> gradeWriting({
    required String taskPrompt,
    required String userAnswer,
    required int taskNumber,
  }) async {
    final systemPrompt = '''
You are a strict IELTS Writing examiner. Grade this answer based on official IELTS Writing Task $taskNumber criteria.

IMPORTANT GRADING RULES:
- If the answer is off-topic, irrelevant, or nonsensical: Give 0-2 bands for Task Achievement
- If word count < 150 (Task 1) or < 250 (Task 2): Penalize Task Achievement heavily
- If answer is too short (< 100 words): Maximum band 4.0 overall
- If grammar is poor with many basic errors: Maximum band 5.0
- If vocabulary is very limited or repetitive: Maximum band 5.0
- If answer lacks structure or coherence: Maximum band 5.0
- For nonsense or random words: Give band 1.0-2.0

GRADE EACH CRITERION (0-9):
1. Task Achievement/Response:
   - Band 9: Fully addresses all parts, clear position, well-developed ideas
   - Band 7: Addresses all parts, clear position, main ideas extended
   - Band 5: Addresses task only partially, unclear position, limited development
   - Band 3: Does not address task, no clear position
   - Band 1: Answer is completely irrelevant or incomprehensible

2. Coherence and Cohesion:
   - Band 9: Seamless cohesion, skillful paragraphing
   - Band 7: Clear progression, appropriate cohesive devices
   - Band 5: Inadequate/overuse of cohesive devices, paragraphing unclear
   - Band 3: Ideas not logically organized, no paragraphing
   - Band 1: No coherence, random sentences

3. Lexical Resource:
   - Band 9: Wide range, natural and sophisticated word choice
   - Band 7: Sufficient range, some flexibility, occasional errors
   - Band 5: Limited range, repetitive, noticeable errors
   - Band 3: Very limited vocabulary, errors dominate
   - Band 1: Extremely limited vocabulary, incomprehensible

4. Grammatical Range and Accuracy:
   - Band 9: Wide range of structures, error-free
   - Band 7: Variety of complex structures, frequent error-free sentences
   - Band 5: Limited range, frequent errors but meaning is clear
   - Band 3: Only simple structures, errors predominate
   - Band 1: Cannot use sentence forms, incomprehensible

Return JSON format:
{
  "overall_score": 5.5,
  "task_achievement": 5.0,
  "coherence_cohesion": 6.0,
  "lexical_resource": 5.5,
  "grammar_accuracy": 5.5,
  "feedback": "Detailed explanation of why this score",
  "strengths": ["List actual strengths if any"],
  "improvements": ["Specific areas to improve"]
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
You are a strict IELTS Speaking examiner. Grade this transcription based on official IELTS Speaking Part $partNumber criteria.

IMPORTANT GRADING RULES:
- If answer is off-topic or doesn't answer the question: Maximum band 4.0
- If answer is too short (< 10 words for Part 1, < 30 words for Part 2/3): Maximum band 3.0
- If answer is nonsensical, random words, or gibberish: Band 1.0-2.0
- If transcription shows poor grammar throughout: Maximum band 5.0
- If vocabulary is very basic or repetitive: Maximum band 5.0
- If answer lacks development (yes/no answers only): Maximum band 4.0
- Be realistic: Most candidates score 5.0-7.0, not 8.0-9.0

GRADE EACH CRITERION (0-9):
1. Fluency and Coherence:
   - Band 9: Speaks fluently, fully coherent, no repetition
   - Band 7: Speaks at length, coherent, some hesitation
   - Band 5: Speaks with frequent pauses, limited coherence
   - Band 3: Speaks with long pauses, simple responses only
   - Band 1: Pauses dominate, no communication

2. Lexical Resource:
   - Band 9: Precise and sophisticated vocabulary
   - Band 7: Flexible vocabulary, some less common words
   - Band 5: Limited vocabulary, relies on basic words
   - Band 3: Very limited vocabulary, inadequate for topic
   - Band 1: Insufficient vocabulary to answer

3. Grammatical Range and Accuracy:
   - Band 9: Wide range, naturally accurate
   - Band 7: Range of complex structures, some errors
   - Band 5: Basic structures, errors frequent but meaning clear
   - Band 3: Only simple structures, errors prevent meaning
   - Band 1: Cannot produce basic sentence forms

4. Pronunciation (assess from transcription quality):
   - Band 9: Fully comprehensible, precise
   - Band 7: Generally comprehensible, some mispronunciation
   - Band 5: Mispronunciation evident, requires effort to understand
   - Band 3: Frequent mispronunciation, difficult to understand
   - Band 1: Speech mostly unintelligible

For Part 1: Short answers (20-30 seconds) are acceptable
For Part 2: Must speak for 1-2 minutes with development
For Part 3: Answers should be detailed and analytical

Return JSON format:
{
  "overall_score": 5.5,
  "fluency_coherence": 5.0,
  "lexical_resource": 6.0,
  "grammar_accuracy": 5.5,
  "pronunciation": 5.5,
  "feedback": "Detailed explanation of why this score",
  "strengths": ["List actual strengths if any"],
  "improvements": ["Specific areas needing improvement"]
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
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check file exists and size
        final file = File(audioFilePath);
        if (!await file.exists()) {
          throw Exception('Audio file not found: $audioFilePath');
        }
        
        final fileSize = await file.length();
        print('📤 Transcribing audio: ${audioFilePath.split('/').last} (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        
        // OpenAI limit is 25MB, warn if too large
        if (fileSize > 25 * 1024 * 1024) {
          throw Exception('File too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB). Max 25MB');
        }
        
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(OpenAIConfig.transcriptionsEndpoint),
        );
        
        request.headers['Authorization'] = 'Bearer ${OpenAIConfig.apiKey}';
        request.files.add(await http.MultipartFile.fromPath(
          'file', 
          audioFilePath,
          contentType: MediaType('audio', 'wav'), // Explicitly set content type
        ));
        request.fields['model'] = 'whisper-1';
        request.fields['language'] = 'en';

        // Send with longer timeout (60 seconds)
        final streamedResponse = await request.send().timeout(
          Duration(seconds: 60),
          onTimeout: () {
            throw TimeoutException('Request timeout after 60 seconds');
          },
        );
        
        final responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final text = data['text'] ?? '';
          print('✅ Transcription success: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
          return text;
        } else {
          print('❌ Whisper API Error: ${streamedResponse.statusCode}');
          print('Error details: $responseBody');
          
          // If 401, don't retry
          if (streamedResponse.statusCode == 401) {
            throw Exception('Invalid API Key (401). Check openai_config.dart');
          }
          
          throw Exception('OpenAI Whisper API error: ${streamedResponse.statusCode} - $responseBody');
        }
      } catch (e) {
        retryCount++;
        print('⚠️ Transcription attempt $retryCount/$maxRetries failed: $e');
        
        if (retryCount >= maxRetries) {
          print('❌ All retry attempts failed');
          throw Exception('Failed to transcribe after $maxRetries attempts: $e');
        }
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    throw Exception('Failed to transcribe audio');
  }
}
