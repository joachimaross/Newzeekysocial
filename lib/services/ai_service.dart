import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  late final ChatSession _chat;

  static const String _systemPrompt =
      "You are Zeeky, a friendly, helpful, and slightly witty AI assistant for the social media app 'Zeeky Social'. You are here to help users, answer their questions, and make their experience more enjoyable. Your tone should be conversational and engaging. You should be slightly informal but always respectful. Never break character.";

  AIService() {
    // Get the model with the system prompt
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.text(_systemPrompt),
    );
    // Start a new chat session
    _chat = model.startChat();
  }

  Future<String> getResponse(String prompt) async {
    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      return response.text ?? 'I\'m not sure what to say. Could you try rephrasing?';
    } catch (e) {
      return 'Oops! Something went wrong on my end. Please try again. Error: $e';
    }
  }
}
