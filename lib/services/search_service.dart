import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/post_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/community_model.dart';

enum SearchType { users, posts, communities, hashtags, all }
enum TrendingPeriod { hour, day, week, month }

class SearchResult {
  final SearchType type;
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final double relevanceScore;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.data,
    required this.relevanceScore,
  });
}

class TrendingItem {
  final String id;
  final String content;
  final int count;
  final double trendScore;
  final TrendingPeriod period;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  TrendingItem({
    required this.id,
    required this.content,
    required this.count,
    required this.trendScore,
    required this.period,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory TrendingItem.fromMap(Map<String, dynamic> map) {
    return TrendingItem(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      count: map['count'] ?? 0,
      trendScore: (map['trendScore'] ?? 0.0).toDouble(),
      period: TrendingPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == map['period'],
        orElse: () => TrendingPeriod.day,
      ),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

class SearchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search users by name or username
  Future<List<SearchResult>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = <SearchResult>[];

      // Search by display name
      final nameQuery = await _db
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      for (final doc in nameQuery.docs) {
        final user = AppUser.fromMap(doc.data());
        results.add(SearchResult(
          type: SearchType.users,
          id: user.uid,
          title: user.displayName,
          subtitle: user.bio ?? '',
          imageUrl: user.photoURL,
          data: user.toMap(),
          relevanceScore: _calculateUserRelevance(query, user),
        ));
      }

      // Search by email (if query looks like email)
      if (query.contains('@')) {
        final emailQuery = await _db
            .collection('users')
            .where('email', isEqualTo: query.toLowerCase())
            .limit(5)
            .get();

        for (final doc in emailQuery.docs) {
          final user = AppUser.fromMap(doc.data());
          if (!results.any((r) => r.id == user.uid)) {
            results.add(SearchResult(
              type: SearchType.users,
              id: user.uid,
              title: user.displayName,
              subtitle: user.email ?? '',
              imageUrl: user.photoURL,
              data: user.toMap(),
              relevanceScore: 1.0, // Exact email match gets high score
            ));
          }
        }
      }

      // Sort by relevance and remove duplicates
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return results.take(20).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Search posts by content
  Future<List<SearchResult>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = <SearchResult>[];

      // Search by content
      final contentQuery = await _db
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      for (final doc in contentQuery.docs) {
        final post = Post.fromMap(doc.id, doc.data());
        results.add(SearchResult(
          type: SearchType.posts,
          id: post.id,
          title: post.content.length > 100 
              ? '${post.content.substring(0, 100)}...' 
              : post.content,
          subtitle: 'Posted ${_formatTimeAgo(post.timestamp)}',
          imageUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : null,
          data: post.toMap(),
          relevanceScore: _calculatePostRelevance(query, post),
        ));
      }

      // Search by hashtags
      if (query.startsWith('#')) {
        final hashtag = query.substring(1).toLowerCase();
        final hashtagQuery = await _db
            .collection('posts')
            .where('hashtags', arrayContains: hashtag)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        for (final doc in hashtagQuery.docs) {
          final post = Post.fromMap(doc.id, doc.data());
          if (!results.any((r) => r.id == post.id)) {
            results.add(SearchResult(
              type: SearchType.posts,
              id: post.id,
              title: post.content.length > 100 
                  ? '${post.content.substring(0, 100)}...' 
                  : post.content,
              subtitle: 'Tagged with $query',
              imageUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : null,
              data: post.toMap(),
              relevanceScore: 0.9, // High relevance for hashtag matches
            ));
          }
        }
      }

      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return results.take(20).toList();
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  // Search communities
  Future<List<SearchResult>> searchCommunities(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = <SearchResult>[];

      // Search by name
      final nameQuery = await _db
          .collection('communities')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('type', whereIn: ['public']) // Only search public communities
          .limit(20)
          .get();

      for (final doc in nameQuery.docs) {
        final community = Community.fromMap(doc.id, doc.data());
        results.add(SearchResult(
          type: SearchType.communities,
          id: community.id,
          title: community.name,
          subtitle: '${community.memberCount} members • ${community.description}',
          imageUrl: community.imageUrl,
          data: community.toMap(),
          relevanceScore: _calculateCommunityRelevance(query, community),
        ));
      }

      // Search by tags
      final tagQuery = await _db
          .collection('communities')
          .where('tags', arrayContains: query.toLowerCase())
          .where('type', whereIn: ['public'])
          .limit(20)
          .get();

      for (final doc in tagQuery.docs) {
        final community = Community.fromMap(doc.id, doc.data());
        if (!results.any((r) => r.id == community.id)) {
          results.add(SearchResult(
            type: SearchType.communities,
            id: community.id,
            title: community.name,
            subtitle: '${community.memberCount} members • ${community.description}',
            imageUrl: community.imageUrl,
            data: community.toMap(),
            relevanceScore: 0.8, // Good relevance for tag matches
          ));
        }
      }

      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return results.take(20).toList();
    } catch (e) {
      print('Error searching communities: $e');
      return [];
    }
  }

  // Get trending hashtags
  Future<List<TrendingItem>> getTrendingHashtags({
    TrendingPeriod period = TrendingPeriod.day,
    int limit = 10,
  }) async {
    try {
      final query = await _db
          .collection('trending_hashtags')
          .where('period', isEqualTo: period.toString().split('.').last)
          .orderBy('trendScore', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TrendingItem.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting trending hashtags: $e');
      return [];
    }
  }

  // Get trending posts
  Future<List<Post>> getTrendingPosts({
    TrendingPeriod period = TrendingPeriod.day,
    int limit = 20,
  }) async {
    try {
      // Calculate time threshold based on period
      final now = DateTime.now();
      DateTime threshold;
      switch (period) {
        case TrendingPeriod.hour:
          threshold = now.subtract(const Duration(hours: 1));
          break;
        case TrendingPeriod.day:
          threshold = now.subtract(const Duration(days: 1));
          break;
        case TrendingPeriod.week:
          threshold = now.subtract(const Duration(days: 7));
          break;
        case TrendingPeriod.month:
          threshold = now.subtract(const Duration(days: 30));
          break;
      }

      // Get posts with high engagement in the time period
      final query = await _db
          .collection('posts')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(threshold))
          .orderBy('timestamp', descending: true)
          .limit(limit * 3) // Get more to filter by engagement
          .get();

      final posts = query.docs
          .map((doc) => Post.fromMap(doc.id, doc.data()))
          .toList();

      // Sort by engagement score and take top results
      posts.sort((a, b) => _calculateEngagementScore(b).compareTo(_calculateEngagementScore(a)));
      return posts.take(limit).toList();
    } catch (e) {
      print('Error getting trending posts: $e');
      return [];
    }
  }

  // Universal search across all types
  Future<List<SearchResult>> universalSearch(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final futures = await Future.wait([
        searchUsers(query),
        searchPosts(query),
        searchCommunities(query),
      ]);

      final allResults = <SearchResult>[];
      for (final results in futures) {
        allResults.addAll(results.take(5)); // Take top 5 from each category
      }

      // Sort all results by relevance
      allResults.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return allResults.take(20).toList();
    } catch (e) {
      print('Error in universal search: $e');
      return [];
    }
  }

  // Update trending hashtags (should be called periodically)
  Future<void> updateTrendingHashtags() async {
    try {
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(days: 1));

      // Get recent posts with hashtags
      final recentPosts = await _db
          .collection('posts')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(oneDayAgo))
          .get();

      final hashtagCounts = <String, int>{};

      // Count hashtag usage
      for (final doc in recentPosts.docs) {
        final post = Post.fromMap(doc.id, doc.data());
        for (final hashtag in post.hashtags) {
          hashtagCounts[hashtag] = (hashtagCounts[hashtag] ?? 0) + 1;
        }
      }

      // Update trending hashtags collection
      final batch = _db.batch();
      for (final entry in hashtagCounts.entries) {
        if (entry.value >= 3) { // Minimum threshold for trending
          final trendingItem = TrendingItem(
            id: entry.key,
            content: '#${entry.key}',
            count: entry.value,
            trendScore: _calculateTrendScore(entry.value, now),
            period: TrendingPeriod.day,
            updatedAt: now,
          );

          final docRef = _db.collection('trending_hashtags').doc(entry.key);
          batch.set(docRef, trendingItem.toMap());
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error updating trending hashtags: $e');
    }
  }

  // Private helper methods
  double _calculateUserRelevance(String query, AppUser user) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();
    final lowerName = user.displayName.toLowerCase();

    if (lowerName == lowerQuery) score += 1.0;
    else if (lowerName.startsWith(lowerQuery)) score += 0.8;
    else if (lowerName.contains(lowerQuery)) score += 0.6;

    // Boost verified users
    if (user.isVerified) score += 0.2;

    // Boost recently active users
    if (user.isOnline) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  double _calculatePostRelevance(String query, Post post) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();
    final lowerContent = post.content.toLowerCase();

    if (lowerContent.contains(lowerQuery)) {
      score += 0.7;
      // Boost if query appears at the beginning
      if (lowerContent.startsWith(lowerQuery)) score += 0.2;
    }

    // Boost posts with high engagement
    final engagementScore = _calculateEngagementScore(post) / 100; // Normalize
    score += engagementScore.clamp(0.0, 0.3);

    // Boost recent posts
    final hoursSincePost = DateTime.now().difference(post.timestamp).inHours;
    if (hoursSincePost < 24) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  double _calculateCommunityRelevance(String query, Community community) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();
    final lowerName = community.name.toLowerCase();

    if (lowerName.contains(lowerQuery)) score += 0.8;
    if (community.description.toLowerCase().contains(lowerQuery)) score += 0.3;

    // Boost verified and large communities
    if (community.isVerified) score += 0.2;
    if (community.memberCount > 100) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  double _calculateEngagementScore(Post post) {
    return (post.totalReactions * 2) + 
           (post.commentsCount * 3) + 
           (post.sharesCount * 4);
  }

  double _calculateTrendScore(int count, DateTime timestamp) {
    final hoursSinceUpdate = DateTime.now().difference(timestamp).inHours;
    final timeDecay = 1.0 - (hoursSinceUpdate / 24.0).clamp(0.0, 0.9);
    return count * timeDecay;
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

// Extension for TrendingItem to include toMap method
extension TrendingItemExtension on TrendingItem {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'count': count,
      'trendScore': trendScore,
      'period': period.toString().split('.').last,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }
}