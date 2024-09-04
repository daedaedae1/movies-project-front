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
        // ログイン成功処理
        print('ログイン成功');

        // ログイン成功時、ログイン状態およびIDを保存
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _useridController.text);
        await prefs.setInt('userIdNumeric', data['id']);

        // 次のページへ遷移
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        // ログイン失敗処理
        print('ログイン失敗');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました。'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // サーバーエラー処理
      print('サーバーエラー: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ユーザーIDまたはパスワードが一致しません。'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
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
              onPressed: () async {
                if (_useridController.text.isEmpty || _pwdController.text.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('すべての項目を入力してください。'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                return;
                }
                else {
                  await _login();
                }
              },
              child: Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
