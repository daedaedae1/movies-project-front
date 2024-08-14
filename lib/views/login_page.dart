import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; //로그인 상태저장 import 문

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _useridController = TextEditingController();
  final _pwdController = TextEditingController();

  Future<void> _login() async {
    var url = Uri.parse('http://localhost:8080/api/login');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userid': _useridController.text,
        'pwd': _pwdController.text,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // null 검사를 추가하여 'success' 키가 없거나 null일 경우 기본값으로 false를 사용.
      bool success = data['success'] != null;

      if (success) {
        // 로그인 성공 처리
        print('로그인 성공');

        //로그인 성공시 로그인 상태 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        prefs.setString('userid', _useridController.text);

        // 다음 페이지로 네비게이션
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        // 로그인 실패 처리
        print('로그인 실패');
        // 여기서 사용자에게 로그인 실패 메시지를 표시.
      }
    } else {
      // 서버 오류 처리
      print('서버 오류: ${response.statusCode}');
      // 여기서 사용자에게 서버 오류 메시지를 표시.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 10.0),
              child: TextField(
                controller: _useridController,
                decoration: InputDecoration(labelText: '아이디'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 5.0),
              child: TextField(
                obscureText: true,
                controller: _pwdController,
                decoration: InputDecoration(labelText: '비밀번호'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
