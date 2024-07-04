import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'articles.dart';

class ArticleCard extends StatelessWidget {
  
  late final Article article;

  ArticleCard({super.key, required this.article});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launcUrl(article.url),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (article.urlToImage.isNotEmpty) ?
            Image.network(article.urlToImage,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover) :
            Image.asset('assets/images/news.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(article.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(article.description,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
            ),
            Text(article.title),
            Text(article.description),
          ],
        )
      )
    );
    
  }

  _launcUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if(await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('??');
    }
  }
  
}