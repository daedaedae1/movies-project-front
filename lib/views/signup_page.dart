import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 요청을 보내기 위한 import 문
import '../model/user.dart';
import 'dart:convert';
import 'main_page.dart';

class SignUpPage extends StatelessWidget {
  final nameController = TextEditingController();
  final useridController = TextEditingController();
  final pwdController = TextEditingController();

  Future<bool> _checkUserIdExists(String userid) async {
    var url = Uri.parse('http://localhost:8080/api/checkUserId/$userid');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'];
      } else {
        print('Failed to check user ID. Status code: ${response.statusCode}');
        return false; // Assume the ID does not exist if the request fails
      }
    } catch (e) {
      print('Error checking user ID: $e');
      return false; // Assume the ID does not exist if there is an exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会員登録')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'NAME'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: TextField(
                controller: useridController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: TextField(
                obscureText: true,
                controller: pwdController,
                decoration: InputDecoration(labelText: 'PWD'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 모든 필드가 입력되었는지 확인
                if (nameController.text.isEmpty ||
                    useridController.text.isEmpty ||
                    pwdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('すべての項目を入力してください。'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 중복 아이디 확인
                final userIdExists = await _checkUserIdExists(useridController.text);
                if (userIdExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('すでに存在するIDです。'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 회원가입 요청
                User user = User(
                  name: nameController.text,
                  userid: useridController.text,
                  pwd: pwdController.text,
                );

                var url = Uri.parse('http://localhost:8080/api/signup');
                try {
                  var response = await http.post(url,
                      headers: {"Content-Type": "application/json"},
                      body: json.encode(user.toJson()));

                  if (response.statusCode == 200) {
                    print('회원가입 성공: ${response.body}');
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainPage()));
                  } else {
                    print('회원가입 실패: ${response.statusCode}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('회원가입 실패: ${response.statusCode}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print('회원가입 중 오류 발생: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('회원가입 중 오류 발생: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('登録'),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(140, 40),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
