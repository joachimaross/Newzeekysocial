import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  message,
  mention,
  reply,
  reaction,
  follow,
  like,
  comment,
  share,
  event_invite,
  event_reminder,
  community_invite,
  system,
  ai_suggestion,
  security_alert
}

enum NotificationPriority { low, normal, high, urgent }

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final String? groupKey;
  final Map<String, dynamic> metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.imageUrl,
    this.actionUrl,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    this.groupKey,
    this.metadata = const {},
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      readAt: map['readAt'] != null 
          ? (map['readAt'] as Timestamp).toDate() 
          : null,
      expiresAt: map['expiresAt'] != null 
          ? (map['expiresAt'] as Timestamp).toDate() 
          : null,
      groupKey: map['groupKey'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'groupKey': groupKey,
      'metadata': metadata,
    };
  }

  bool get isExpired => 
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AppNotification copyWith({
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? expiresAt,
    String? groupKey,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
      groupKey: groupKey ?? this.groupKey,
      metadata: metadata ?? this.metadata,
    );
  }
}