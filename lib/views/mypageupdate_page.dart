import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class MyPageUpdate extends StatefulWidget {
  @override
  _UserInfoEditPageState createState() => _UserInfoEditPageState();
}

class _UserInfoEditPageState extends State<MyPageUpdate> {
  var _userInfo; // 사용자 정보를 저장할 변수
  TextEditingController _useridController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userid = prefs.getString('userid');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/details/$userid');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // 응답 바디를 UTF-8로 디코드
        var userInfo = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _userInfo = userInfo;
          _useridController.text = userInfo['userid'] ?? '';
          _pwdController.text = userInfo['pwd'] ?? '';
          _nameController.text = userInfo['name'] ?? '';
        });
      } else {
        print('서버 오류: ${response.statusCode}');
        // 오류 처리
      }
    }
  }

  Future<void> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/$userid/update');
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
        // 성공적으로 업데이트됨
        print('User updated successfully');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        // 업데이트 실패
        print('Failed to update user: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 정보 수정'),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator()) // 로딩 인디케이터
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
                      decoration: InputDecoration(labelText: '아이디'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: '이름'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      controller: _pwdController,
                      decoration: InputDecoration(labelText: '비밀번호'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center, // 버튼을 가운데 정렬.
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _updateUserInfo();
                      },
                      child: Text('저장'),
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
