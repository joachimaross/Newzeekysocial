import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  final _model = FirebaseAI.vertexAI().generativeModel(model: 'gemini-1.5-flash');

  Future<String> generateText(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response from model.';
    } catch (e) {
      return 'Error generating text: $e';
    }
  }
}
