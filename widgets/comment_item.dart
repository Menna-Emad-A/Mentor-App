// lib/widgets/comment_item.dart

import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../screens/comment_detail.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  CommentItem({Key? key, required this.comment}) : super(key: key);

  // Function to generate a color based on the comment ID
  Color _getColor() {
    return Colors.primaries[comment.id % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentDetail(comment: comment),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            // Circle with the ID
            CircleAvatar(
              backgroundColor: _getColor(),
              child: Text(
                '${comment.id}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 16.0),
            // Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    comment.email,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
