import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import '../../../../config/openai_config.dart';

class BookChatbotService {
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref('Books');
  final Logger _logger = Logger();
  
  BookChatbotService() {
    // Initialize OpenAI API from config (not committed to Git)
    OpenAI.apiKey = OpenAIConfig.apiKey;
    OpenAI.showLogs = false;
  }

  /// Get all books from Firebase to use as context
  Future<String> _getBooksContext() async {
    try {
      final snapshot = await _booksRef.get();
      
      if (!snapshot.exists) {
        return 'No books available in the app.';
      }

      final booksData = snapshot.value as Map<dynamic, dynamic>;
      final List<String> booksInfo = [];

      booksData.forEach((key, value) {
        final book = value as Map<dynamic, dynamic>;
        final title = book['title'] ?? 'Unknown';
        final author = book['author'] ?? 'Unknown';
        final description = book['description'] ?? 'No description';
        final pages = book['pages'] ?? 0;
        final language = book['language'] ?? 'Unknown';
        final viewCount = book['viewCount'] ?? 0;
        final downloadsCount = book['downloadsCount'] ?? 0;
        
        booksInfo.add(
          'Title: $title\n'
          'Author: $author\n'
          'Description: $description\n'
          'Pages: $pages\n'
          'Language: $language\n'
          'Views: $viewCount\n'
          'Downloads: $downloadsCount\n'
        );
      });

      return booksInfo.join('\n---\n');
    } catch (e) {
      _logger.e('Error fetching books context: $e');
      return 'Unable to fetch books data.';
    }
  }

  /// Send a message to the chatbot and get a response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Check if API key is set
      if (OpenAIConfig.apiKey.isEmpty || OpenAIConfig.apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
        return 'Error: OpenAI API key not configured. Please set your API key in lib/config/openai_config.dart';
      }

      // Get books context from Firebase
      final booksContext = await _getBooksContext();

      // System prompt to restrict chatbot to app-related queries only
      final systemPrompt = '''
You are a helpful assistant for a book reading app. Your role is to help users find and discover books available in this app.

AVAILABLE BOOKS IN THE APP:
$booksContext

IMPORTANT RULES:
1. ONLY answer questions related to the books in this app
2. Suggest books based on user preferences (genre, author, difficulty, etc.)
3. Provide information about books available in the app
4. If user asks about books not in the app, politely say "That book is not available in our app, but here are similar books we have..."
5. DO NOT answer questions unrelated to books or this app
6. If user asks off-topic questions, politely redirect them: "I'm here to help you find books in our app. Would you like a book recommendation?"
7. Be concise and friendly in Vietnamese or English (match user's language)
8. You can recommend multiple books that match user criteria

Examples of valid questions:
- "Recommend a book for IELTS preparation"
- "What horror books do you have?"
- "Show me books by British Council"
- "I want a book with over 100 pages"

Examples of invalid questions (should redirect):
- "What's the weather today?" → Redirect to books
- "How do I cook pasta?" → Redirect to books
- "Tell me a joke" → Redirect to books
''';

      // Create chat completion with streaming disabled
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                userMessage,
              ),
            ],
          ),
        ],
        maxTokens: 500,
        temperature: 0.7,
      );

      // Extract response
      final response = chatCompletion.choices.first.message.content?.first.text ?? 
                      'Sorry, I could not generate a response.';
      
      return response;
      
    } catch (e) {
      _logger.e('Chatbot error: $e');
      
      if (e.toString().contains('API key')) {
        return 'Error: Invalid API key. Please check your OpenAI API key configuration.';
      }
      
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }

  /// Get a quick book recommendation
  Future<String> getQuickRecommendation() async {
    return sendMessage('Recommend me a good book from the available books.');
  }
}
