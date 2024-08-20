import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      bool success = data['success'] ?? false;

      if (success) {
        // 로그인 성공 처리
        print('로그인 성공');

        // 로그인 성공시 로그인 상태 및 ID 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _useridController.text);
        await prefs.setInt('userIdNumeric', data['id']); // userId를 정수형으로 저장

        // 다음 페이지로 네비게이션
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        // 로그인 실패 처리
        print('로그인 실패');
        // 사용자에게 로그인 실패 메시지를 표시하는 코드 추가
      }
    } else {
      // 서버 오류 처리
      print('서버 오류: ${response.statusCode}');
      // 사용자에게 서버 오류 메시지를 표시하는 코드 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: TextField(
                controller: _useridController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
              child: TextField(
                obscureText: true,
                controller: _pwdController,
                decoration: InputDecoration(labelText: 'PWD'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
