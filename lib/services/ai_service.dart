
// import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  // final _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

  Future<String> generateText(String prompt) async {
    try {
      // final response = await _model.generateContent([Content.text(prompt)]);
      // return response.text ?? 'No response from model.';
      return 'AI functionality is temporarily disabled due to a build issue.';
    } catch (e) {
      return 'Error generating text: $e';
    }
  }
}
