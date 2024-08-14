import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 요청을 보내기 위한 import 문
import '../model/user.dart';
import 'dart:convert';
import 'main_page.dart';

class SignUpPage extends StatelessWidget {
  // TextEditingController 인스턴스 생성
  final nameController = TextEditingController();
  final useridController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: useridController,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 사용자 입력을 이용해 SignUpModel 객체 생성
                User user = User(
                  name: nameController.text,
                  userid: useridController.text,
                  pwd: passwordController.text,
                );

                var url = Uri.parse('http://localhost:8080/api/signup');
                var response = await http.post(url,
                    headers: {"Content-Type": "application/json"},
                    body: json
                        .encode(user.toJson())); // toJson() 메서드를 이용해 JSON으로 변환

                if (response.statusCode == 200) {
                  print('회원가입 성공: ${response.body}');
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
                } else {
                  print('회원가입 실패: ${response.statusCode}');
                }
              },
              child: Text('회원가입'),
            )
          ],
        ),
      ),
    );
  }
}
