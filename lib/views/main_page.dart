import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mypage_page.dart';
import 'movielist_page.dart';
import 'contentbasedrecommend_page.dart';
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
          SliverList(
            delegate: SliverChildListDelegate(
              _isLoggedIn ? _buildLoggedInView() : _buildLoggedOutView(),
            ),
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

  // SliverChildListDelegate는 List<Widget>를 필요로 함.
  // 로그인 됐을 때의 화면
  List<Widget> _buildLoggedInView() {
    return [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieList()),
                );
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
                      ),
                    ),
                  );
                }
              },
              child: Text('콘텐츠 기반 추천'),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(180, 30),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    ];
  }

  // 로그아웃 됐을 때의 화면
  List<Widget> _buildLoggedOutView() {
    return [
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 첫 번째 블럭: 설명 내용 - 이미지
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight, // 우측 정렬
                      child: Padding(
                        padding: EdgeInsets.only(right: 30), // 오른쪽 여백 설정
                        child: Text(
                          '시청 기반의 영화 추천 사이트',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Image.network(
                      'assets/images/ex1.jpeg', // 여기에 이미지 URL을 입력하세요.
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // 두 번째 블럭: 이미지 - 설명 내용
              Row(
                children: <Widget>[
                  Expanded(
                    child: Image.network(
                      'assets/images/ex1.jpeg', // 여기에 이미지 URL을 입력하세요.
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '회원가입 후 로그인하시면, 시청 기록을 관리하고, 개인 맞춤형 영화 추천을 받으실 수 있습니다.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 세 번째 블럭: 가운데 정렬된 이미지와 설명 내용
              Center(
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
                      '지금 바로 가입하고 Orora의 다양한 기능을 만나보세요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ];
  }
}
