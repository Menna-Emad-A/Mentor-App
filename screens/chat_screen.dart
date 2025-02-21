import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            final chats = snapshot.data!.docs;

            return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  var chat = chats[index];
                  List<String> participants = List<String>.from(chat['participants']);
                  String otherUserId = participants.firstWhere((id) => id != currentUserId);

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return SizedBox();

                      var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(userData['name']),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    otherUserId: otherUserId,
                                  )));
                        },
                      );
                    },
                  );
                });
          }),
    );
  }
}
