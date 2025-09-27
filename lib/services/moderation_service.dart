import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zeeky_social/services/ai_service.dart';

enum ModerationAction { none, warn, blur, remove, ban_user, restrict_user }
enum ContentType { text, image, video, audio, profile }
enum ViolationType { 
  spam, 
  hate_speech, 
  harassment, 
  adult_content, 
  violence, 
  fake_news, 
  self_harm, 
  copyright, 
  personal_info,
  inappropriate_language
}

class ModerationResult {
  final bool isViolation;
  final ViolationType? violationType;
  final double confidence;
  final ModerationAction recommendedAction;
  final String reason;
  final Map<String, dynamic> details;

  ModerationResult({
    required this.isViolation,
    this.violationType,
    required this.confidence,
    required this.recommendedAction,
    required this.reason,
    this.details = const {},
  });

  factory ModerationResult.safe() {
    return ModerationResult(
      isViolation: false,
      confidence: 1.0,
      recommendedAction: ModerationAction.none,
      reason: 'Content is safe',
    );
  }

  factory ModerationResult.fromMap(Map<String, dynamic> map) {
    return ModerationResult(
      isViolation: map['isViolation'] ?? false,
      violationType: map['violationType'] != null
          ? ViolationType.values.firstWhere(
              (e) => e.toString().split('.').last == map['violationType'],
              orElse: () => ViolationType.spam,
            )
          : null,
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      recommendedAction: ModerationAction.values.firstWhere(
        (e) => e.toString().split('.').last == map['recommendedAction'],
        orElse: () => ModerationAction.none,
      ),
      reason: map['reason'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isViolation': isViolation,
      'violationType': violationType?.toString().split('.').last,
      'confidence': confidence,
      'recommendedAction': recommendedAction.toString().split('.').last,
      'reason': reason,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class UserRestriction {
  final String userId;
  final ViolationType violationType;
  final ModerationAction action;
  final DateTime startTime;
  final DateTime? endTime;
  final String reason;
  final String moderatorId;
  final bool isActive;
  final Map<String, dynamic> metadata;

  UserRestriction({
    required this.userId,
    required this.violationType,
    required this.action,
    required this.startTime,
    this.endTime,
    required this.reason,
    required this.moderatorId,
    this.isActive = true,
    this.metadata = const {},
  });

  factory UserRestriction.fromMap(Map<String, dynamic> map) {
    return UserRestriction(
      userId: map['userId'] ?? '',
      violationType: ViolationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['violationType'],
        orElse: () => ViolationType.spam,
      ),
      action: ModerationAction.values.firstWhere(
        (e) => e.toString().split('.').last == map['action'],
        orElse: () => ModerationAction.warn,
      ),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null 
          ? (map['endTime'] as Timestamp).toDate() 
          : null,
      reason: map['reason'] ?? '',
      moderatorId: map['moderatorId'] ?? '',
      isActive: map['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'violationType': violationType.toString().split('.').last,
      'action': action.toString().split('.').last,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'reason': reason,
      'moderatorId': moderatorId,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  bool get isExpired => endTime != null && DateTime.now().isAfter(endTime!);
}

class ModerationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  // Predefined keywords and patterns for different violation types
  static const Map<ViolationType, List<String>> _keywordPatterns = {
    ViolationType.spam: ['buy now', 'click here', 'limited time', 'act now', '100% free'],
    ViolationType.hate_speech: ['hate', 'racist', 'bigot'], // Simplified for demo
    ViolationType.harassment: ['kill yourself', 'die', 'worthless'], // Simplified for demo
    ViolationType.inappropriate_language: ['fuck', 'shit', 'damn'], // Basic profanity
  };

  // Moderate text content
  Future<ModerationResult> moderateText(String content, ContentType contentType) async {
    try {
      // Quick keyword-based check first
      final keywordResult = _checkKeywords(content);
      if (keywordResult.isViolation && keywordResult.confidence > 0.8) {
        await _logModerationResult(content, keywordResult, contentType);
        return keywordResult;
      }

      // AI-based moderation for more nuanced content
      final aiResult = await _aiModeration(content, contentType);
      await _logModerationResult(content, aiResult, contentType);
      
      return aiResult;
    } catch (e) {
      print('Error in text moderation: $e');
      return ModerationResult.safe();
    }
  }

  // Moderate image content (placeholder - would use AI vision in production)
  Future<ModerationResult> moderateImage(String imageUrl) async {
    try {
      // In production, this would use AI vision models to detect:
      // - Adult content
      // - Violence
      // - Inappropriate imagery
      // - Copyright violations
      
      // For demo, always return safe
      final result = ModerationResult.safe();
      await _logModerationResult(imageUrl, result, ContentType.image);
      return result;
    } catch (e) {
      print('Error in image moderation: $e');
      return ModerationResult.safe();
    }
  }

  // Apply moderation action
  Future<void> applyModerationAction(
    String contentId, 
    ModerationResult result, 
    ContentType contentType
  ) async {
    if (!result.isViolation) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      switch (result.recommendedAction) {
        case ModerationAction.blur:
          await _blurContent(contentId, contentType);
          break;
        case ModerationAction.remove:
          await _removeContent(contentId, contentType);
          break;
        case ModerationAction.warn:
          await _warnUser(contentId, result);
          break;
        case ModerationAction.restrict_user:
          await _restrictUser(contentId, result, Duration(hours: 24));
          break;
        case ModerationAction.ban_user:
          await _banUser(contentId, result);
          break;
        case ModerationAction.none:
          // No action needed
          break;
      }

      // Log the action
      await _logModerationAction(contentId, result, contentType);
    } catch (e) {
      print('Error applying moderation action: $e');
    }
  }

  // Check if user is restricted
  Future<UserRestriction?> getUserRestriction(String userId) async {
    try {
      final query = await _db
          .collection('user_restrictions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final restriction = UserRestriction.fromMap(query.docs.first.data());
      
      // Check if restriction is expired
      if (restriction.isExpired) {
        await _deactivateRestriction(query.docs.first.id);
        return null;
      }

      return restriction;
    } catch (e) {
      print('Error getting user restriction: $e');
      return null;
    }
  }

  // Auto-moderation for new content
  Future<bool> autoModerate(String content, ContentType contentType, String contentId) async {
    final result = await moderateText(content, contentType);
    
    if (result.isViolation && result.confidence > 0.7) {
      await applyModerationAction(contentId, result, contentType);
      return true; // Content was moderated
    }
    
    return false; // Content is allowed
  }

  // Get moderation statistics
  Future<Map<String, int>> getModerationStats({Duration? period}) async {
    try {
      final cutoff = period != null 
          ? DateTime.now().subtract(period)
          : DateTime.now().subtract(const Duration(days: 30));

      final query = await _db
          .collection('moderation_logs')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
          .get();

      final stats = <String, int>{};
      for (final doc in query.docs) {
        final data = doc.data();
        final violationType = data['violationType'] as String?;
        if (violationType != null) {
          stats[violationType] = (stats[violationType] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting moderation stats: $e');
      return {};
    }
  }

  // Private helper methods

  ModerationResult _checkKeywords(String content) {
    final lowerContent = content.toLowerCase();
    
    for (final entry in _keywordPatterns.entries) {
      for (final keyword in entry.value) {
        if (lowerContent.contains(keyword)) {
          return ModerationResult(
            isViolation: true,
            violationType: entry.key,
            confidence: 0.9,
            recommendedAction: _getRecommendedAction(entry.key),
            reason: 'Contains inappropriate keyword: $keyword',
            details: {'keyword': keyword},
          );
        }
      }
    }

    return ModerationResult.safe();
  }

  Future<ModerationResult> _aiModeration(String content, ContentType contentType) async {
    try {
      final prompt = '''
      Analyze the following content for policy violations. 
      Check for: spam, hate speech, harassment, adult content, violence, fake news, self-harm content, personal information leaks.
      
      Content: "$content"
      
      Respond with a JSON object containing:
      - isViolation (boolean)
      - violationType (string, one of: spam, hate_speech, harassment, adult_content, violence, fake_news, self_harm, personal_info)
      - confidence (number 0-1)
      - reason (string explanation)
      
      If no violations found, set isViolation to false.
      ''';

      final aiResponse = await _aiService.generateText(prompt);
      
      // Parse AI response (simplified - in production use proper JSON parsing)
      if (aiResponse.toLowerCase().contains('"isviolation": true') || 
          aiResponse.toLowerCase().contains('"isviolation":true')) {
        
        // Extract violation type from response
        ViolationType? violationType;
        for (final type in ViolationType.values) {
          if (aiResponse.toLowerCase().contains(type.toString().split('.').last)) {
            violationType = type;
            break;
          }
        }

        return ModerationResult(
          isViolation: true,
          violationType: violationType ?? ViolationType.inappropriate_language,
          confidence: 0.8,
          recommendedAction: _getRecommendedAction(violationType ?? ViolationType.inappropriate_language),
          reason: 'AI detected policy violation',
          details: {'aiResponse': aiResponse},
        );
      }

      return ModerationResult.safe();
    } catch (e) {
      print('Error in AI moderation: $e');
      return ModerationResult.safe();
    }
  }

  ModerationAction _getRecommendedAction(ViolationType violationType) {
    switch (violationType) {
      case ViolationType.spam:
        return ModerationAction.remove;
      case ViolationType.hate_speech:
        return ModerationAction.ban_user;
      case ViolationType.harassment:
        return ModerationAction.restrict_user;
      case ViolationType.adult_content:
        return ModerationAction.blur;
      case ViolationType.violence:
        return ModerationAction.remove;
      case ViolationType.fake_news:
        return ModerationAction.blur;
      case ViolationType.self_harm:
        return ModerationAction.remove;
      case ViolationType.personal_info:
        return ModerationAction.blur;
      case ViolationType.inappropriate_language:
        return ModerationAction.warn;
      default:
        return ModerationAction.warn;
    }
  }

  Future<void> _blurContent(String contentId, ContentType contentType) async {
    final collection = _getCollectionName(contentType);
    await _db.collection(collection).doc(contentId).update({
      'isBlurred': true,
      'moderationApplied': true,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _removeContent(String contentId, ContentType contentType) async {
    final collection = _getCollectionName(contentType);
    await _db.collection(collection).doc(contentId).update({
      'isRemoved': true,
      'moderationApplied': true,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _warnUser(String contentId, ModerationResult result) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('user_warnings').add({
      'userId': user.uid,
      'contentId': contentId,
      'violationType': result.violationType?.toString().split('.').last,
      'reason': result.reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _restrictUser(String contentId, ModerationResult result, Duration duration) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final restriction = UserRestriction(
      userId: user.uid,
      violationType: result.violationType ?? ViolationType.spam,
      action: ModerationAction.restrict_user,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(duration),
      reason: result.reason,
      moderatorId: 'system',
    );

    await _db.collection('user_restrictions').add(restriction.toMap());
  }

  Future<void> _banUser(String contentId, ModerationResult result) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final restriction = UserRestriction(
      userId: user.uid,
      violationType: result.violationType ?? ViolationType.spam,
      action: ModerationAction.ban_user,
      startTime: DateTime.now(),
      reason: result.reason,
      moderatorId: 'system',
    );

    await _db.collection('user_restrictions').add(restriction.toMap());
  }

  Future<void> _deactivateRestriction(String restrictionId) async {
    await _db.collection('user_restrictions').doc(restrictionId).update({
      'isActive': false,
      'deactivatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _logModerationResult(
    String content, 
    ModerationResult result, 
    ContentType contentType
  ) async {
    await _db.collection('moderation_logs').add({
      'content': content,
      'contentType': contentType.toString().split('.').last,
      'moderationResult': result.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
      'userId': _auth.currentUser?.uid,
    });
  }

  Future<void> _logModerationAction(
    String contentId, 
    ModerationResult result, 
    ContentType contentType
  ) async {
    await _db.collection('moderation_actions').add({
      'contentId': contentId,
      'contentType': contentType.toString().split('.').last,
      'action': result.recommendedAction.toString().split('.').last,
      'violationType': result.violationType?.toString().split('.').last,
      'reason': result.reason,
      'timestamp': FieldValue.serverTimestamp(),
      'moderatorId': 'system',
    });
  }

  String _getCollectionName(ContentType contentType) {
    switch (contentType) {
      case ContentType.text:
        return 'posts';
      case ContentType.image:
        return 'posts';
      case ContentType.video:
        return 'posts';
      case ContentType.audio:
        return 'posts';
      case ContentType.profile:
        return 'users';
    }
  }
}