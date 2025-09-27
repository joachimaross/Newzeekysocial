# AI Content Studio Testing Guide

This guide provides comprehensive instructions for testing the AI-powered Social Content Studio in development, beta, and production environments.

## 🚀 Quick Start

### Development Mode
1. Enable mock data for testing without API costs:
   ```dart
   // In your test environment
   final mockService = MockContentStudioService(useMockData: true);
   ```

2. Run tests:
   ```bash
   flutter test test/content_studio_service_test.dart
   ```

3. Run app in debug mode:
   ```bash
   flutter run --debug
   ```

## 🧪 Testing Features

### 1. Content Generation Testing

#### Test Scenarios:
- **Basic Content Generation**
  - Input: "morning coffee routine"
  - Expected: Post with relevant content, hashtags, and engagement score
  - Test in all content types (post, story, reel, meme, challenge)

- **Style Variations**
  - Test all content styles: casual, professional, humorous, inspirational, trendy, educational
  - Verify style differences in generated content

- **Multi-language Support**
  - Test content generation in all supported languages
  - Verify proper language translation functionality

#### Sample Test:
```dart
test('should generate engaging content', () async {
  final result = await contentStudio.generateContent(
    prompt: 'productivity tips for remote work',
    type: ContentType.post,
    style: ContentStyle.professional,
    language: Language.english,
    includeImages: true,
    includeHashtags: true,
  );
  
  expect(result.content, isNotEmpty);
  expect(result.hashtags.length, greaterThanOrEqualTo(3));
  expect(result.engagementScore, greaterThanOrEqualTo(0.5));
});
```

### 2. Meme Generator Testing

#### Test Scenarios:
- **Template-based Memes**
  - Test with specific template IDs
  - Test with auto-selected templates
  - Verify meme structure (top text, bottom text, image prompt)

- **Topic Adaptation**
  - Test various topics: current events, pop culture, work life
  - Verify humor and relevance

#### Sample Input/Output:
```yaml
Input:
  topic: "monday mornings"
  templateId: "drake_pointing"
  style: "humorous"

Expected Output:
  - topText: "Weekend relaxation"
  - bottomText: "Monday morning alarm"
  - hashtags: ["meme", "monday", "relatable"]
  - engagementScore: 0.9
```

### 3. Challenge Generator Testing

#### Test Scenarios:
- **Category-specific Challenges**
  - fitness, creativity, learning, wellness, productivity
  - Verify category-appropriate content

- **Duration Variations**
  - Test 1-30 day challenges
  - Verify duration is properly incorporated

#### Sample Test:
```dart
test('should create fitness challenge', () async {
  final result = await contentStudio.generateChallenge(
    category: 'fitness',
    duration: 7,
    style: ContentStyle.inspirational,
  );
  
  expect(result.challengeData!.category, equals('fitness'));
  expect(result.challengeData!.duration, equals(7));
  expect(result.challengeData!.instructions, contains('day'));
});
```

### 4. Multi-language Translation Testing

#### Test Cases:
```dart
final translations = await contentStudio.translateContent(
  'Hello world! Great to see you here.',
  [Language.spanish, Language.french, Language.german]
);

// Verify all languages are translated
expect(translations[Language.spanish], contains('Hola'));
expect(translations[Language.french], contains('Bonjour'));
expect(translations[Language.german], contains('Hallo'));
```

### 5. Platform Remix Testing

#### Test Scenarios:
- **Twitter**: Character limit optimization, trending hashtags
- **Instagram**: Visual focus, story-style content
- **LinkedIn**: Professional tone, industry insights
- **TikTok**: Short-form, energetic content

#### Sample Test:
```dart
final remixes = await contentStudio.remixForPlatforms(
  'Just launched our new product!',
  ['Twitter', 'LinkedIn', 'Instagram']
);

expect(remixes['Twitter'], contains('🐦'));
expect(remixes['LinkedIn'], contains('professional'));
expect(remixes['Instagram'], contains('📸'));
```

## 🛠️ Development Testing Setup

### Mock Data Configuration
Enable mock data for development testing:

```dart
// In lib/main.dart for development builds
final contentStudio = kDebugMode 
  ? MockContentStudioService(useMockData: true)
  : ContentStudioService();
```

### Environment Variables
Create test environment configuration:

```yaml
# .env.development
FLUTTER_ENV=development
USE_MOCK_AI=true
AI_API_TIMEOUT=30000
MAX_CONTENT_VARIATIONS=3
```

### Test Data
Use predefined test inputs for consistent testing:

```dart
// Test data sets
final testPrompts = [
  'morning routine',
  'weekend plans', 
  'productivity tips',
  'healthy eating',
  'tech trends',
];

final testLanguages = [
  Language.english,
  Language.spanish,
  Language.french,
];
```

## 🔍 Beta Testing Guide

### User Acceptance Testing
1. **Content Quality Assessment**
   - Rate generated content relevance (1-5)
   - Check for appropriate hashtags
   - Verify engagement potential

2. **User Experience Testing**
   - UI responsiveness
   - Feature discoverability
   - Error handling

3. **Performance Testing**
   - Content generation speed
   - App stability with concurrent requests
   - Memory usage monitoring

### Beta Test Scenarios
```yaml
Scenario 1: Content Creator Workflow
  Steps:
    1. Open Content Studio
    2. Enter topic: "sustainable living"
    3. Select style: inspirational
    4. Generate content with images
    5. Copy to clipboard
    6. Share to social platform

Expected: 
  - Content generated in <5 seconds
  - Relevant, inspiring content
  - 5+ relevant hashtags
  - High-quality image suggestions

Scenario 2: Multi-platform Campaign
  Steps:
    1. Create base content
    2. Remix for 3 platforms
    3. Translate to 2 languages
    4. Save variations

Expected:
  - Platform-specific adaptations
  - Accurate translations
  - Consistent brand voice
```

## 📊 Performance Benchmarks

### Response Time Targets
- Content Generation: < 5 seconds
- Meme Generation: < 3 seconds
- Challenge Creation: < 4 seconds
- Translation: < 2 seconds per language
- Platform Remix: < 1 second per platform

### Quality Metrics
- Engagement Score: > 0.7 average
- Content Relevance: > 85% user satisfaction
- Hashtag Accuracy: > 90% relevant hashtags
- Translation Quality: > 80% accuracy rate

## 🚨 Error Handling Testing

### Common Error Scenarios
1. **Network Issues**
   - Timeout handling
   - Offline mode behavior
   - Retry mechanisms

2. **Invalid Inputs**
   - Empty prompts
   - Unsupported languages
   - Invalid template IDs

3. **API Limitations**
   - Rate limiting
   - Content policy violations
   - Service unavailability

### Test Error Cases:
```dart
test('should handle empty prompt gracefully', () async {
  final result = await contentStudio.generateContent(
    prompt: '',
    type: ContentType.post,
  );
  
  // Should not crash, may return default content
  expect(result, isNotNull);
});
```

## 📈 Monitoring & Analytics

### Key Metrics to Track
- API success rates
- Average response times
- User engagement with generated content
- Feature usage statistics
- Error frequencies

### Logging Setup
```dart
// Enable detailed logging for development
developer.log(
  'Content generated successfully',
  name: 'ContentStudio',
  level: 800, // INFO level
  time: DateTime.now(),
);
```

## 🔧 Debugging Tips

### Common Issues & Solutions
1. **Slow Response Times**
   - Check network connection
   - Verify API endpoints
   - Monitor concurrent requests

2. **Poor Content Quality**
   - Review prompts and context
   - Check language settings
   - Verify model parameters

3. **UI Performance Issues**
   - Profile widget rebuilds
   - Optimize image loading
   - Check memory leaks

### Debug Mode Features
- Mock data toggle
- Response time display  
- Quality score breakdown
- API call logging

## 📋 Testing Checklist

### Pre-Release Testing
- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met
- [ ] Error handling verified
- [ ] Multi-language support tested
- [ ] Cross-platform compatibility
- [ ] Accessibility compliance
- [ ] Security audit completed

### User Testing
- [ ] Content quality assessment
- [ ] UI/UX evaluation
- [ ] Feature completeness
- [ ] Performance satisfaction
- [ ] Error recovery testing
- [ ] Documentation accuracy

## 📚 Additional Resources

### Sample Test Cases
See `test/content_studio_service_test.dart` for comprehensive test examples.

### Mock Data Examples
Check `lib/services/mock_content_studio_service.dart` for sample inputs/outputs.

### Performance Profiling
Use Flutter DevTools for detailed performance analysis.

### API Documentation
Refer to Firebase AI documentation for model-specific guidelines.

---

**Need Help?** Contact the development team or check the project's GitHub issues for troubleshooting support.