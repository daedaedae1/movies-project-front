import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/user.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/main_page.dart';
import 'views/mypage_page.dart';
import 'views/mypageupdate_page.dart';
import 'views/movielist_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserData()),
      ],
      child: MaterialApp(
        title: '영화 웹',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainPage(),
        routes: {
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/mypage': (context) => MyPage(),
          '/mypage/update': (context) => MyPageUpdate(),
          '/movie': (context) => MovieList(),
        },
      ),
    );
  }
}
