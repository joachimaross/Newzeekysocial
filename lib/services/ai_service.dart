import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';

enum AIFeature {
  chat,
  smart_replies,
  content_generation,
  summarization,
  translation,
  image_analysis,
  image_generation,
  voice_to_text,
  text_to_speech,
  content_moderation,
  hashtag_suggestions,
  caption_generation,
}

class SmartReply {
  final String text;
  final double confidence;
  final Map<String, dynamic> metadata;

  SmartReply({
    required this.text,
    required this.confidence,
    this.metadata = const {},
  });
}

class AIContent {
  final String content;
  final String type;
  final Map<String, dynamic> metadata;
  final double quality;

  AIContent({
    required this.content,
    required this.type,
    this.metadata = const {},
    this.quality = 1.0,
  });
}

class AIService {
  final _textModel = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.5-pro');
  final _visionModel = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.5-pro');
  final _imagenModel = FirebaseAI.vertexAI().imagenModel();
  final _embeddingModel = FirebaseAI.vertexAI().embeddingModel(model: 'text-embedding-004');

  // Chat and conversation
  Future<String> generateText(String prompt, {AIFeature feature = AIFeature.chat}) async {
    try {
      String systemPrompt = _getSystemPrompt(feature);
      String fullPrompt = systemPrompt.isNotEmpty ? '$systemPrompt\n\n$prompt' : prompt;
      
      final response = await _textModel.generateContent([Content.text(fullPrompt)]);
      return response.text ?? 'No response from model.';
    } catch (e) {
      return 'Error generating text: $e';
    }
  }

  // Smart replies for messages
  Future<List<SmartReply>> generateSmartReplies(String messageContent, {int count = 3}) async {
    try {
      final prompt = '''
      Generate $count smart, contextually appropriate replies to this message: "$messageContent"
      
      Make the replies:
      - Natural and conversational
      - Varied in tone (supportive, questioning, humorous)
      - Short and easy to send
      - Appropriate for the context
      
      Format each reply on a new line starting with "REPLY:"
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      final replies = <SmartReply>[];
      final lines = text.split('\n');
      
      for (final line in lines) {
        if (line.startsWith('REPLY:')) {
          final replyText = line.substring(6).trim();
          if (replyText.isNotEmpty) {
            replies.add(SmartReply(
              text: replyText,
              confidence: 0.8,
              metadata: {'generated_at': DateTime.now().toIso8601String()},
            ));
          }
        }
      }
      
      return replies.take(count).toList();
    } catch (e) {
      print('Error generating smart replies: $e');
      return [];
    }
  }

  // Content generation for posts
  Future<AIContent> generatePostContent(String topic, {String style = 'casual'}) async {
    try {
      final prompt = '''
      Create an engaging social media post about: $topic
      
      Style: $style
      Requirements:
      - Keep it under 280 characters
      - Make it engaging and shareable
      - Include relevant emojis
      - Suggest 3-5 hashtags at the end
      
      Format:
      POST: [your post content]
      HASHTAGS: [hashtag1] [hashtag2] [hashtag3]
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      String postContent = '';
      String hashtags = '';
      
      final lines = text.split('\n');
      for (final line in lines) {
        if (line.startsWith('POST:')) {
          postContent = line.substring(5).trim();
        } else if (line.startsWith('HASHTAGS:')) {
          hashtags = line.substring(9).trim();
        }
      }

      return AIContent(
        content: postContent,
        type: 'post',
        metadata: {
          'hashtags': hashtags,
          'topic': topic,
          'style': style,
        },
        quality: 0.85,
      );
    } catch (e) {
      print('Error generating post content: $e');
      return AIContent(
        content: 'Unable to generate content at this time.',
        type: 'error',
      );
    }
  }

  // Text summarization
  Future<String> summarizeText(String text, {int maxLength = 100}) async {
    try {
      final prompt = '''
      Summarize the following text in approximately $maxLength characters or less.
      Keep the key points and main ideas.
      
      Text to summarize:
      "$text"
      
      Summary:
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to summarize text.';
    } catch (e) {
      return 'Error summarizing text: $e';
    }
  }

  // Language translation
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final prompt = '''
      Translate the following text to $targetLanguage.
      Maintain the original tone and meaning.
      
      Text to translate: "$text"
      
      Translation:
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to translate text.';
    } catch (e) {
      return 'Error translating text: $e';
    }
  }

  // Image analysis and description
  Future<String> analyzeImage(Uint8List imageData, String prompt) async {
    try {
      final content = Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageData),
      ]);

      final response = await _visionModel.generateContent([content]);
      return response.text ?? 'Unable to analyze image.';
    } catch (e) {
      return 'Error analyzing image: $e';
    }
  }

  // Generate image captions
  Future<String> generateImageCaption(Uint8List imageData) async {
    return analyzeImage(imageData, '''
    Analyze this image and generate an engaging social media caption.
    Make it descriptive, interesting, and suitable for sharing.
    Include relevant emojis and suggest appropriate mood or context.
    Keep it under 150 characters.
    ''');
  }

  // Generate hashtags for content
  Future<List<String>> generateHashtags(String content, {int count = 5}) async {
    try {
      final prompt = '''
      Generate $count relevant hashtags for this social media content:
      "$content"
      
      Requirements:
      - Make hashtags specific and relevant
      - Mix popular and niche hashtags
      - No spaces, use camelCase for multi-word hashtags
      - Don't include the # symbol
      
      Format each hashtag on a new line starting with "TAG:"
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      final hashtags = <String>[];
      final lines = text.split('\n');
      
      for (final line in lines) {
        if (line.startsWith('TAG:')) {
          final tag = line.substring(4).trim().replaceAll('#', '');
          if (tag.isNotEmpty) {
            hashtags.add(tag);
          }
        }
      }
      
      return hashtags.take(count).toList();
    } catch (e) {
      print('Error generating hashtags: $e');
      return [];
    }
  }

  // Generate image from text prompt
  Future<List<ImageData>> generateImage(String prompt, {int numberOfImages = 1}) async {
    try {
      final result = await _imagenModel.generateImages(
        prompt: prompt,
        numberOfImages: numberOfImages,
      );
      return result;
    } catch (e) {
      print('Error generating image: $e');
      return [];
    }
  }

  // Enhanced image generation with style
  Future<List<ImageData>> generateStyledImage(
    String prompt, 
    String style, 
    {int numberOfImages = 1}
  ) async {
    final styledPrompt = '''
    $prompt
    
    Style: $style
    High quality, professional, suitable for social media sharing.
    ''';
    
    return generateImage(styledPrompt, numberOfImages: numberOfImages);
  }

  // Generate text embeddings for semantic search
  Future<List<double>?> generateEmbedding(String text) async {
    try {
      final result = await _embeddingModel.embedContent([Content.text(text)]);
      return result.embeddings.first.values;
    } catch (e) {
      print('Error generating embedding: $e');
      return null;
    }
  }

  // Content enhancement suggestions
  Future<Map<String, dynamic>> enhanceContent(String content) async {
    try {
      final prompt = '''
      Analyze this social media content and provide enhancement suggestions:
      "$content"
      
      Provide suggestions for:
      1. Grammar and spelling corrections
      2. Tone improvements
      3. Engagement optimization
      4. Hashtag suggestions
      5. Emoji recommendations
      
      Format your response as structured suggestions.
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final suggestions = response.text ?? '';
      
      return {
        'original': content,
        'suggestions': suggestions,
        'enhanced': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error enhancing content: $e');
      return {'error': 'Unable to enhance content'};
    }
  }

  // Generate conversation starters
  Future<List<String>> generateConversationStarters(String topic) async {
    try {
      final prompt = '''
      Generate 5 interesting conversation starters about: $topic
      
      Make them:
      - Thought-provoking
      - Open-ended questions
      - Suitable for social media discussion
      - Engaging and friendly
      
      Format each starter on a new line starting with "STARTER:"
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      final starters = <String>[];
      final lines = text.split('\n');
      
      for (final line in lines) {
        if (line.startsWith('STARTER:')) {
          final starter = line.substring(8).trim();
          if (starter.isNotEmpty) {
            starters.add(starter);
          }
        }
      }
      
      return starters;
    } catch (e) {
      print('Error generating conversation starters: $e');
      return [];
    }
  }

  // Mood detection and response
  Future<Map<String, dynamic>> detectMood(String text) async {
    try {
      final prompt = '''
      Analyze the mood and sentiment of this text:
      "$text"
      
      Provide:
      1. Overall mood (happy, sad, excited, angry, neutral, etc.)
      2. Sentiment score (1-10, where 1 is very negative, 10 is very positive)
      3. Emotional keywords found
      4. Suggested response tone
      
      Format as JSON structure.
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      
      // In production, parse the JSON response properly
      return {
        'analysis': response.text,
        'analyzed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error detecting mood: $e');
      return {'error': 'Unable to analyze mood'};
    }
  }

  // Private helper methods
  String _getSystemPrompt(AIFeature feature) {
    switch (feature) {
      case AIFeature.chat:
        return '''
        You are Zeeky, the friendly AI assistant for Zeeky Social.
        Be helpful, conversational, and engaging.
        Keep responses concise but informative.
        Use emojis appropriately to add personality.
        ''';
        
      case AIFeature.smart_replies:
        return '''
        Generate natural, contextually appropriate replies.
        Keep them short, friendly, and conversational.
        Vary the tone and style for different options.
        ''';
        
      case AIFeature.content_generation:
        return '''
        Create engaging, shareable social media content.
        Focus on authenticity and value to the audience.
        Use appropriate hashtags and emojis.
        ''';
        
      case AIFeature.content_moderation:
        return '''
        You are a content moderation assistant.
        Be precise and objective in your analysis.
        Focus on safety and community guidelines.
        ''';
        
      default:
        return '';
    }
  }
}
