import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get a stream of all posts
  Stream<QuerySnapshot> getPostsStream() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  // Add a new post
  Future<void> addPost(String content, String userId) {
    return _db.collection('posts').add({
      'content': content,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get a stream of chat rooms for the current user
  Stream<QuerySnapshot> getChatRoomsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }
    return _db
        .collection('chat_rooms')
        .where('userIds', arrayContains: currentUser.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // Get a stream of messages for a specific chat room
  Stream<QuerySnapshot> getMessagesStream(String chatRoomId) {
    return _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', ascending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String receiverId, String message, {String messageType = 'text'}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final String currentUserId = currentUser.uid;
    final Timestamp timestamp = Timestamp.now();

    // Construct chat room ID from current user ID and receiver ID (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Create a new message
    final messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType,
    };

    // Add the new message to the messages subcollection
    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // Update the last message in the chat room
    await _db.collection('chat_rooms').doc(chatRoomId).set(
      {
        'userIds': ids,
        'lastMessage': messageType == 'image' ? 'Photo' : message,
        'lastMessageTimestamp': timestamp,
      },
      SetOptions(merge: true), // Use merge to create the doc if it doesn't exist
    );
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
