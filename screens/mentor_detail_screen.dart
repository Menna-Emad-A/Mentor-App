import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class MentorDetailScreen extends StatelessWidget {
  final String mentorId;

  MentorDetailScreen({required this.mentorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(mentorId).get(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          // Show a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Check if the document exists
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Mentor data not found.'));
          }

          // Safely get the data
          var data = snapshot.data!.data();

          // Check if data is null
          if (data == null) {
            return Center(child: Text('Mentor data is empty.'));
          }

          // Now you can safely cast data to Map<String, dynamic>
          Map<String, dynamic> mentorData = data as Map<String, dynamic>;

          // Use the data as needed
          String profilePictureUrl = mentorData['profilePicture'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePictureUrl != ''
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: profilePictureUrl == ''
                      ? Text(
                    mentorData['name'] != null
                        ? mentorData['name'][0]
                        : '',
                    style: TextStyle(fontSize: 40),
                  )
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  mentorData['name'] ?? 'No Name',
                  style: TextStyle(fontSize: 24),
                ),
                ListTile(
                  title: Text('Experience'),
                  subtitle: Text(mentorData['experience'] ?? 'N/A'),
                ),
                ListTile(
                  title: Text('Field'),
                  subtitle: Text(mentorData['field'] ?? 'No Field'),
                ),
                ListTile(
                  title: Text('Description'),
                  subtitle: Text(mentorData['description'] ?? 'No Description'),
                ),
                ElevatedButton(
                    onPressed: () {
                      // Navigate to chat page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                otherUserId: mentorId,
                              )));
                    },
                    child: Text('Contact')),
                // Mentor Reviews Section
                MentorReviewsSection(mentorId: mentorId),
              ],
            ),
          );
        },
      ),
    );
  }

}


class MentorReviewsSection extends StatefulWidget {
  final String mentorId;

  MentorReviewsSection({required this.mentorId});

  @override
  _MentorReviewsSectionState createState() => _MentorReviewsSectionState();
}

class _MentorReviewsSectionState extends State<MentorReviewsSection> {
  final TextEditingController reviewController = TextEditingController();

  void submitReview() async {
    if (reviewController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.mentorId)
        .collection('reviews')
        .add({
      'review': reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    reviewController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mentor Reviews', style: TextStyle(fontSize: 20)),
        TextField(
          controller: reviewController,
          decoration: InputDecoration(
              labelText: 'Write a review', suffixIcon: IconButton(
            icon: Icon(Icons.send),
            onPressed: submitReview,
          )),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.mentorId)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            final reviews = snapshot.data!.docs;

            return ListView.builder(
                shrinkWrap: true,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  var review = reviews[index];
                  return ListTile(
                    title: Text(review['review']),
                  );
                });
          },
        ),
      ],
    );
  }
}
