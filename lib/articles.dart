import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  

  // Future => 비동기 메소드
  // async => 비동기로 동작
  Future<List<Article>> fetchArticles({int page = 1, String country = 'kr', String category='', String apiKey='44ca18ddbd66467e956be7659c207db6'}) async {
    String url = 'https://newsapi.org/v2/top-headlines?';
    url += 'country=$country';

    // Headlines 이라는 카테고리는 처리하지 않는다(url에 추가시키지 않는다)
    if(category.isNotEmpty && category != 'Headlines') {
      url += '&category=$category';
    }

    // 2페이지 이상인 경우 url에 페이지 값 넣기
    if(page > 1) {
      url += '&page=$page';
    }

    url += '&apiKey=$apiKey';

    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> body = json['articles'];
      List<Article> articles = [];
      for(var item in body) {
        if(await _isUrlValid(item['urlToImage'])) {
          articles.add(Article.fromJson((item)));
        }
      }

      return articles;
    } else {
      return [];
    }
  }

  Future<bool> _isUrlValid(String? urlToImage) async {
    try {
      if (urlToImage == null || urlToImage.isEmpty) {
        return false;
      }

      final response = await http.head(Uri.parse(urlToImage));
      return response.statusCode == 200;

    } catch (e) {
      return false;
    }
  } 
}

class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Article({required this.title, required this.description, required this.urlToImage, required this.url});

  // 이 인스턴스는 앱에서 한 개만 존재해야 함 => 싱글턴 클래스, factory 많이 사용
  // 생성자 보장
  // 순수 데이터만 있는 Article 클래스
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '', 
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '', 
      url: json['url'] ?? ''
    );
  }


}