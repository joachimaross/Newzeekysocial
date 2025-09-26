import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/story_model.dart';
import 'package:myapp/services/media_service.dart';
import 'package:myapp/services/notification_service.dart';

class StoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MediaService _mediaService = MediaService();
  final NotificationService _notificationService = NotificationService();

  Timer? _cleanupTimer;

  void initialize() {
    // Start periodic cleanup of expired stories
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupExpiredStories();
    });
  }

  void dispose() {
    _cleanupTimer?.cancel();
  }

  // Create a new story
  Future<String?> createStory({
    required String content,
    File? mediaFile,
    StoryType type = StoryType.text,
    String? backgroundColor,
    String? textColor,
    Duration? customDuration,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      String? mediaUrl;
      
      // Upload media if provided
      if (mediaFile != null && type != StoryType.text) {
        final mediaResult = await _uploadStoryMedia(mediaFile, type);
        if (mediaResult == null) {
          throw Exception('Failed to upload media');
        }
        mediaUrl = mediaResult.url;
      }

      final now = DateTime.now();
      final expiresAt = customDuration != null 
          ? now.add(customDuration)
          : now.add(const Duration(hours: 24));

      final story = Story(
        id: '', // Will be set by Firestore
        userId: user.uid,
        content: content,
        mediaUrl: mediaUrl,
        type: type,
        createdAt: now,
        expiresAt: expiresAt,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );

      final docRef = await _db.collection('stories').add(story.toMap());
      
      // Update user's story count
      await _updateUserStoryCount(user.uid, 1);

      // Notify followers about the new story
      await _notifyFollowersOfNewStory(user.uid, docRef.id);

      return docRef.id;
    } catch (e) {
      print('Error creating story: $e');
      return null;
    }
  }

  // Get user's active stories
  Stream<List<Story>> getUserStories(String userId) {
    return _db
        .collection('stories')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Story.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get stories from followed users
  Stream<List<Story>> getFollowingStories() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('user_following')
        .doc(user.uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <Story>[];

      final followingList = List<String>.from(doc.data()?['following'] ?? []);
      if (followingList.isEmpty) return <Story>[];

      // Add current user to see own stories
      followingList.add(user.uid);

      final storiesSnapshot = await _db
          .collection('stories')
          .where('userId', whereIn: followingList)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return storiesSnapshot.docs
          .map((doc) => Story.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get all public stories (discover)
  Stream<List<Story>> getPublicStories({int limit = 50}) {
    return _db
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Story.fromMap(doc.id, doc.data()))
            .toList());
  }

  // View a story (add to viewed list)
  Future<void> viewStory(String storyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('stories').doc(storyId).update({
        'viewedBy': FieldValue.arrayUnion([user.uid]),
      });

      // Log story view for analytics
      await _logStoryView(storyId, user.uid);
    } catch (e) {
      print('Error viewing story: $e');
    }
  }

  // React to a story
  Future<void> reactToStory(String storyId, String emoji) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('stories').doc(storyId).update({
        'reactions.${user.uid}': emoji,
      });

      // Notify story owner about the reaction
      final story = await getStory(storyId);
      if (story != null && story.userId != user.uid) {
        await _notificationService.sendNotification(
          userId: story.userId,
          title: 'Story Reaction',
          body: '${user.displayName} reacted to your story with $emoji',
          type: 'story_reaction',
          data: {'storyId': storyId, 'reaction': emoji},
        );
      }
    } catch (e) {
      print('Error reacting to story: $e');
    }
  }

  // Reply to a story
  Future<void> replyToStory(String storyId, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create a reply document
      await _db.collection('story_replies').add({
        'storyId': storyId,
        'userId': user.uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Notify story owner about the reply
      final story = await getStory(storyId);
      if (story != null && story.userId != user.uid) {
        await _notificationService.sendNotification(
          userId: story.userId,
          title: 'Story Reply',
          body: '${user.displayName} replied to your story',
          type: 'story_reply',
          data: {'storyId': storyId, 'message': message},
        );
      }
    } catch (e) {
      print('Error replying to story: $e');
    }
  }

  // Get story by ID
  Future<Story?> getStory(String storyId) async {
    try {
      final doc = await _db.collection('stories').doc(storyId).get();
      if (doc.exists) {
        return Story.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting story: $e');
      return null;
    }
  }

  // Delete a story
  Future<void> deleteStory(String storyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final story = await getStory(storyId);
      if (story == null || story.userId != user.uid) return;

      // Delete media from storage if exists
      if (story.mediaUrl != null) {
        // Extract storage reference from URL and delete
        // This is simplified - in production, store the storage reference
      }

      // Delete the story document
      await _db.collection('stories').doc(storyId).delete();

      // Delete related replies
      final repliesQuery = await _db
          .collection('story_replies')
          .where('storyId', isEqualTo: storyId)
          .get();

      final batch = _db.batch();
      for (final doc in repliesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update user's story count
      await _updateUserStoryCount(user.uid, -1);
    } catch (e) {
      print('Error deleting story: $e');
    }
  }

  // Get story replies
  Stream<List<Map<String, dynamic>>> getStoryReplies(String storyId) {
    return _db
        .collection('story_replies')
        .where('storyId', isEqualTo: storyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Get story viewers
  Future<List<String>> getStoryViewers(String storyId) async {
    try {
      final doc = await _db.collection('stories').doc(storyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return List<String>.from(data['viewedBy'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting story viewers: $e');
      return [];
    }
  }

  // Create story highlight
  Future<void> addToHighlights(String storyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final story = await getStory(storyId);
      if (story == null || story.userId != user.uid) return;

      // Update story to be a highlight
      await _db.collection('stories').doc(storyId).update({
        'isHighlight': true,
      });

      // Add to user's highlights collection
      await _db.collection('story_highlights').doc(user.uid).set({
        'storyIds': FieldValue.arrayUnion([storyId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding story to highlights: $e');
    }
  }

  // Get user's story highlights
  Stream<List<Story>> getUserHighlights(String userId) {
    return _db
        .collection('story_highlights')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <Story>[];

      final storyIds = List<String>.from(doc.data()?['storyIds'] ?? []);
      if (storyIds.isEmpty) return <Story>[];

      final storiesSnapshot = await _db
          .collection('stories')
          .where(FieldPath.documentId, whereIn: storyIds)
          .where('isHighlight', isEqualTo: true)
          .get();

      return storiesSnapshot.docs
          .map((doc) => Story.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get story analytics
  Future<Map<String, dynamic>> getStoryAnalytics(String storyId) async {
    try {
      final story = await getStory(storyId);
      if (story == null) return {};

      final repliesQuery = await _db
          .collection('story_replies')
          .where('storyId', isEqualTo: storyId)
          .get();

      return {
        'views': story.viewedBy.length,
        'reactions': story.reactions.length,
        'replies': repliesQuery.docs.length,
        'reactionBreakdown': _analyzeReactions(story.reactions),
        'timeLeft': story.expiresAt.difference(DateTime.now()).inHours,
        'isExpired': story.isExpired,
      };
    } catch (e) {
      print('Error getting story analytics: $e');
      return {};
    }
  }

  // Private helper methods

  Future<MediaUploadResult?> _uploadStoryMedia(File mediaFile, StoryType type) async {
    switch (type) {
      case StoryType.image:
        final imageFile = XFile(mediaFile.path);
        return await _mediaService.uploadImage(imageFile, generateThumbnail: false);
      case StoryType.video:
        final videoFile = XFile(mediaFile.path);
        return await _mediaService.uploadVideo(videoFile);
      default:
        return null;
    }
  }

  Future<void> _updateUserStoryCount(String userId, int delta) async {
    await _db.collection('users').doc(userId).update({
      'storyCount': FieldValue.increment(delta),
    });
  }

  Future<void> _notifyFollowersOfNewStory(String userId, String storyId) async {
    try {
      // Get user's followers
      final followersDoc = await _db.collection('user_followers').doc(userId).get();
      if (!followersDoc.exists) return;

      final followers = List<String>.from(followersDoc.data()?['followers'] ?? []);
      
      // Send notifications to followers (in batches to avoid quota limits)
      const batchSize = 100;
      for (int i = 0; i < followers.length; i += batchSize) {
        final batch = followers.skip(i).take(batchSize);
        for (final followerId in batch) {
          await _notificationService.sendNotification(
            userId: followerId,
            title: 'New Story',
            body: 'Someone you follow posted a new story',
            type: 'new_story',
            data: {'storyId': storyId, 'authorId': userId},
          );
        }
      }
    } catch (e) {
      print('Error notifying followers: $e');
    }
  }

  Future<void> _logStoryView(String storyId, String viewerId) async {
    await _db.collection('story_analytics').add({
      'storyId': storyId,
      'viewerId': viewerId,
      'action': 'view',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _cleanupExpiredStories() async {
    try {
      final expiredQuery = await _db
          .collection('stories')
          .where('expiresAt', isLessThan: Timestamp.now())
          .where('isHighlight', isEqualTo: false) // Don't delete highlights
          .get();

      final batch = _db.batch();
      for (final doc in expiredQuery.docs) {
        batch.delete(doc.reference);
      }

      if (expiredQuery.docs.isNotEmpty) {
        await batch.commit();
        print('Cleaned up ${expiredQuery.docs.length} expired stories');
      }
    } catch (e) {
      print('Error cleaning up expired stories: $e');
    }
  }

  Map<String, int> _analyzeReactions(Map<String, dynamic> reactions) {
    final breakdown = <String, int>{};
    for (final reaction in reactions.values) {
      if (reaction is String) {
        breakdown[reaction] = (breakdown[reaction] ?? 0) + 1;
      }
    }
    return breakdown;
  }
}