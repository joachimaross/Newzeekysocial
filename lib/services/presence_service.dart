import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PresenceStatus { online, away, busy, offline }
enum ActivityType { typing, recording, uploading, idle }

class UserPresence {
  final String userId;
  final PresenceStatus status;
  final DateTime lastSeen;
  final String? statusMessage;
  final Map<String, ActivityType> activities; // chatRoomId -> activity
  final bool isOnMobile;
  final bool isOnWeb;
  final Map<String, dynamic> metadata;

  UserPresence({
    required this.userId,
    required this.status,
    required this.lastSeen,
    this.statusMessage,
    this.activities = const {},
    this.isOnMobile = false,
    this.isOnWeb = false,
    this.metadata = const {},
  });

  factory UserPresence.fromMap(Map<String, dynamic> map) {
    return UserPresence(
      userId: map['userId'] ?? '',
      status: PresenceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PresenceStatus.offline,
      ),
      lastSeen: (map['lastSeen'] as Timestamp).toDate(),
      statusMessage: map['statusMessage'],
      activities: Map<String, ActivityType>.from(
        (map['activities'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            key,
            ActivityType.values.firstWhere(
              (e) => e.toString().split('.').last == value,
              orElse: () => ActivityType.idle,
            ),
          ),
        ),
      ),
      isOnMobile: map['isOnMobile'] ?? false,
      isOnWeb: map['isOnWeb'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status.toString().split('.').last,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'statusMessage': statusMessage,
      'activities': activities.map(
        (key, value) => MapEntry(key, value.toString().split('.').last),
      ),
      'isOnMobile': isOnMobile,
      'isOnWeb': isOnWeb,
      'metadata': metadata,
    };
  }

  bool get isOnline => status == PresenceStatus.online;
  bool get isTypingIn => activities.containsValue(ActivityType.typing);
}

class PresenceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Timer? _presenceTimer;
  StreamSubscription? _authSubscription;
  final Map<String, Timer> _typingTimers = {};
  final Duration _typingTimeout = const Duration(seconds: 3);

  void initialize() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startPresenceUpdates();
      } else {
        _stopPresenceUpdates();
      }
    });
  }

  void dispose() {
    _stopPresenceUpdates();
    _authSubscription?.cancel();
    _typingTimers.values.forEach((timer) => timer.cancel());
    _typingTimers.clear();
  }

  void _startPresenceUpdates() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Update presence every 30 seconds
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      updateUserPresence(PresenceStatus.online);
    });

    // Set initial online status
    updateUserPresence(PresenceStatus.online);

    // Set offline when app goes to background
    _setOfflineOnDisconnect(user.uid);
  }

  void _stopPresenceUpdates() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    
    final user = _auth.currentUser;
    if (user != null) {
      updateUserPresence(PresenceStatus.offline);
    }
  }

  Future<void> updateUserPresence(
    PresenceStatus status, {
    String? statusMessage,
    bool? isOnMobile,
    bool? isOnWeb,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final presenceData = {
        'userId': user.uid,
        'status': status.toString().split('.').last,
        'lastSeen': FieldValue.serverTimestamp(),
        'statusMessage': statusMessage,
        'isOnMobile': isOnMobile ?? false,
        'isOnWeb': isOnWeb ?? true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('presence').doc(user.uid).set(
        presenceData,
        SetOptions(merge: true),
      );

      // Also update user document
      await _db.collection('users').doc(user.uid).update({
        'isOnline': status == PresenceStatus.online,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating presence: $e');
    }
  }

  Future<void> setTypingIndicator(String chatRoomId, bool isTyping) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final activityKey = 'activities.$chatRoomId';
      
      if (isTyping) {
        // Set typing indicator
        await _db.collection('presence').doc(user.uid).update({
          activityKey: ActivityType.typing.toString().split('.').last,
        });

        // Clear previous timer
        _typingTimers[chatRoomId]?.cancel();
        
        // Auto-clear typing indicator after timeout
        _typingTimers[chatRoomId] = Timer(_typingTimeout, () {
          clearActivity(chatRoomId);
        });
      } else {
        await clearActivity(chatRoomId);
      }
    } catch (e) {
      print('Error setting typing indicator: $e');
    }
  }

  Future<void> clearActivity(String chatRoomId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('presence').doc(user.uid).update({
        'activities.$chatRoomId': FieldValue.delete(),
      });
      
      _typingTimers[chatRoomId]?.cancel();
      _typingTimers.remove(chatRoomId);
    } catch (e) {
      print('Error clearing activity: $e');
    }
  }

  Stream<UserPresence?> getUserPresence(String userId) {
    return _db
        .collection('presence')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserPresence.fromMap(doc.data()!) : null);
  }

  Stream<List<UserPresence>> getMultipleUserPresence(List<String> userIds) {
    if (userIds.isEmpty) return Stream.value([]);

    return _db
        .collection('presence')
        .where('userId', whereIn: userIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserPresence.fromMap(doc.data()))
            .toList());
  }

  Future<List<String>> getOnlineUsers() async {
    try {
      final snapshot = await _db
          .collection('presence')
          .where('status', isEqualTo: 'online')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting online users: $e');
      return [];
    }
  }

  bool isUserTypingIn(UserPresence presence, String chatRoomId) {
    return presence.activities[chatRoomId] == ActivityType.typing;
  }

  void _setOfflineOnDisconnect(String userId) {
    // In a real implementation, you would use Firebase Realtime Database
    // for better offline detection, or implement this with server-side logic
    // This is a simplified version using Firestore
    
    // Set up a periodic check and cleanup of stale presence data
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupStalePresence();
    });
  }

  Future<void> _cleanupStalePresence() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
      final snapshot = await _db
          .collection('presence')
          .where('lastSeen', isLessThan: Timestamp.fromDate(cutoff))
          .where('status', isEqualTo: 'online')
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': PresenceStatus.offline.toString().split('.').last,
        });
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error cleaning up stale presence: $e');
    }
  }
}