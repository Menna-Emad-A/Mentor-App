import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'mentor_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final tabs = [
    MentorListScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class MentorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar can be added here if needed
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userType', isEqualTo: 'Mentor')
            .snapshots(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          // Show a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No mentors found.'));
          }

          final mentors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              var mentor = mentors[index];

              // Get mentor data safely
              var data = mentor.data();

              if (data == null) {
                return SizedBox(); // Skip if data is null
              }

              Map<String, dynamic> mentorData = data as Map<String, dynamic>;

              String profilePictureUrl = mentorData['profilePicture'] ?? '';

              return Card(
                color: Color(mentorData['borderColor'] ?? Colors.blue.value),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profilePictureUrl != ''
                        ? NetworkImage(profilePictureUrl)
                        : null,
                    child: profilePictureUrl == ''
                        ? Text(
                      mentorData['name'] != null
                          ? mentorData['name'][0]
                          : '',
                    )
                        : null,
                  ),
                  title: Text(mentorData['name'] ?? 'No Name'),
                  subtitle: Text(mentorData['field'] ?? 'No Field'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MentorDetailScreen(mentorId: mentor.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
