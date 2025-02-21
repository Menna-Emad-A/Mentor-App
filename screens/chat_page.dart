import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  ChatPage({required this.otherUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController messageController = TextEditingController();

  String? chatId;

  @override
  void initState() {
    super.initState();
    initChat();
  }

  void initChat() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    var chats = query.docs;
    for (var chat in chats) {
      if ((chat['participants'] as List).contains(widget.otherUserId)) {
        setState(() {
          chatId = chat.id;
        });
        return;
      }
    }

    // If chat doesn't exist, create one
    DocumentReference chatRef =
    await FirebaseFirestore.instance.collection('chats').add({
      'participants': [currentUserId, widget.otherUserId],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      chatId = chatRef.id;
    });
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message and timestamp
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (chatId == null) return CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .collection('messages')
                .orderBy('timestamp')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              final messages = snapshot.data!.docs;

              return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == currentUserId;
                    return ListTile(
                      title: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: isMe ? Colors.blue : Colors.grey[300],
                          child: Text(message['text']),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
        Row(
          children: [
            Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(hintText: 'Type a message'),
                )),
            IconButton(icon: Icon(Icons.send), onPressed: sendMessage)
          ],
        )
      ]),
    );
  }
}
