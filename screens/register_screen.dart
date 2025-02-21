import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

enum UserType { Mentor, Mentee }

class _RegisterScreenState extends State<RegisterScreen> {
  UserType _userType = UserType.Mentee;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Common fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  // Mentor-specific fields
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController fieldController = TextEditingController();
  Color borderColor = Colors.blue;

  // Image Picker
  File? _profileImage;
  String? _profileImageUrl;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _uploadProfilePicture(String userId) async {
    if (_profileImage == null) return;

    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      UploadTask uploadTask = storageRef.putFile(_profileImage!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await snapshot.ref.getDownloadURL();
      _profileImageUrl = downloadUrl;
    } catch (e) {
      print('Profile picture upload failed: $e');
      // You might want to handle the error or set _profileImageUrl to a default value
      _profileImageUrl = '';
    }
  }

  void register() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      await _uploadProfilePicture(userCredential.user!.uid);

      Map<String, dynamic> userData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'userType': _userType == UserType.Mentor ? 'Mentor' : 'Mentee',
        'profilePicture': _profileImageUrl ?? '',
      };

      if (_userType == UserType.Mentor) {
        userData.addAll({
          'experience': experienceController.text,
          'field': fieldController.text,
          'borderColor': borderColor.value,
        });
      } else {
        userData.addAll({
          'field': fieldController.text,
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Navigate to home screen after registration
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);
      // Handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMentor = _userType == UserType.Mentor;

    return Scaffold(
        appBar: AppBar(
          title: Text('Mentorship Finder - Register'),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(children: [
                  ListTile(
                    title: Text('Mentor'),
                    leading: Radio(
                      value: UserType.Mentor,
                      groupValue: _userType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Mentee'),
                    leading: Radio(
                      value: UserType.Mentee,
                      groupValue: _userType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: fieldController,
                    decoration: InputDecoration(
                        labelText: isMentor ? 'Major Expertise/Field' : 'Major/Field'),
                  ),
                  if (isMentor)
                    TextField(
                      controller: experienceController,
                      decoration: InputDecoration(labelText: 'Experience'),
                    ),
                  if (isMentor)
                    Row(
                      children: [
                        Text('Choose Border Color:'),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            // Implement color picker here
                            // For simplicity, we'll just toggle between two colors
                            setState(() {
                              borderColor = borderColor == Colors.blue
                                  ? Colors.green
                                  : Colors.blue;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: borderColor,
                          ),
                        )
                      ],
                    ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(onPressed: register, child: Text('Register')),
                ]))));
  }
}
