import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  File? _profileImage;
  String? _profileImageUrl;

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void editProfile(BuildContext context) {
    // Implement profile editing functionality
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      await _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$userId.jpg');

    UploadTask uploadTask = storageRef.putFile(_profileImage!);

    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    String downloadUrl = await snapshot.ref.getDownloadURL();
    _profileImageUrl = downloadUrl;

    // Update the user's profile picture URL in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'profilePicture': _profileImageUrl});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
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
          return Center(child: Text('User data not found.'));
        }

        // Safely get the data
        var data = snapshot.data!.data();

        // Check if data is null
        if (data == null) {
          return Center(child: Text('User data is empty.'));
        }

        // Now you can safely cast data to Map<String, dynamic>
        Map<String, dynamic> userData = data as Map<String, dynamic>;

        // Use the data as needed
        String profilePictureUrl = userData['profilePicture'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            actions: [
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => editProfile(context)),
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => logout(context)),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (profilePictureUrl != ''
                        ? NetworkImage(profilePictureUrl)
                        : null),
                    child: (_profileImage == null && profilePictureUrl == '')
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userData['name'] ?? 'No Name',
                  style: TextStyle(fontSize: 24),
                ),
                ListTile(
                  title: Text('Description'),
                  subtitle: Text(userData['description'] ?? 'No Description'),
                ),
                ListTile(
                  title: Text('Field'),
                  subtitle: Text(userData['field'] ?? 'No Field'),
                ),
                if (userData['userType'] == 'Mentor')
                  ListTile(
                    title: Text('Experience'),
                    subtitle: Text(userData['experience'] ?? 'N/A'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}
