import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, image, video }

class Story {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final StoryType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final Map<String, dynamic> reactions;
  final bool isHighlight;
  final String? backgroundColor;
  final String? textColor;
  final Map<String, dynamic> metadata;

  Story({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrl,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.reactions = const {},
    this.isHighlight = false,
    this.backgroundColor,
    this.textColor,
    this.metadata = const {},
  });

  factory Story.fromMap(String id, Map<String, dynamic> map) {
    return Story(
      id: id,
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      type: StoryType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => StoryType.text,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
      reactions: Map<String, dynamic>.from(map['reactions'] ?? {}),
      isHighlight: map['isHighlight'] ?? false,
      backgroundColor: map['backgroundColor'],
      textColor: map['textColor'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'mediaUrl': mediaUrl,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': viewedBy,
      'reactions': reactions,
      'isHighlight': isHighlight,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'metadata': metadata,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Story copyWith({
    String? content,
    String? mediaUrl,
    StoryType? type,
    List<String>? viewedBy,
    Map<String, dynamic>? reactions,
    bool? isHighlight,
    String? backgroundColor,
    String? textColor,
    Map<String, dynamic>? metadata,
  }) {
    return Story(
      id: id,
      userId: userId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      createdAt: createdAt,
      expiresAt: expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      reactions: reactions ?? this.reactions,
      isHighlight: isHighlight ?? this.isHighlight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      metadata: metadata ?? this.metadata,
    );
  }
}