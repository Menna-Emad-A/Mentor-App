import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../screens/article_detail.dart';

class ArticleItem extends StatelessWidget {
  final Article article;

  ArticleItem({Key? key, required this.article}) : super(key: key);

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final formatter = DateFormat('yyyy-MM-dd – kk:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Article Image
            if (article.urlToImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.urlToImage,
                placeholder: (context, url) => Container(
                  height: 200.0,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200.0,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Article Description
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Article Date and Author
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        article.author,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
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
