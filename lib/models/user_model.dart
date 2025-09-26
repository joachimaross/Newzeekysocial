import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String? photoURL;
  final String? email;
  final String? bio;
  final String? phoneNumber;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final Map<String, dynamic> privacySettings;
  final List<String> badges;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.displayName,
    this.photoURL,
    this.email,
    this.bio,
    this.phoneNumber,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.privacySettings = const {},
    this.badges = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      email: map['email'],
      bio: map['bio'],
      phoneNumber: map['phoneNumber'],
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null 
          ? (map['lastSeen'] as Timestamp).toDate() 
          : null,
      privacySettings: Map<String, dynamic>.from(map['privacySettings'] ?? {}),
      badges: List<String>.from(map['badges'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoURL': photoURL,
      'email': email,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'privacySettings': privacySettings,
      'badges': badges,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppUser copyWith({
    String? displayName,
    String? photoURL,
    String? email,
    String? bio,
    String? phoneNumber,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? privacySettings,
    List<String>? badges,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      privacySettings: privacySettings ?? this.privacySettings,
      badges: badges ?? this.badges,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
