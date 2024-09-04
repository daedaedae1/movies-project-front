import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mypage_page.dart';
import 'movielist_page.dart';
import 'contentbasedrecommend_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSONパース用のインポート

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userId = prefs.getInt('userIdNumeric');

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userId = userId;
    });
  }

  Future<void> logout() async {
    var url = Uri.parse('http://localhost:8080/api/logout'); // サーバーURLを設定
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'}
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // サーバーでログアウトが成功した場合
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userIdNumeric'); // ログアウト時にユーザーIDを削除

      setState(() {
        _isLoggedIn = false;
        _userId = null;
      });

      print(data['success']);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));

    } else {
      // ログアウトリクエストが失敗した場合
      print('로그아웃 실패: ${response.reasonPhrase}');
    }
  }

  void _navigateToSelectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (!_isLoggedIn) {
      if (index == 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else if (index == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      }
    } else {
      if (index == 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else if (index == 1) {
        logout();
      } else if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _navItems = _isLoggedIn
        ? [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'ホーム',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.exit_to_app),
        label: 'ログアウト',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '会員情報',
      ),
    ]
        : [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'ホーム',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.login),
        label: 'ログイン',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.app_registration),
        label: '会員登録',
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent, // トップバーを透明に設定
            elevation: 0, // シャドウを削除
            pinned: true, // スクロール時にトップバーが固定されるように設定
            flexibleSpace: FlexibleSpaceBar(
              title: Center(
                child: Text(
                  'Orora',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
              titlePadding: EdgeInsets.all(0), // タイトルのパディングを設定
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _isLoggedIn ? _buildLoggedInView() : _buildLoggedOutView(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _navigateToSelectedPage,
      ),
    );
  }

// ログイン時の画面
  Widget _buildLoggedInView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Columnが最小サイズだけを占めるように設定
        mainAxisAlignment: MainAxisAlignment.center, // 縦の中央揃え
        crossAxisAlignment: CrossAxisAlignment.center, // 横の中央揃え
        children: <Widget>[
          // 映画リストボタン
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0), // ボタン間に間隔を追加
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieList()),
                );
              },
              icon: Icon(Icons.movie, color: Colors.white),
              label: Text(
                '映画リスト',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // ボタンの背景色
                fixedSize: Size(200, 60), // ボタンのサイズ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // ボタンの角を丸く
                ),
                elevation: 8, // ボタンのシャドウ
              ),
            ),
          ),
          // コンテンツベースの推薦ボタン
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0), // ボタン間に間隔を追加
            child: ElevatedButton.icon(
              onPressed: () {
                if (_userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentBasedRecommendPage(
                        userId: _userId!,
                      ),
                    ),
                  );
                }
              },
              icon: Icon(Icons.star, color: Colors.white),
              label: Text(
                '映画おすすめ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                fixedSize: Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 8,
              ),
            ),
          ),
          // 追加UI要素 - 説明テキスト
          SizedBox(height: 30), // ボタンと説明の間隔
          Text(
            'お気軽に映画リストやおすすめ機能をお試しください！',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  // ログアウト時の画面
  Widget _buildLoggedOutView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 第一ブロック
          Container(
            color: Colors.cyan, // 背景色を設定
            child: Padding(
              padding: const EdgeInsets.all(60.0), // 背景色の内側にパディングを適用
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight, // 右揃え
                      child: Padding(
                        padding: const EdgeInsets.only(right: 100), // テキストの右マージンを設定
                        child: Text(
                          '視聴履歴に基づいた\n映画推薦サイト',
                          style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold), // テキスト設定
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 200), // 画像の右マージンを設定
                      child: Image.network(
                        'assets/images/first.png',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 第二ブロック
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(130.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Image.network(
                        'assets/images/afterLogin.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          '会員登録後にログインすると、\n視聴履歴の管理や\n映画おすすめが受けられます。',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 第三ブロック
          Container(
            color: Colors.cyan[100],
            child: Padding(
              padding: const EdgeInsets.all(130.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      'assets/images/set.png',
                      width: 600,
                      height: 300,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        '今すぐ登録して、\nOroraのおすすめ機能を体験しよう！',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}