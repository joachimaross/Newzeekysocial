import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:myapp/models/chat_message_model.dart';
import 'package:image_picker/image_picker.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;

  const ChatConversationScreen(
      {super.key, required this.chatRoomId, required this.receiverId});

  @override
  ChatConversationScreenState createState() => ChatConversationScreenState();
}

class ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      firestoreService.sendMessage(widget.receiverId, _messageController.text, messageType: 'text');
      _messageController.clear();
    }
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      final storageService = Provider.of<StorageService>(context, listen: false);
      final imageUrl = await storageService.uploadImage(image);
      if (imageUrl != null) {
        if (!mounted) return;
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        firestoreService.sendMessage(widget.receiverId, imageUrl, messageType: 'image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with \${widget.receiverId.substring(0, 6)}...'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getMessagesStream(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error: \${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ChatMessage(
                    id: doc.id,
                    senderId: data['senderId'] ?? '',
                    receiverId: data['receiverId'] ?? '',
                    message: data['message'] ?? '',
                    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    messageType: data['messageType'] ?? 'text',
                  );
                }).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  reverse: true, // To show latest messages at the bottom
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isImage = message.messageType == 'image';

                    return ListTile(
                      title: isImage
                          ? Image.network(message.message)
                          : Text(message.message),
                      subtitle: const Text('From: \${message.senderId.substring(0, 6)}...'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
