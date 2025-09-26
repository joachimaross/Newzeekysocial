import 'package:firebase_ai/firebase_ai.dart';
import 'dart:developer' as developer;

/// AI service that handles Firebase AI operations
/// with comprehensive error handling and logging
class AIService {
  final GenerativeModel _model;

  AIService() : _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.5-pro');

  /// Generate text from a prompt using Gemini
  Future<String> generateText(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    try {
      developer.log(
        'Generating text with prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...',
        name: 'zeeky_social.ai',
        level: 800,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      
      final generatedText = response.text ?? 'No response from model.';

      developer.log(
        'Text generation completed successfully (${generatedText.length} characters)',
        name: 'zeeky_social.ai',
        level: 800,
      );

      return generatedText;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate text',
        name: 'zeeky_social.ai',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );

      return 'Error generating text: ${_getErrorMessage(e)}';
    }
  }

  /// Generate text with image input (multimodal)
  Future<String> generateTextWithImage(String prompt, List<int> imageBytes, String mimeType) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }
    
    if (imageBytes.isEmpty) {
      throw ArgumentError('Image data cannot be empty');
    }

    try {
      developer.log(
        'Generating text with image (${imageBytes.length} bytes)',
        name: 'zeeky_social.ai',
        level: 800,
      );

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      final response = await _model.generateContent([content]);
      
      final generatedText = response.text ?? 'No response from model.';

      developer.log(
        'Multimodal text generation completed successfully (${generatedText.length} characters)',
        name: 'zeeky_social.ai',
        level: 800,
      );

      return generatedText;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate text with image',
        name: 'zeeky_social.ai',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );

      return 'Error analyzing image: ${_getErrorMessage(e)}';
    }
  }

  /// Generate a chat response with conversation context
  Future<String> generateChatResponse(List<Content> conversationHistory) async {
    if (conversationHistory.isEmpty) {
      throw ArgumentError('Conversation history cannot be empty');
    }

    try {
      developer.log(
        'Generating chat response with ${conversationHistory.length} messages in context',
        name: 'zeeky_social.ai',
        level: 800,
      );

      final response = await _model.generateContent(conversationHistory);
      
      final generatedText = response.text ?? 'No response from model.';

      developer.log(
        'Chat response generated successfully (${generatedText.length} characters)',
        name: 'zeeky_social.ai',
        level: 800,
      );

      return generatedText;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate chat response',
        name: 'zeeky_social.ai',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );

      return 'Error generating response: ${_getErrorMessage(e)}';
    }
  }

  /// Start a chat session with the AI model
  ChatSession startChat({List<Content>? history}) {
    developer.log(
      'Starting new chat session',
      name: 'zeeky_social.ai',
      level: 800,
    );

    return _model.startChat(history: history);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('quota')) {
      return 'AI service quota exceeded. Please try again later.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please check your API configuration.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
