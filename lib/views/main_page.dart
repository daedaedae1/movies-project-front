import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mypage_page.dart';
import 'movielist_page.dart';
import 'contentbasedrecommend_page.dart';
import 'collaborativerecommend_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId'); // 로그아웃 시 사용자 ID 제거

    setState(() {
      _isLoggedIn = false;
      _userId = null;
    });
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainPage()));
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
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.exit_to_app),
        label: '로그아웃',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '마이페이지',
      ),
    ]
        : [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.login),
        label: '로그인',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.app_registration),
        label: '회원가입',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Orora'),
      ),
      body: _isLoggedIn ? _buildLoggedInView() : _buildLoggedOutView(),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _navigateToSelectedPage,
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MovieList()));
            },
            child: Text('영화 리스트'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(130, 30),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_userId != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContentBasedRecommendPage(
                          userId: _userId!,
                        )));
              }
            },
            child: Text('콘텐츠 기반 추천'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(180, 30),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CollaborativeRecommendPage()));
            },
            child: Text('협업 필터링 추천'),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(180, 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Orora에 오신 것을 환영합니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Orora는 영화를 더 쉽게 찾고 관리할 수 있는 플랫폼입니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '회원가입 후 로그인하시면, 시청 기록을 관리하고, 개인 맞춤형 영화 추천을 받으실 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '지금 바로 가입하고 Orora의 다양한 기능을 만나보세요!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
