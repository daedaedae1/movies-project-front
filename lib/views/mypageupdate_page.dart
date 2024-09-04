import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'mypage_page.dart';

class MyPageUpdate extends StatefulWidget {
  @override
  _UserInfoEditPageState createState() => _UserInfoEditPageState();
}

class _UserInfoEditPageState extends State<MyPageUpdate> {
  var _userInfo;
  TextEditingController _useridController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/details/$userid');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var userInfo = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _userInfo = userInfo;
          _useridController.text = userInfo['userid'] ?? '';
          _pwdController.text = userInfo['pwd'] ?? '';
          _nameController.text = userInfo['name'] ?? '';
        });
      } else {
        print('サーバーエラー: ${response.statusCode}');
      }
    }
  }

  Future<void> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/details/$userid/update');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'userid': userid,
          'pwd': _pwdController.text,
          'name': _nameController.text,
        }),
      );

      if (response.statusCode == 200) {
        print('アップデート成功');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        print('アップデート失敗: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アカウント設定'),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator()) // ローディングインジケーター, 円形の回転アニメーション
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 10.0),
                    child: TextField(
                      enabled: false,
                      controller: _useridController,
                      decoration: InputDecoration(labelText: 'ID'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'NAME'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      controller: _pwdController,
                      decoration: InputDecoration(labelText: 'PWD'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center, // ボタンを中央揃え
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _updateUserInfo();
                      },
                      child: Text('保存'),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(115, 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
