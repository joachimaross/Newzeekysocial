import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zeeky_social/models/chat_room_model.dart';
import 'package:zeeky_social/services/auth_service.dart';
import 'package:zeeky_social/services/firestore_service.dart';
import 'package:zeeky_social/screens/chat_conversation_screen.dart';
import 'package:zeeky_social/screens/user_list_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getChatRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error: \${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats yet. Start a new one!'));
          }

          final chatRooms = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatRoom(
              id: doc.id,
              userIds: List<String>.from(data['userIds'] ?? []),
              lastMessage: data['lastMessage'] ?? '',
              lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserId = chatRoom.userIds.firstWhere((id) => id != currentUserId, orElse: () => 'Unknown');
              return ChatListItem(chatRoom: chatRoom, otherUserId: otherUserId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserListScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.chatRoom, required this.otherUserId});

  final ChatRoom chatRoom;
  final String otherUserId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Chat with \${otherUserId.substring(0, 6)}...'),
      subtitle: Text(chatRoom.lastMessage),
      trailing: const Text('\${chatRoom.lastMessageTimestamp.hour}:\${chatRoom.lastMessageTimestamp.minute}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              chatRoomId: chatRoom.id,
              receiverId: otherUserId,
            ),
          ),
        );
      },
    );
  }
}
