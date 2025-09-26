import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityType { public, private, secret }
enum MemberRole { owner, admin, moderator, member, restricted }

class Community {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? bannerUrl;
  final CommunityType type;
  final String ownerId;
  final List<String> adminIds;
  final List<String> moderatorIds;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;
  final List<String> tags;
  final bool isVerified;
  final Map<String, dynamic> rules;
  final Map<String, dynamic> metadata;

  Community({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.bannerUrl,
    required this.type,
    required this.ownerId,
    this.adminIds = const [],
    this.moderatorIds = const [],
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const {},
    this.tags = const [],
    this.isVerified = false,
    this.rules = const {},
    this.metadata = const {},
  });

  factory Community.fromMap(String id, Map<String, dynamic> map) {
    return Community(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      bannerUrl: map['bannerUrl'],
      type: CommunityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => CommunityType.public,
      ),
      ownerId: map['ownerId'] ?? '',
      adminIds: List<String>.from(map['adminIds'] ?? []),
      moderatorIds: List<String>.from(map['moderatorIds'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
      isVerified: map['isVerified'] ?? false,
      rules: Map<String, dynamic>.from(map['rules'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'bannerUrl': bannerUrl,
      'type': type.toString().split('.').last,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'moderatorIds': moderatorIds,
      'memberCount': memberCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'settings': settings,
      'tags': tags,
      'isVerified': isVerified,
      'rules': rules,
      'metadata': metadata,
    };
  }
}

class CommunityMember {
  final String userId;
  final String communityId;
  final MemberRole role;
  final DateTime joinedAt;
  final bool isMuted;
  final bool isBanned;
  final DateTime? bannedUntil;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic> metadata;

  CommunityMember({
    required this.userId,
    required this.communityId,
    required this.role,
    required this.joinedAt,
    this.isMuted = false,
    this.isBanned = false,
    this.bannedUntil,
    this.permissions = const {},
    this.metadata = const {},
  });

  factory CommunityMember.fromMap(Map<String, dynamic> map) {
    return CommunityMember(
      userId: map['userId'] ?? '',
      communityId: map['communityId'] ?? '',
      role: MemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      isMuted: map['isMuted'] ?? false,
      isBanned: map['isBanned'] ?? false,
      bannedUntil: map['bannedUntil'] != null
          ? (map['bannedUntil'] as Timestamp).toDate()
          : null,
      permissions: Map<String, dynamic>.from(map['permissions'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'communityId': communityId,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isMuted': isMuted,
      'isBanned': isBanned,
      'bannedUntil': bannedUntil != null ? Timestamp.fromDate(bannedUntil!) : null,
      'permissions': permissions,
      'metadata': metadata,
    };
  }

  bool get canPost {
    return !isBanned && !isMuted && 
           (role == MemberRole.owner || role == MemberRole.admin || 
            role == MemberRole.moderator || role == MemberRole.member);
  }

  bool get canModerate {
    return !isBanned && 
           (role == MemberRole.owner || role == MemberRole.admin || 
            role == MemberRole.moderator);
  }
}