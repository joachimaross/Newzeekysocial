import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:zeeky_social/services/ai_service.dart';

enum ContentType { post, story, reel, meme, challenge }
enum ContentStyle { casual, professional, humorous, inspirational, trendy, educational }
enum Language { english, spanish, french, german, italian, portuguese, japanese, chinese }

class ContentTemplate {
  final String id;
  final String name;
  final String description;
  final ContentType type;
  final Map<String, String> placeholders;
  final List<String> suggestedHashtags;

  ContentTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.placeholders,
    this.suggestedHashtags = const [],
  });
}

class MemeData {
  final String templateId;
  final String topText;
  final String bottomText;
  final String imagePrompt;
  final List<String> hashtags;

  MemeData({
    required this.templateId,
    required this.topText,
    required this.bottomText,
    required this.imagePrompt,
    this.hashtags = const [],
  });
}

class ChallengeData {
  final String id;
  final String title;
  final String description;
  final String instructions;
  final List<String> hashtags;
  final int duration; // in days
  final String category;

  ChallengeData({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    required this.hashtags,
    required this.duration,
    required this.category,
  });
}

class ContentStudioResult {
  final String content;
  final ContentType type;
  final List<String> hashtags;
  final List<String> captions;
  final Map<String, dynamic> metadata;
  final double engagementScore;
  final List<ImageData>? generatedImages;
  final MemeData? memeData;
  final ChallengeData? challengeData;

  ContentStudioResult({
    required this.content,
    required this.type,
    required this.hashtags,
    required this.captions,
    this.metadata = const {},
    this.engagementScore = 0.0,
    this.generatedImages,
    this.memeData,
    this.challengeData,
  });
}

class ContentStudioService {
  final AIService _aiService = AIService();
  final _textModel = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.5-pro');
  final _imagenModel = FirebaseAI.vertexAI().imagenModel();

  // Supported languages for translation
  final Map<Language, String> _languageCodes = {
    Language.english: 'en',
    Language.spanish: 'es', 
    Language.french: 'fr',
    Language.german: 'de',
    Language.italian: 'it',
    Language.portuguese: 'pt',
    Language.japanese: 'ja',
    Language.chinese: 'zh',
  };

  // Predefined meme templates
  final List<ContentTemplate> _memeTemplates = [
    ContentTemplate(
      id: 'drake_pointing',
      name: 'Drake Pointing',
      description: 'Classic Drake meme format',
      type: ContentType.meme,
      placeholders: {'rejection': '', 'approval': ''},
      suggestedHashtags: ['meme', 'drake', 'choice'],
    ),
    ContentTemplate(
      id: 'distracted_boyfriend',
      name: 'Distracted Boyfriend',
      description: 'Distracted boyfriend meme format',
      type: ContentType.meme,
      placeholders: {'boyfriend': '', 'girlfriend': '', 'other_woman': ''},
      suggestedHashtags: ['meme', 'distracted', 'choice'],
    ),
    ContentTemplate(
      id: 'woman_yelling_cat',
      name: 'Woman Yelling at Cat',
      description: 'Woman yelling at cat meme format',
      type: ContentType.meme,
      placeholders: {'woman_text': '', 'cat_text': ''},
      suggestedHashtags: ['meme', 'argument', 'cat'],
    ),
  ];

  // Generate comprehensive social content
  Future<ContentStudioResult> generateContent({
    required String prompt,
    required ContentType type,
    ContentStyle style = ContentStyle.casual,
    Language language = Language.english,
    bool includeImages = false,
    bool includeHashtags = true,
    bool includeCaptions = true,
    int maxVariations = 3,
  }) async {
    try {
      final baseContent = await _generateBaseContent(prompt, type, style, language);
      final hashtags = includeHashtags ? await _generateHashtags(baseContent, type) : <String>[];
      final captions = includeCaptions ? await _generateCaptions(baseContent, type, maxVariations) : <String>[];
      
      List<ImageData>? images;
      if (includeImages) {
        images = await _generateContentImages(baseContent, type, style);
      }

      final engagementScore = await _calculateEngagementScore(baseContent, hashtags, type);

      return ContentStudioResult(
        content: baseContent,
        type: type,
        hashtags: hashtags,
        captions: captions,
        generatedImages: images,
        engagementScore: engagementScore,
        metadata: {
          'style': style.toString(),
          'language': language.toString(),
          'generated_at': DateTime.now().toIso8601String(),
          'prompt': prompt,
        },
      );
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  // Generate memes based on current trends
  Future<ContentStudioResult> generateMeme({
    required String topic,
    String? templateId,
    ContentStyle style = ContentStyle.humorous,
    Language language = Language.english,
  }) async {
    try {
      final template = templateId != null 
          ? _memeTemplates.firstWhere((t) => t.id == templateId)
          : _memeTemplates[DateTime.now().millisecond % _memeTemplates.length];

      final memeContent = await _generateMemeContent(topic, template, style, language);
      final imagePrompt = await _generateMemeImagePrompt(memeContent, template);
      final images = await _generateMemeImages(imagePrompt);
      
      final memeData = MemeData(
        templateId: template.id,
        topText: memeContent['top_text'] ?? '',
        bottomText: memeContent['bottom_text'] ?? '',
        imagePrompt: imagePrompt,
        hashtags: [...template.suggestedHashtags, 'meme', topic.toLowerCase().replaceAll(' ', '')],
      );

      return ContentStudioResult(
        content: '${memeData.topText}\n${memeData.bottomText}',
        type: ContentType.meme,
        hashtags: memeData.hashtags,
        captions: [memeData.topText, memeData.bottomText],
        generatedImages: images,
        memeData: memeData,
        engagementScore: 0.9, // Memes typically have high engagement
        metadata: {
          'template': template.name,
          'topic': topic,
          'generated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to generate meme: $e');
    }
  }

  // Generate social challenges
  Future<ContentStudioResult> generateChallenge({
    required String category,
    required int duration,
    ContentStyle style = ContentStyle.inspirational,
    Language language = Language.english,
  }) async {
    try {
      final challengePrompt = '''
      Create an engaging social media challenge for the category: $category
      Duration: $duration days
      Style: $style
      Language: ${_getLanguageName(language)}
      
      Generate:
      1. Challenge title (catchy and memorable)
      2. Description (what it's about)
      3. Clear instructions (step by step)
      4. Relevant hashtags
      5. Engagement hooks
      
      Format:
      TITLE: [challenge title]
      DESCRIPTION: [challenge description]
      INSTRUCTIONS: [step by step instructions]
      HASHTAGS: [hashtag1] [hashtag2] [hashtag3]
      HOOK: [engagement hook]
      ''';

      final response = await _textModel.generateContent([Content.text(challengePrompt)]);
      final text = response.text ?? '';
      
      final challengeData = _parseChallengeResponse(text);
      final images = await _generateChallengeImages(challengeData.title, category);

      return ContentStudioResult(
        content: challengeData.description,
        type: ContentType.challenge,
        hashtags: challengeData.hashtags,
        captions: [challengeData.title, challengeData.instructions],
        generatedImages: images,
        challengeData: challengeData,
        engagementScore: 0.85,
        metadata: {
          'category': category,
          'duration': duration,
          'generated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to generate challenge: $e');
    }
  }

  // Auto-translate content to multiple languages
  Future<Map<Language, String>> translateContent(String content, List<Language> targetLanguages) async {
    final translations = <Language, String>{};
    
    for (final language in targetLanguages) {
      try {
        final languageName = _getLanguageName(language);
        final translated = await _aiService.translateText(content, languageName);
        translations[language] = translated;
      } catch (e) {
        translations[language] = 'Translation failed: $e';
      }
    }
    
    return translations;
  }

  // Content remixing for cross-platform adaptation
  Future<Map<String, String>> remixForPlatforms(String content, List<String> platforms) async {
    final remixed = <String, String>{};
    
    for (final platform in platforms) {
      try {
        final prompt = '''
        Adapt this content for $platform:
        "$content"
        
        Consider platform-specific:
        - Character limits
        - Audience behavior
        - Content format preferences
        - Engagement patterns
        
        Optimized content:
        ''';

        final response = await _textModel.generateContent([Content.text(prompt)]);
        remixed[platform] = response.text ?? content;
      } catch (e) {
        remixed[platform] = content; // Fallback to original
      }
    }
    
    return remixed;
  }

  // Generate trending hashtag suggestions
  Future<List<String>> generateTrendingHashtags(String content, {int count = 10}) async {
    try {
      final prompt = '''
      Generate $count trending and relevant hashtags for this content:
      "$content"
      
      Include:
      - 3-4 trending general hashtags
      - 3-4 niche-specific hashtags
      - 2-3 community hashtags
      
      Requirements:
      - Research current trends
      - Mix popular and emerging hashtags
      - Ensure relevance to content
      - Use camelCase for multi-word tags
      - No # symbol
      
      Format each hashtag on a new line starting with "TAG:"
      ''';

      return await _aiService.generateHashtags(content, count: count);
    } catch (e) {
      return [];
    }
  }

  // Enhanced auto-caption with multiple variations
  Future<List<String>> generateMultipleCaptions(
    Uint8List imageData, 
    {int variations = 3, ContentStyle style = ContentStyle.casual}
  ) async {
    final captions = <String>[];
    
    for (int i = 0; i < variations; i++) {
      try {
        final stylePrompt = _getStylePrompt(style, i);
        final caption = await _aiService.analyzeImage(imageData, '''
        $stylePrompt
        Analyze this image and create an engaging social media caption.
        Make it unique from previous variations.
        Include relevant emojis and context.
        Keep it under 150 characters.
        ''');
        captions.add(caption);
      } catch (e) {
        captions.add('Caption generation failed');
      }
    }
    
    return captions;
  }

  // Private helper methods
  Future<String> _generateBaseContent(String prompt, ContentType type, ContentStyle style, Language language) async {
    final typePrompt = _getContentTypePrompt(type);
    final stylePrompt = _getContentStylePrompt(style);
    final languagePrompt = _getLanguageName(language);
    
    final fullPrompt = '''
    $typePrompt
    $stylePrompt
    
    Create content in $languagePrompt about: $prompt
    
    Requirements:
    - Engaging and shareable
    - Platform-optimized
    - Include relevant context
    - Appropriate tone and style
    ''';

    return await _aiService.generateText(fullPrompt);
  }

  Future<List<String>> _generateHashtags(String content, ContentType type) async {
    final typeSpecific = _getTypeHashtags(type);
    final generated = await _aiService.generateHashtags(content, count: 8);
    return [...typeSpecific, ...generated].take(10).toList();
  }

  Future<List<String>> _generateCaptions(String content, ContentType type, int count) async {
    final captions = <String>[];
    for (int i = 0; i < count; i++) {
      try {
        final prompt = '''
        Create a variation of this caption (variation ${i + 1}):
        "$content"
        
        Make it:
        - Unique and engaging
        - Suitable for ${type.toString()}
        - Different tone/approach
        ''';
        
        final response = await _textModel.generateContent([Content.text(prompt)]);
        captions.add(response.text ?? content);
      } catch (e) {
        captions.add(content);
      }
    }
    return captions;
  }

  Future<List<ImageData>?> _generateContentImages(String content, ContentType type, ContentStyle style) async {
    try {
      final imagePrompt = '''
      Create a high-quality image for ${type.toString()} content with ${style.toString()} style:
      "$content"
      
      Style requirements:
      - Professional and engaging
      - Suitable for social media
      - High visual appeal
      - Brand-safe content
      ''';

      return await _aiService.generateImage(imagePrompt, numberOfImages: 1);
    } catch (e) {
      return null;
    }
  }

  Future<double> _calculateEngagementScore(String content, List<String> hashtags, ContentType type) async {
    try {
      final prompt = '''
      Analyze this social media content for potential engagement:
      Content: "$content"
      Hashtags: ${hashtags.join(', ')}
      Type: ${type.toString()}
      
      Rate engagement potential (0.0-1.0) based on:
      - Content quality and appeal
      - Hashtag relevance and popularity
      - Content type performance
      - Shareability factors
      
      Return only the numerical score (e.g., 0.85):
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final scoreText = response.text?.trim() ?? '0.5';
      return double.tryParse(scoreText) ?? 0.5;
    } catch (e) {
      return 0.5; // Default score
    }
  }

  // Meme generation helpers
  Future<Map<String, String>> _generateMemeContent(String topic, ContentTemplate template, ContentStyle style, Language language) async {
    final prompt = '''
    Create meme text for "${template.name}" format about: $topic
    Style: $style
    Language: ${_getLanguageName(language)}
    
    Template format: ${template.description}
    Required fields: ${template.placeholders.keys.join(', ')}
    
    Make it:
    - Funny and relatable
    - Current and trendy
    - Appropriate for social sharing
    
    Format your response with clear labels for each field.
    ''';

    final response = await _textModel.generateContent([Content.text(prompt)]);
    return _parseMemeContent(response.text ?? '', template);
  }

  Future<String> _generateMemeImagePrompt(Map<String, String> memeContent, ContentTemplate template) async {
    return '''
    Generate image for ${template.name} meme template.
    Template: ${template.description}
    Text content: ${memeContent.values.join(' / ')}
    
    Style: Clean, meme-appropriate, high contrast text overlay suitable.
    ''';
  }

  Future<List<ImageData>> _generateMemeImages(String imagePrompt) async {
    return await _aiService.generateImage(imagePrompt) ?? [];
  }

  ChallengeData _parseChallengeResponse(String response) {
    final lines = response.split('\n');
    String title = '';
    String description = '';
    String instructions = '';
    List<String> hashtags = [];
    
    for (final line in lines) {
      if (line.startsWith('TITLE:')) {
        title = line.substring(6).trim();
      } else if (line.startsWith('DESCRIPTION:')) {
        description = line.substring(12).trim();
      } else if (line.startsWith('INSTRUCTIONS:')) {
        instructions = line.substring(13).trim();
      } else if (line.startsWith('HASHTAGS:')) {
        final hashtagLine = line.substring(9).trim();
        hashtags = hashtagLine.split(' ').where((h) => h.isNotEmpty).toList();
      }
    }

    return ChallengeData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      instructions: instructions,
      hashtags: hashtags,
      duration: 7, // Default duration
      category: 'general',
    );
  }

  Future<List<ImageData>?> _generateChallengeImages(String title, String category) async {
    final imagePrompt = '''
    Create an inspiring image for social media challenge:
    Title: "$title"
    Category: $category
    
    Style: Motivational, colorful, engaging, with space for text overlay.
    ''';

    return await _aiService.generateImage(imagePrompt);
  }

  Map<String, String> _parseMemeContent(String response, ContentTemplate template) {
    // Simple parsing - in production, use more robust parsing
    final content = <String, String>{};
    final lines = response.split('\n');
    
    for (final key in template.placeholders.keys) {
      for (final line in lines) {
        if (line.toLowerCase().contains(key.toLowerCase())) {
          content[key] = line.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
          break;
        }
      }
    }
    
    return content;
  }

  String _getLanguageName(Language language) {
    switch (language) {
      case Language.english: return 'English';
      case Language.spanish: return 'Spanish';
      case Language.french: return 'French';
      case Language.german: return 'German';
      case Language.italian: return 'Italian';
      case Language.portuguese: return 'Portuguese';
      case Language.japanese: return 'Japanese';
      case Language.chinese: return 'Chinese';
    }
  }

  String _getContentTypePrompt(ContentType type) {
    switch (type) {
      case ContentType.post:
        return 'Create a social media post that is engaging and shareable.';
      case ContentType.story:
        return 'Create story content that is immediate and personal.';
      case ContentType.reel:
        return 'Create short-form video content description that is trendy and viral.';
      case ContentType.meme:
        return 'Create humorous meme content that is relatable and shareable.';
      case ContentType.challenge:
        return 'Create challenge content that encourages participation.';
    }
  }

  String _getContentStylePrompt(ContentStyle style) {
    switch (style) {
      case ContentStyle.casual:
        return 'Use a casual, friendly, and approachable tone.';
      case ContentStyle.professional:
        return 'Use a professional, polished, and authoritative tone.';
      case ContentStyle.humorous:
        return 'Use a humorous, witty, and entertaining tone.';
      case ContentStyle.inspirational:
        return 'Use an inspirational, motivating, and uplifting tone.';
      case ContentStyle.trendy:
        return 'Use a trendy, current, and hip tone with latest slang.';
      case ContentStyle.educational:
        return 'Use an educational, informative, and helpful tone.';
    }
  }

  String _getStylePrompt(ContentStyle style, int variation) {
    final basePrompt = _getContentStylePrompt(style);
    final variations = [
      'Focus on emotional connection.',
      'Emphasize visual appeal.',
      'Highlight community aspect.',
    ];
    
    return '$basePrompt ${variations[variation % variations.length]}';
  }

  List<String> _getTypeHashtags(ContentType type) {
    switch (type) {
      case ContentType.post:
        return ['social', 'community', 'share'];
      case ContentType.story:
        return ['story', 'moment', 'life'];
      case ContentType.reel:
        return ['reel', 'video', 'trending'];
      case ContentType.meme:
        return ['meme', 'funny', 'humor'];
      case ContentType.challenge:
        return ['challenge', 'participate', 'community'];
    }
  }
}