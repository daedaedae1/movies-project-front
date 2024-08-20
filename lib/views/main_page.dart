import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mypage_page.dart';
import 'movielist_page.dart';
import 'contentbasedrecommend_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위한 import

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
    var url = Uri.parse('http://localhost:8080/api/logout'); // 서버 URL을 설정하세요.
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'}
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // 서버에서 로그아웃이 성공적으로 처리되었을 경우
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userIdNumeric'); // 로그아웃 시 사용자 ID 제거

      setState(() {
        _isLoggedIn = false;
        _userId = null;
      });

      print(data['success']);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));

    } else {
      // 로그아웃 요청이 실패했을 경우
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
            backgroundColor: Colors.transparent, // 상단바를 투명하게 설정
            elevation: 0, // 그림자 제거
            pinned: true, // 스크롤 시 상단바가 고정되도록 설정
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
              titlePadding: EdgeInsets.all(0), // Title padding 설정
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

  // 로그인 됐을 때의 화면
  Widget _buildLoggedInView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Column이 최소 크기만큼만 차지하도록 설정
        mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MovieList()),
              );
            },
            child: Text('映画リスト'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(130, 30),
            ),
          ),
          SizedBox(height: 20), // 버튼 사이의 간격
          ElevatedButton(
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
            child: Text('映画おすすめ'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(180, 30),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃 됐을 때의 화면
  Widget _buildLoggedOutView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 첫 번째 블럭: 설명 내용 - 이미지
          Container(
            color: Colors.cyan, // 첫 번째 블럭의 배경색 설정
            child: Padding(
              padding: const EdgeInsets.all(60.0), // 배경색 안쪽에 패딩 적용
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight, // 우측 정렬
                      child: Padding(
                        padding: const EdgeInsets.only(right: 100), // 텍스트의 오른쪽 여백 설정
                        child: Text(
                          '視聴履歴に基づいた\n映画推薦サイト',
                          style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold), // 텍스트 설정
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 200), // 이미지 오른쪽 여백 설정
                      child: Image.network(
                        'assets/images/first.png', // 여기에 이미지 URL을 입력하세요.
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 두 번째 블럭: 이미지 - 설명 내용
          Container(
            color: Colors.white, // 두 번째 블럭의 배경색 설정
            child: Padding(
              padding: const EdgeInsets.all(60.0), // 배경색 안쪽에 패딩 적용
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100), // 이미지 오른쪽 여백 설정
                      child: Image.network(
                        'assets/images/ex1.jpeg', // 여기에 이미지 URL을 입력하세요.
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '회원가입 후 로그인하시면, 시청 기록을 관리하고,\n개인 맞춤형 영화 추천을 받으실 수 있습니다.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 세 번째 블럭: 가운데 정렬된 이미지와 설명 내용
          Container(
            color: Colors.cyan[100], // 세 번째 블럭의 배경색 설정
            child: Padding(
              padding: const EdgeInsets.all(60.0), // 배경색 안쪽에 패딩 적용
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center, // 세로 가운데 정렬
                  children: <Widget>[
                    Image.network(
                      'assets/images/ex1.jpeg', // 여기에 이미지 URL을 입력하세요.
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '지금 바로 가입하고 Orora의 추천 기능을 만나보세요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}