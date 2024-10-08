import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト送信用のインポート文
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
        print('${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('$e');
      return false;
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
                // すべてのフィールドが入力されているか確認
                if (nameController.text.isEmpty ||
                    useridController.text.isEmpty ||
                    pwdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('すべての項目を入力してください。'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // 重複したIDが存在するか確認
                final userIdExists = await _checkUserIdExists(useridController.text);
                if (userIdExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('すでに存在するIDです。'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // 会員登録リクエスト
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
                    print('会員登録成功: ${response.body}');
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainPage()));
                  } else {
                    print('会員登録失敗: ${response.statusCode}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('会員登録に失敗しました。'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('会員登録中にエラーが発生しました。: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('会員登録中にエラーが発生しました。'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
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
