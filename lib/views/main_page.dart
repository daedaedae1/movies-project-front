import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mypage_page.dart';
import 'movielist_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false; // 로그인 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  // 로그아웃 메소드
  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    setState(() {
      _isLoggedIn = false;
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
        // 로그아웃 메소드 호출
        logout();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyPage()));
      }
    }
  }

  void _printMessage() {
    print("isLoggedIn: $_isLoggedIn");
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
      body: _isLoggedIn
          ? _buildLoggedInView() // 로그인 상태일 때의 화면
          : _buildLoggedOutView(), // 로그아웃 상태일 때의 화면
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _navigateToSelectedPage,
      ),
    );
  }

  // 로그인 상태일 때의 화면
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
              _printMessage();
            },
            child: Text('클릭하세요'),
          ),
        ],
      ),
    );
  }

  // 로그아웃 상태일 때의 화면
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
            SizedBox(height: 16),
            Image.asset(
              'assets/intro_image.jpg', // 앱의 이미지 에셋을 활용하세요
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              'Orora는 영화를 더 쉽게 찾고 관리할 수 있는 플랫폼입니다. 다양한 영화 정보를 검색하고, 맞춤형 추천을 받아보세요.',
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
