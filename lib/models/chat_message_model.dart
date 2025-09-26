import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { 
  text, 
  image, 
  video, 
  audio, 
  file, 
  location, 
  contact, 
  sticker, 
  gif, 
  voice_note,
  system,
  reply,
  forward
}

enum MessageStatus { 
  sending, 
  sent, 
  delivered, 
  read, 
  failed 
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String chatRoomId;
  final String content;
  final MessageType messageType;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final Duration? audioDuration;
  final Map<String, dynamic> location;
  final String? replyToMessageId;
  final String? forwardedFromUserId;
  final Map<String, String> reactions; // userId -> emoji
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final Map<String, dynamic> encryption;
  final Map<String, dynamic> metadata;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.chatRoomId,
    required this.content,
    required this.messageType,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.audioDuration,
    this.location = const {},
    this.replyToMessageId,
    this.forwardedFromUserId,
    this.reactions = const {},
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.encryption = const {},
    this.metadata = const {},
  });

  // Legacy constructor for backwards compatibility
  ChatMessage.legacy({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required String message,
    required this.timestamp,
    String messageTypeString = 'text',
  }) : content = message,
       chatRoomId = '${senderId}_$receiverId',
       messageType = messageTypeString == 'image' ? MessageType.image : MessageType.text,
       status = MessageStatus.sent,
       mediaUrl = null,
       thumbnailUrl = null,
       fileName = null,
       fileSize = null,
       audioDuration = null,
       location = const {},
       replyToMessageId = null,
       forwardedFromUserId = null,
       reactions = const {},
       isEdited = false,
       editedAt = null,
       isDeleted = false,
       deletedAt = null,
       encryption = const {},
       metadata = const {};

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '${map['senderId']}_${map['receiverId']}',
      content: map['content'] ?? map['message'] ?? '', // Support legacy 'message' field
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['messageType'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      mediaUrl: map['mediaUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      audioDuration: map['audioDuration'] != null 
          ? Duration(milliseconds: map['audioDuration']) 
          : null,
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      replyToMessageId: map['replyToMessageId'],
      forwardedFromUserId: map['forwardedFromUserId'],
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null 
          ? (map['editedAt'] as Timestamp).toDate() 
          : null,
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] as Timestamp).toDate() 
          : null,
      encryption: Map<String, dynamic>.from(map['encryption'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'chatRoomId': chatRoomId,
      'content': content,
      'message': content, // Keep for backwards compatibility
      'messageType': messageType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'audioDuration': audioDuration?.inMilliseconds,
      'location': location,
      'replyToMessageId': replyToMessageId,
      'forwardedFromUserId': forwardedFromUserId,
      'reactions': reactions,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'encryption': encryption,
      'metadata': metadata,
    };
  }

  bool get hasMedia => [MessageType.image, MessageType.video, MessageType.audio, MessageType.voice_note, MessageType.file].contains(messageType);
  
  bool get isReply => replyToMessageId != null;
  bool get isForwarded => forwardedFromUserId != null;
  bool get isSystem => messageType == MessageType.system;
  bool get hasReactions => reactions.isNotEmpty;
  bool get isEncrypted => encryption.isNotEmpty;

  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    
    switch (messageType) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
      case MessageType.voice_note:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '🎭 Sticker';
      case MessageType.gif:
        return '🎬 GIF';
      default:
        return content;
    }
  }

  // Legacy getters for backwards compatibility
  String get message => content;

  ChatMessage copyWith({
    String? content,
    MessageType? messageType,
    MessageStatus? status,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    Duration? audioDuration,
    Map<String, dynamic>? location,
    String? replyToMessageId,
    String? forwardedFromUserId,
    Map<String, String>? reactions,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    Map<String, dynamic>? encryption,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      chatRoomId: chatRoomId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      timestamp: timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      audioDuration: audioDuration ?? this.audioDuration,
      location: location ?? this.location,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      forwardedFromUserId: forwardedFromUserId ?? this.forwardedFromUserId,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      encryption: encryption ?? this.encryption,
      metadata: metadata ?? this.metadata,
    );
  }
}
