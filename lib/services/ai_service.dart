
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:developer' as developer;

class AIService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  AIService() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.blockLowAndAbove),
      ],
    );
    _visionModel = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
    );
  }

  Future<String> getResponse(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response from model.';
    } catch (e, s) {
      developer.log(
        'Error generating text',
        name: 'com.example.myapp.AIService',
        error: e,
        stackTrace: s,
      );
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> analyzeImage(String prompt, Uint8List imageData) async {
    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageData),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'No response from model.';
    } catch (e, s) {
      developer.log(
        'Error analyzing image',
        name: 'com.example.myapp.AIService',
        error: e,
        stackTrace: s,
      );
      return 'Error: ${e.toString()}';
    }
  }
}
