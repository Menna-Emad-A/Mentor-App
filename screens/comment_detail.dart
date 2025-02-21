// lib/screens/comment_detail.dart
import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentDetail extends StatelessWidget {
  final Comment comment;

  CommentDetail({Key? key, required this.comment}) : super(key: key);

  Color _getColor() {
    return Colors.primaries[comment.id % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    Color color = _getColor();
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Details'),
        backgroundColor: color,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${comment.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Name:', style: TextStyle(fontSize: 18)),
            Text(comment.name, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Email:', style: TextStyle(fontSize: 18)),
            Text(comment.email, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Body:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  comment.body,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
