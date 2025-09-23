import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/screens/chat_conversation_screen.dart';
import 'package:myapp/services/auth_service.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error: \${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AppUser(
              uid: doc.id,
              displayName: data['displayName'] ?? 'Anonymous',
              photoURL: data['photoURL'],
            );
          }).toList();

          // Filter out the current user
          final otherUsers = users.where((user) => user.uid != currentUserId).toList();

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user.displayName),
                onTap: () {
                  // Navigate to chat screen with this user
                  List<String> ids = [currentUserId, user.uid];
                  ids.sort();
                  String chatRoomId = ids.join("_");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatConversationScreen(
                        chatRoomId: chatRoomId,
                        receiverId: user.uid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
