import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:zeeky_social/services/content_studio_service.dart';

class MockContentStudioService extends ContentStudioService {
  final Random _random = Random();
  final bool _useMockData;

  MockContentStudioService({bool useMockData = false}) : _useMockData = useMockData;

  // Mock data for testing
  final List<String> _mockPosts = [
    "Just had an amazing coffee this morning! ☕ Starting the day right with positive vibes 🌟",
    "Working on something exciting today! Can't wait to share more details soon 🚀",
    "Beautiful sunset tonight 🌅 Sometimes we need to pause and appreciate the simple things in life",
    "Learning something new every day keeps life interesting 📚 What did you learn today?",
    "Weekend vibes are the best vibes! 🎉 How are you spending your weekend?",
  ];

  final List<String> _mockHashtags = [
    'trending', 'viral', 'content', 'social', 'ai', 'creative', 'inspiration',
    'motivation', 'lifestyle', 'tech', 'innovation', 'community', 'share',
    'explore', 'discover', 'amazing', 'awesome', 'cool', 'fun', 'love',
  ];

  final Map<String, List<String>> _mockMemeTemplates = {
    'drake_pointing': [
      'When someone suggests manual work',
      'When someone mentions AI automation',
    ],
    'distracted_boyfriend': [
      'Me looking at new social media trends',
      'My current content strategy',
      'AI-generated content',
    ],
    'woman_yelling_cat': [
      'You need to post more consistently!',
      'Me just trying to enjoy my content',
    ],
  };

  final List<Map<String, dynamic>> _mockChallenges = [
    {
      'title': '7-Day Fitness Challenge',
      'description': 'Transform your daily routine with simple fitness activities',
      'instructions': 'Do 10 minutes of exercise each day for 7 days. Share your progress!',
      'hashtags': ['fitness', 'health', 'challenge', 'transformation'],
      'category': 'fitness',
    },
    {
      'title': 'Creative Writing Sprint',
      'description': 'Unlock your creativity with daily writing prompts',
      'instructions': 'Write for 15 minutes each day using our daily prompt. Share your favorite line!',
      'hashtags': ['writing', 'creativity', 'challenge', 'inspiration'],
      'category': 'creativity',
    },
    {
      'title': 'Mindfulness Moments',
      'description': 'Practice daily mindfulness for better mental health',
      'instructions': 'Take 5 minutes each day for mindful breathing. Share your experience!',
      'hashtags': ['mindfulness', 'mentalhealth', 'wellness', 'meditation'],
      'category': 'wellness',
    },
  ];

  final Map<String, String> _mockTranslations = {
    'spanish': 'Hola mundo! Este es contenido traducido automáticamente.',
    'french': 'Bonjour le monde! Ceci est du contenu traduit automatiquement.',
    'german': 'Hallo Welt! Dies ist automatisch übersetzter Inhalt.',
    'italian': 'Ciao mondo! Questo è contenuto tradotto automaticamente.',
    'portuguese': 'Olá mundo! Este é conteúdo traduzido automaticamente.',
    'japanese': 'こんにちは世界！これは自動翻訳されたコンテンツです。',
    'chinese': '你好世界！这是自动翻译的内容。',
  };

  final Map<String, String> _mockPlatformAdaptations = {
    'Twitter': 'Short, punchy version with trending hashtags #TwitterTip 🐦',
    'Instagram': 'Visual-focused version with emojis and storytelling 📸 Perfect for your feed!',
    'LinkedIn': 'Professional take with industry insights and thought leadership angle 💼',
    'TikTok': 'Fun, energetic version perfect for short-form video content 🎵 #TikTokTrend',
    'Facebook': 'Community-focused version encouraging discussion and engagement 👥',
    'YouTube': 'Long-form content idea with educational value and viewer engagement 🎥',
  };

  @override
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
    if (_useMockData) {
      return _generateMockContent(prompt, type, style, language, includeImages, includeHashtags, includeCaptions, maxVariations);
    }
    return await super.generateContent(
      prompt: prompt,
      type: type,
      style: style,
      language: language,
      includeImages: includeImages,
      includeHashtags: includeHashtags,
      includeCaptions: includeCaptions,
      maxVariations: maxVariations,
    );
  }

  @override
  Future<ContentStudioResult> generateMeme({
    required String topic,
    String? templateId,
    ContentStyle style = ContentStyle.humorous,
    Language language = Language.english,
  }) async {
    if (_useMockData) {
      return _generateMockMeme(topic, templateId, style, language);
    }
    return await super.generateMeme(
      topic: topic,
      templateId: templateId,
      style: style,
      language: language,
    );
  }

  @override
  Future<ContentStudioResult> generateChallenge({
    required String category,
    required int duration,
    ContentStyle style = ContentStyle.inspirational,
    Language language = Language.english,
  }) async {
    if (_useMockData) {
      return _generateMockChallenge(category, duration, style, language);
    }
    return await super.generateChallenge(
      category: category,
      duration: duration,
      style: style,
      language: language,
    );
  }

  @override
  Future<Map<Language, String>> translateContent(String content, List<Language> targetLanguages) async {
    if (_useMockData) {
      return _generateMockTranslations(content, targetLanguages);
    }
    return await super.translateContent(content, targetLanguages);
  }

  @override
  Future<Map<String, String>> remixForPlatforms(String content, List<String> platforms) async {
    if (_useMockData) {
      return _generateMockPlatformAdaptations(content, platforms);
    }
    return await super.remixForPlatforms(content, platforms);
  }

  @override
  Future<List<String>> generateTrendingHashtags(String content, {int count = 10}) async {
    if (_useMockData) {
      return _generateMockHashtags(count);
    }
    return await super.generateTrendingHashtags(content, count: count);
  }

  // Mock generation methods
  Future<ContentStudioResult> _generateMockContent(
    String prompt, 
    ContentType type, 
    ContentStyle style, 
    Language language,
    bool includeImages, 
    bool includeHashtags, 
    bool includeCaptions, 
    int maxVariations
  ) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));

    final mockContent = _mockPosts[_random.nextInt(_mockPosts.length)];
    final mockHashtags = includeHashtags ? _generateMockHashtags(5) : <String>[];
    final mockCaptions = includeCaptions ? List.generate(maxVariations, (i) => 
        '${mockContent} (Variation ${i + 1})') : <String>[];

    List<ImageData>? mockImages;
    if (includeImages) {
      mockImages = [_generateMockImageData()];
    }

    return ContentStudioResult(
      content: '$mockContent\n\nGenerated for: $prompt\nType: ${type.toString()}\nStyle: ${style.toString()}',
      type: type,
      hashtags: mockHashtags,
      captions: mockCaptions,
      generatedImages: mockImages,
      engagementScore: 0.7 + _random.nextDouble() * 0.3, // 0.7-1.0
      metadata: {
        'mock': true,
        'prompt': prompt,
        'style': style.toString(),
        'language': language.toString(),
        'generated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<ContentStudioResult> _generateMockMeme(
    String topic, 
    String? templateId, 
    ContentStyle style, 
    Language language
  ) async {
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(2000)));

    final template = templateId ?? _mockMemeTemplates.keys.first;
    final templateData = _mockMemeTemplates[template] ?? ['Top text', 'Bottom text'];
    
    final memeData = MemeData(
      templateId: template,
      topText: '${templateData[0]} - $topic',
      bottomText: templateData.length > 1 ? '${templateData[1]} - $topic' : 'Bottom text about $topic',
      imagePrompt: 'Mock meme image for $template about $topic',
      hashtags: ['meme', 'funny', topic.toLowerCase().replaceAll(' ', ''), 'humor'],
    );

    return ContentStudioResult(
      content: '${memeData.topText}\n${memeData.bottomText}',
      type: ContentType.meme,
      hashtags: memeData.hashtags,
      captions: [memeData.topText, memeData.bottomText],
      generatedImages: [_generateMockImageData()],
      memeData: memeData,
      engagementScore: 0.9, // Memes have high engagement
      metadata: {
        'mock': true,
        'template': template,
        'topic': topic,
        'generated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<ContentStudioResult> _generateMockChallenge(
    String category, 
    int duration, 
    ContentStyle style, 
    Language language
  ) async {
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(1000)));

    final mockChallenge = _mockChallenges.firstWhere(
      (c) => c['category'] == category.toLowerCase(),
      orElse: () => _mockChallenges[_random.nextInt(_mockChallenges.length)],
    );

    final challengeData = ChallengeData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${mockChallenge['title']} - $duration Day Edition',
      description: '${mockChallenge['description']} Custom tailored for $category enthusiasts.',
      instructions: '${mockChallenge['instructions']} Duration: $duration days.',
      hashtags: [...mockChallenge['hashtags'], '${duration}day', 'challenge$category'],
      duration: duration,
      category: category,
    );

    return ContentStudioResult(
      content: challengeData.description,
      type: ContentType.challenge,
      hashtags: challengeData.hashtags.cast<String>(),
      captions: [challengeData.title, challengeData.instructions],
      generatedImages: [_generateMockImageData()],
      challengeData: challengeData,
      engagementScore: 0.85,
      metadata: {
        'mock': true,
        'category': category,
        'duration': duration,
        'generated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Map<Language, String>> _generateMockTranslations(String content, List<Language> targetLanguages) async {
    await Future.delayed(Duration(milliseconds: 500 * targetLanguages.length));

    final translations = <Language, String>{};
    for (final language in targetLanguages) {
      final langKey = language.toString().split('.').last;
      translations[language] = _mockTranslations[langKey] ?? 'Mock translation for $langKey: $content';
    }
    return translations;
  }

  Future<Map<String, String>> _generateMockPlatformAdaptations(String content, List<String> platforms) async {
    await Future.delayed(Duration(milliseconds: 300 * platforms.length));

    final adaptations = <String, String>{};
    for (final platform in platforms) {
      adaptations[platform] = _mockPlatformAdaptations[platform] ?? 
          'Adapted for $platform: $content (optimized for platform-specific audience)';
    }
    return adaptations;
  }

  List<String> _generateMockHashtags(int count) {
    final selected = <String>[];
    final available = List<String>.from(_mockHashtags);
    
    while (selected.length < count && available.isNotEmpty) {
      final index = _random.nextInt(available.length);
      selected.add(available.removeAt(index));
    }
    
    return selected;
  }

  ImageData _generateMockImageData() {
    // Create a simple colored rectangle as mock image
    final width = 400;
    final height = 300;
    final bytes = Uint8List(width * height * 3); // RGB
    
    // Fill with random color
    final r = _random.nextInt(256);
    final g = _random.nextInt(256);
    final b = _random.nextInt(256);
    
    for (int i = 0; i < bytes.length; i += 3) {
      bytes[i] = r;
      bytes[i + 1] = g;
      bytes[i + 2] = b;
    }

    return ImageData(bytes: bytes);
  }

  // Static test data for unit tests
  static Map<String, dynamic> getSampleInputOutput() {
    return {
      'inputs': {
        'generateContent': {
          'prompt': 'coffee morning routine',
          'type': 'post',
          'style': 'casual',
          'language': 'english',
          'includeImages': true,
          'includeHashtags': true,
          'includeCaptions': true,
          'maxVariations': 3,
        },
        'generateMeme': {
          'topic': 'monday mornings',
          'templateId': 'drake_pointing',
          'style': 'humorous',
          'language': 'english',
        },
        'generateChallenge': {
          'category': 'fitness',
          'duration': 7,
          'style': 'inspirational',
          'language': 'english',
        },
        'translateContent': {
          'content': 'Hello world! This is a test.',
          'targetLanguages': ['spanish', 'french', 'german'],
        },
        'remixForPlatforms': {
          'content': 'Just had an amazing experience today!',
          'platforms': ['Twitter', 'Instagram', 'LinkedIn'],
        },
      },
      'expectedOutputs': {
        'generateContent': {
          'type': 'ContentStudioResult',
          'fields': ['content', 'type', 'hashtags', 'captions', 'engagementScore'],
          'contentLength': '>20',
          'hashtagsCount': '>=3',
          'captionsCount': '>=1',
          'engagementScore': '>=0.5',
        },
        'generateMeme': {
          'type': 'ContentStudioResult',
          'fields': ['content', 'memeData'],
          'memeDataFields': ['templateId', 'topText', 'bottomText'],
        },
        'generateChallenge': {
          'type': 'ContentStudioResult',
          'fields': ['content', 'challengeData'],
          'challengeDataFields': ['title', 'description', 'instructions', 'duration'],
        },
        'translateContent': {
          'type': 'Map<Language, String>',
          'expectedKeys': ['spanish', 'french', 'german'],
        },
        'remixForPlatforms': {
          'type': 'Map<String, String>',
          'expectedKeys': ['Twitter', 'Instagram', 'LinkedIn'],
        },
      },
    };
  }

  // Test utility methods
  static Future<bool> testGenerateContent(MockContentStudioService service) async {
    try {
      final input = getSampleInputOutput()['inputs']['generateContent'];
      final result = await service.generateContent(
        prompt: input['prompt'],
        type: ContentType.post,
        style: ContentStyle.casual,
        language: Language.english,
        includeImages: input['includeImages'],
        includeHashtags: input['includeHashtags'],
        includeCaptions: input['includeCaptions'],
        maxVariations: input['maxVariations'],
      );

      return result.content.isNotEmpty &&
             result.hashtags.length >= 3 &&
             result.captions.isNotEmpty &&
             result.engagementScore >= 0.5;
    } catch (e) {
      print('Test failed: $e');
      return false;
    }
  }

  static Future<bool> testGenerateMeme(MockContentStudioService service) async {
    try {
      final input = getSampleInputOutput()['inputs']['generateMeme'];
      final result = await service.generateMeme(
        topic: input['topic'],
        templateId: input['templateId'],
        style: ContentStyle.humorous,
        language: Language.english,
      );

      return result.content.isNotEmpty &&
             result.memeData != null &&
             result.memeData!.templateId.isNotEmpty;
    } catch (e) {
      print('Test failed: $e');
      return false;
    }
  }

  static Future<bool> testGenerateChallenge(MockContentStudioService service) async {
    try {
      final input = getSampleInputOutput()['inputs']['generateChallenge'];
      final result = await service.generateChallenge(
        category: input['category'],
        duration: input['duration'],
        style: ContentStyle.inspirational,
        language: Language.english,
      );

      return result.content.isNotEmpty &&
             result.challengeData != null &&
             result.challengeData!.title.isNotEmpty &&
             result.challengeData!.duration == input['duration'];
    } catch (e) {
      print('Test failed: $e');
      return false;
    }
  }

  static Future<bool> runAllTests() async {
    final mockService = MockContentStudioService(useMockData: true);
    
    print('🧪 Running Content Studio Tests...');
    
    final tests = [
      testGenerateContent(mockService),
      testGenerateMeme(mockService),
      testGenerateChallenge(mockService),
    ];

    final results = await Future.wait(tests);
    final passed = results.where((r) => r).length;
    final total = results.length;

    print('✅ Tests passed: $passed/$total');
    
    if (passed == total) {
      print('🎉 All tests passed!');
      return true;
    } else {
      print('❌ Some tests failed.');
      return false;
    }
  }
}