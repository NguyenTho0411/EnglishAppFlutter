/// OpenAI API Configuration Example
/// Copy this file to openai_config.dart and replace with your actual API key
/// The real openai_config.dart file is in .gitignore and won't be committed

class OpenAIConfig {
  // ⚠️ IMPORTANT: Replace with your actual OpenAI API key
  // Get your API key from: https://platform.openai.com/api-keys
  static const String apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  
  static const String model = 'gpt-3.5-turbo';
  static const String baseUrl = 'https://api.openai.com/v1';
  
  // Endpoints
  static const String chatCompletionsEndpoint = '$baseUrl/chat/completions';
  static const String transcriptionsEndpoint = '$baseUrl/audio/transcriptions';
}
