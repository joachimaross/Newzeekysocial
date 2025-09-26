import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { text, image, video, audio, poll, shared }
enum PostVisibility { public, friends, private }

class Post {
  final String id;
  final String content;
  final String userId;
  final DateTime timestamp;
  final PostType type;
  final PostVisibility visibility;
  final List<String> mediaUrls;
  final List<String> hashtags;
  final List<String> mentions;
  final Map<String, int> reactions; // emoji -> count
  final int commentsCount;
  final int sharesCount;
  final String? sharedPostId;
  final String? communityId;
  final Map<String, dynamic> poll;
  final Map<String, dynamic> location;
  final bool isPinned;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, dynamic> aiMetadata;
  final Map<String, dynamic> metadata;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    required this.timestamp,
    this.type = PostType.text,
    this.visibility = PostVisibility.public,
    this.mediaUrls = const [],
    this.hashtags = const [],
    this.mentions = const [],
    this.reactions = const {},
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.sharedPostId,
    this.communityId,
    this.poll = const {},
    this.location = const {},
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    this.aiMetadata = const {},
    this.metadata = const {},
  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PostType.text,
      ),
      visibility: PostVisibility.values.firstWhere(
        (e) => e.toString().split('.').last == map['visibility'],
        orElse: () => PostVisibility.public,
      ),
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      commentsCount: map['commentsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      sharedPostId: map['sharedPostId'],
      communityId: map['communityId'],
      poll: Map<String, dynamic>.from(map['poll'] ?? {}),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      isPinned: map['isPinned'] ?? false,
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null 
          ? (map['editedAt'] as Timestamp).toDate() 
          : null,
      aiMetadata: Map<String, dynamic>.from(map['aiMetadata'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'mediaUrls': mediaUrls,
      'hashtags': hashtags,
      'mentions': mentions,
      'reactions': reactions,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'sharedPostId': sharedPostId,
      'communityId': communityId,
      'poll': poll,
      'location': location,
      'isPinned': isPinned,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'aiMetadata': aiMetadata,
      'metadata': metadata,
    };
  }

  int get totalReactions => reactions.values.fold(0, (a, b) => a + b);
  
  bool get hasPoll => poll.isNotEmpty;
  bool get hasMedia => mediaUrls.isNotEmpty;
  bool get hasLocation => location.isNotEmpty;
  bool get isShared => sharedPostId != null;

  Post copyWith({
    String? content,
    PostType? type,
    PostVisibility? visibility,
    List<String>? mediaUrls,
    List<String>? hashtags,
    List<String>? mentions,
    Map<String, int>? reactions,
    int? commentsCount,
    int? sharesCount,
    String? sharedPostId,
    String? communityId,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? location,
    bool? isPinned,
    bool? isEdited,
    DateTime? editedAt,
    Map<String, dynamic>? aiMetadata,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id,
      content: content ?? this.content,
      userId: userId,
      timestamp: timestamp,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      reactions: reactions ?? this.reactions,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      sharedPostId: sharedPostId ?? this.sharedPostId,
      communityId: communityId ?? this.communityId,
      poll: poll ?? this.poll,
      location: location ?? this.location,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      metadata: metadata ?? this.metadata,
    );
  }
}
