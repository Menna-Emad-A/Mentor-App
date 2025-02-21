// lib/screens/comments_list.dart

import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/comment_item.dart';

class CommentsList extends StatelessWidget {
  final Future<List<Comment>> comments;

  CommentsList({Key? key})
      : comments = ApiService.fetchComments(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: FutureBuilder<List<Comment>>(
        future: comments,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Comment> comments = snapshot.data!;
            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentItem(comment: comments[index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          // By default, show a loading spinner
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
