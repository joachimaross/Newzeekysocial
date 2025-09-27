import 'package:flutter_test/flutter_test.dart';
import 'package:zeeky_social/services/content_studio_service.dart';
import 'package:zeeky_social/services/mock_content_studio_service.dart';

void main() {
  group('ContentStudioService Tests', () {
    late MockContentStudioService mockService;
    late ContentStudioService realService;

    setUp(() {
      mockService = MockContentStudioService(useMockData: true);
      realService = ContentStudioService(); // For integration tests
    });

    group('Mock Service Tests', () {
      test('should generate content with all required fields', () async {
        final result = await mockService.generateContent(
          prompt: 'coffee morning routine',
          type: ContentType.post,
          style: ContentStyle.casual,
          language: Language.english,
          includeImages: true,
          includeHashtags: true,
          includeCaptions: true,
          maxVariations: 3,
        );

        expect(result.content, isNotEmpty);
        expect(result.type, equals(ContentType.post));
        expect(result.hashtags, isNotEmpty);
        expect(result.hashtags.length, greaterThanOrEqualTo(3));
        expect(result.captions, isNotEmpty);
        expect(result.captions.length, greaterThanOrEqualTo(1));
        expect(result.engagementScore, greaterThanOrEqualTo(0.5));
        expect(result.generatedImages, isNotNull);
        expect(result.metadata['mock'], isTrue);
      });

      test('should generate meme with proper structure', () async {
        final result = await mockService.generateMeme(
          topic: 'monday mornings',
          templateId: 'drake_pointing',
          style: ContentStyle.humorous,
          language: Language.english,
        );

        expect(result.content, isNotEmpty);
        expect(result.type, equals(ContentType.meme));
        expect(result.memeData, isNotNull);
        expect(result.memeData!.templateId, equals('drake_pointing'));
        expect(result.memeData!.topText, isNotEmpty);
        expect(result.memeData!.bottomText, isNotEmpty);
        expect(result.hashtags, contains('meme'));
        expect(result.engagementScore, equals(0.9)); // Memes have high engagement
      });

      test('should generate challenge with proper structure', () async {
        final result = await mockService.generateChallenge(
          category: 'fitness',
          duration: 7,
          style: ContentStyle.inspirational,
          language: Language.english,
        );

        expect(result.content, isNotEmpty);
        expect(result.type, equals(ContentType.challenge));
        expect(result.challengeData, isNotNull);
        expect(result.challengeData!.title, isNotEmpty);
        expect(result.challengeData!.description, isNotEmpty);
        expect(result.challengeData!.instructions, isNotEmpty);
        expect(result.challengeData!.duration, equals(7));
        expect(result.challengeData!.category, equals('fitness'));
        expect(result.hashtags, isNotEmpty);
      });

      test('should translate content to multiple languages', () async {
        final content = 'Hello world! This is a test.';
        final targetLanguages = [Language.spanish, Language.french, Language.german];
        
        final translations = await mockService.translateContent(content, targetLanguages);

        expect(translations, hasLength(3));
        expect(translations[Language.spanish], isNotNull);
        expect(translations[Language.french], isNotNull);
        expect(translations[Language.german], isNotNull);
        
        for (final translation in translations.values) {
          expect(translation, isNotEmpty);
        }
      });

      test('should remix content for different platforms', () async {
        final content = 'Just had an amazing experience today!';
        final platforms = ['Twitter', 'Instagram', 'LinkedIn'];
        
        final remixes = await mockService.remixForPlatforms(content, platforms);

        expect(remixes, hasLength(3));
        expect(remixes['Twitter'], isNotNull);
        expect(remixes['Instagram'], isNotNull);
        expect(remixes['LinkedIn'], isNotNull);
        
        for (final remix in remixes.values) {
          expect(remix, isNotEmpty);
        }
        
        // Each platform should have distinct adaptations
        expect(remixes['Twitter'], isNot(equals(remixes['Instagram'])));
        expect(remixes['Instagram'], isNot(equals(remixes['LinkedIn'])));
      });

      test('should generate trending hashtags', () async {
        const count = 8;
        final hashtags = await mockService.generateTrendingHashtags(
          'artificial intelligence and social media',
          count: count,
        );

        expect(hashtags, hasLength(lessThanOrEqualTo(count)));
        expect(hashtags, isNotEmpty);
        
        for (final hashtag in hashtags) {
          expect(hashtag, isNotEmpty);
          expect(hashtag, isNot(contains('#'))); // Hashtags should not include #
        }
      });
    });

    group('Content Type Tests', () {
      test('should generate different content for different types', () async {
        final postResult = await mockService.generateContent(
          prompt: 'technology trends',
          type: ContentType.post,
        );
        
        final storyResult = await mockService.generateContent(
          prompt: 'technology trends',
          type: ContentType.story,
        );

        expect(postResult.type, equals(ContentType.post));
        expect(storyResult.type, equals(ContentType.story));
        // Content should be different for different types
        expect(postResult.content, isNot(equals(storyResult.content)));
      });

      test('should generate different content for different styles', () async {
        final casualResult = await mockService.generateContent(
          prompt: 'productivity tips',
          type: ContentType.post,
          style: ContentStyle.casual,
        );
        
        final professionalResult = await mockService.generateContent(
          prompt: 'productivity tips',
          type: ContentType.post,
          style: ContentStyle.professional,
        );

        expect(casualResult.metadata['style'], contains('casual'));
        expect(professionalResult.metadata['style'], contains('professional'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle empty prompt gracefully', () async {
        expect(
          () async => await mockService.generateContent(
            prompt: '',
            type: ContentType.post,
          ),
          // Should not throw exception, might return default content
          returnsNormally,
        );
      });

      test('should handle invalid template ID for memes', () async {
        final result = await mockService.generateMeme(
          topic: 'test topic',
          templateId: 'invalid_template_id',
        );
        
        // Should still generate a meme, possibly using default template
        expect(result.type, equals(ContentType.meme));
        expect(result.memeData, isNotNull);
      });
    });

    group('Performance Tests', () {
      test('content generation should complete within reasonable time', () async {
        final stopwatch = Stopwatch()..start();
        
        await mockService.generateContent(
          prompt: 'performance test',
          type: ContentType.post,
        );
        
        stopwatch.stop();
        
        // Mock service should complete quickly (under 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should handle concurrent requests', () async {
        final futures = List.generate(3, (index) {
          return mockService.generateContent(
            prompt: 'concurrent test $index',
            type: ContentType.post,
          );
        });

        final results = await Future.wait(futures);
        
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result.content, isNotEmpty);
        }
      });
    });

    group('Data Structure Tests', () {
      test('ContentStudioResult should have proper structure', () async {
        final result = await mockService.generateContent(
          prompt: 'structure test',
          type: ContentType.post,
        );

        // Check all required fields exist
        expect(result.content, isA<String>());
        expect(result.type, isA<ContentType>());
        expect(result.hashtags, isA<List<String>>());
        expect(result.captions, isA<List<String>>());
        expect(result.metadata, isA<Map<String, dynamic>>());
        expect(result.engagementScore, isA<double>());
        
        // Check optional fields
        if (result.generatedImages != null) {
          expect(result.generatedImages, isA<List<ImageData>>());
        }
        
        if (result.memeData != null) {
          expect(result.memeData, isA<MemeData>());
        }
        
        if (result.challengeData != null) {
          expect(result.challengeData, isA<ChallengeData>());
        }
      });

      test('MemeData should have proper structure', () async {
        final result = await mockService.generateMeme(
          topic: 'test meme',
        );

        expect(result.memeData, isNotNull);
        final memeData = result.memeData!;
        
        expect(memeData.templateId, isA<String>());
        expect(memeData.topText, isA<String>());
        expect(memeData.bottomText, isA<String>());
        expect(memeData.imagePrompt, isA<String>());
        expect(memeData.hashtags, isA<List<String>>());
      });

      test('ChallengeData should have proper structure', () async {
        final result = await mockService.generateChallenge(
          category: 'test',
          duration: 5,
        );

        expect(result.challengeData, isNotNull);
        final challengeData = result.challengeData!;
        
        expect(challengeData.id, isA<String>());
        expect(challengeData.title, isA<String>());
        expect(challengeData.description, isA<String>());
        expect(challengeData.instructions, isA<String>());
        expect(challengeData.hashtags, isA<List<String>>());
        expect(challengeData.duration, isA<int>());
        expect(challengeData.category, isA<String>());
      });
    });

    group('Integration Tests', () {
      // These tests can be run against real AI services in staging/beta
      test('should work with sample data from documentation', () async {
        final sampleData = MockContentStudioService.getSampleInputOutput();
        final inputs = sampleData['inputs'];
        
        // Test with sample input for content generation
        final contentInput = inputs['generateContent'];
        final result = await mockService.generateContent(
          prompt: contentInput['prompt'],
          type: ContentType.post,
          style: ContentStyle.casual,
          language: Language.english,
          includeImages: contentInput['includeImages'],
          includeHashtags: contentInput['includeHashtags'],
          includeCaptions: contentInput['includeCaptions'],
          maxVariations: contentInput['maxVariations'],
        );

        expect(result.content, isNotEmpty);
        expect(result.content.length, greaterThan(20));
        expect(result.hashtags.length, greaterThanOrEqualTo(3));
        expect(result.engagementScore, greaterThanOrEqualTo(0.5));
      });
    });

    group('Static Test Helper Tests', () {
      test('should run all static tests successfully', () async {
        final allTestsPassed = await MockContentStudioService.runAllTests();
        expect(allTestsPassed, isTrue);
      });
    });
  });

  group('Language Support Tests', () {
    late MockContentStudioService service;

    setUp(() {
      service = MockContentStudioService(useMockData: true);
    });

    test('should support all defined languages', () {
      final languages = Language.values;
      expect(languages, contains(Language.english));
      expect(languages, contains(Language.spanish));
      expect(languages, contains(Language.french));
      expect(languages, contains(Language.german));
      expect(languages, contains(Language.italian));
      expect(languages, contains(Language.portuguese));
      expect(languages, contains(Language.japanese));
      expect(languages, contains(Language.chinese));
    });

    test('should generate content in different languages', () async {
      final languages = [Language.spanish, Language.french];
      
      final result1 = await service.generateContent(
        prompt: 'hello world',
        type: ContentType.post,
        language: languages[0],
      );
      
      final result2 = await service.generateContent(
        prompt: 'hello world',
        type: ContentType.post,
        language: languages[1],
      );

      expect(result1.metadata['language'], contains('spanish'));
      expect(result2.metadata['language'], contains('french'));
    });
  });

  group('Content Style Tests', () {
    late MockContentStudioService service;

    setUp(() {
      service = MockContentStudioService(useMockData: true);
    });

    test('should support all defined content styles', () {
      final styles = ContentStyle.values;
      expect(styles, contains(ContentStyle.casual));
      expect(styles, contains(ContentStyle.professional));
      expect(styles, contains(ContentStyle.humorous));
      expect(styles, contains(ContentStyle.inspirational));
      expect(styles, contains(ContentStyle.trendy));
      expect(styles, contains(ContentStyle.educational));
    });

    test('should generate different content for different styles', () async {
      final styles = [ContentStyle.casual, ContentStyle.professional];
      
      final results = await Future.wait([
        service.generateContent(
          prompt: 'productivity tips',
          type: ContentType.post,
          style: styles[0],
        ),
        service.generateContent(
          prompt: 'productivity tips',
          type: ContentType.post,
          style: styles[1],
        ),
      ]);

      expect(results[0].metadata['style'], contains('casual'));
      expect(results[1].metadata['style'], contains('professional'));
    });
  });
}