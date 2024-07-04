import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/article_card.dart';
import 'articles.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData (
        primarySwatch: Colors.blue
      ),
      home: const NewsPage(),
    ); 
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  
  @override
  State<StatefulWidget> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {

  late Future<List<Article>> futureArticles;  // 임시 리스트
  final List<Article> _articles = [];  // 최종 리스트
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  String _country = 'kr';
  String _category = '';
  bool _isLoadingMore = false;

  // 카테고리 리스트 
  final List<Map<String, String>> categories = [
    {'title': 'Headlines'},
    {'title': 'Business'},
    {'title': 'Technology'},
    {'title': 'Science'},
    {'title': 'Sports'},
    {'title': 'Entertainment'},
    {'title': 'Health'},
  ];

  @override
  void initState() {
    // 데이터 로딩 처리..
    super.initState();
    futureArticles = NewsService().fetchArticles();  // 비동기로 받는 중
    futureArticles.then((articles) {  // 비동기로 받은 데이터가 전부 들어오면 함수 실행
      print(articles);
      setState(() => _articles.addAll(articles));  // 빈 _articles 리스트에 articles 전부 아이템 추가)
    });

    _scrollController.addListener(_scrollListener);
  } 

  void _onCategoryTap({String category=''}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles = NewsService().fetchArticles(category: category, country: _country);
      futureArticles.then((articles) {
        setState(() => _articles.addAll(articles));  // 카테고리에 대한 기사 로드를 다 했을 때
        _category = category;  // 대입한 카테고리를 전역변수에 대입해 고정
      });
    });
  }

  void _onCountryTap({String country=''}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles = NewsService().fetchArticles(country: country, category: _category);
      futureArticles.then((articles) {
        setState(() => _articles.addAll(articles));  // 카테고리에 대한 기사 로드를 다 했을 때
        _country = country;  // 대입한 나라를 전역변수에 대입해 고정
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  // build는 추상 클래스
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('News', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/images/news.png'),
                  fit: BoxFit.cover
                ),
              ),
              child: Column(children: [
                Padding(padding: EdgeInsets.only(top: 80)),
                Text('News Category', style: TextStyle(color: Colors.white, fontSize: 24),)
              ],)
            ),
            // 리스트 안에 리스트 넣기
            ...categories.map((category) => ListTile( 
              title: Text(category['title']!),
              onTap: () {
                _onCategoryTap(category: category['title']!);
                Navigator.pop(context);
              }
            )),
          ],
        ),
      ),
      body: FutureBuilder<List<Article>> (   // Center => layout 클래스
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data'),);
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _articles.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final article = _articles[index];
                return ArticleCard(article: article, key: ValueKey(article.title));
              },
            );
          }
        }
      ),
      // 네비게이션 바 꾸미기
      bottomNavigationBar: BottomNavigationBar(items: [
        // 아이템 꾸미기
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/kr.png', width: 24, height: 24,), label: 'Country'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: ((value) => _onNavItemTap(value, context)),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200 && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true; 
      });
      _loadMoreArticles();
      // 스크롤 했을 때 기사를 추가하는 함수 실행
    }
  }
  
  Future<void> _loadMoreArticles() async {
    _currentPage++;
    List<Article> articles = await NewsService().fetchArticles(page: _currentPage);
    setState(() {
      _articles.addAll(articles);
      _isLoadingMore = false;
    });
  }

  void _showModalBottomSheet(BuildContext context) {
    List<Map<String, String>> items = [
      {'title': 'Korea', 'images': 'assets/images/kr.png', 'code': 'kr'},
      {'title': 'United States', 'images': 'assets/images/us.png', 'code': 'us'},
      {'title': 'Japan', 'images': 'assets/images/jp.png', 'code': 'jp'},
    ];

    // 빈 캔버스(윈도우)
    showModalBottomSheet(context: context,
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        color: Colors.blue,
        child: GridView.count(  // GridView => 행렬 형태로 보임
          crossAxisCount: 3,  // 가로 줄 아이템 몇개
          crossAxisSpacing: 4.0,  // 가로 아이템 사이의 간격
          mainAxisSpacing: 4.0,  // 세로 아이템 사이의 간격
          children: [
            // ...List.generate(),
            Container(
              color: Colors.white,
              child: GestureDetector(
                // 눌렀을 때 처리하는 일들
                onTap: () {
                  Navigator.pop(context);
                  _onCountryTap(country: 'us');
                },
                child: Center(child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/us.png', width: 50, height: 50, fit: BoxFit.cover,),
                      Text('USA'),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: GestureDetector(
                // 눌렀을 때 처리하는 일들
                onTap: () {
                  Navigator.pop(context);
                  _onCountryTap(country: 'jp');
                },
                child: Center(child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/jp.png', width: 50, height: 50, fit: BoxFit.cover,),
                      Text('Japan'),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: GestureDetector(
                // 눌렀을 때 처리하는 일들
                onTap: () {
                  Navigator.pop(context);
                  _onCountryTap(country: 'kr');
                },
                child: Center(child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/kr.png', width: 50, height: 50, fit: BoxFit.cover,),
                      Text('Korea'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      );
    });
  }

  _onNavItemTap(int value, BuildContext context) {  // value => 네비게이션 바에서 액션하는 변수(뭐가 눌렸나, 각 아이템의 인덱스 값)
    print('Selected Index: $value');

    switch(value) {
      case 0:
        _showModalBottomSheet(context);
        break;
      case 1:
        break;
      case 2:
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
    }
    
  }
}
