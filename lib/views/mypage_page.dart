import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_page.dart';
import 'mypageupdate_page.dart';

class MyPage extends StatefulWidget {
  @override
  _UserInfoEditPageState createState() => _UserInfoEditPageState();
}

class _UserInfoEditPageState extends State<MyPage> {
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
        print('서버 오류: ${response.statusCode}');
      }
    }
  }

  Future<void> deleteUserAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userid = prefs.getString('userid');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/$userid/delete');
      var response = await http.delete(url);
      if (response.statusCode == 200) {
        print('회원탈퇴 성공: ${response.body}');
        await prefs.clear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인페이지'),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            userInfoTile('ID', _useridController.text),
            userInfoTile('이름', _nameController.text),
            userInfoTile('PWD', _pwdController.text),
            SizedBox(height: 20),
            Divider(),
            updateButton(context, '회원 수정', MyPageUpdate()),
            deleteUserButton(),
          ],
        ),
      ),
    );
  }

  Widget userInfoTile(String label, String value) {
    return ListTile(
      title: Text(
        "$label: $value",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget updateButton(BuildContext context, String label, Widget page) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Text(label),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(115, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 1, // 버튼의 그림자
        ),
      ),
    );
  }

  Widget deleteUserButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            deleteUserAccount();
          },
          child: Text('회원 탈퇴'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Colors.deepPurple; // 버튼이 눌렸을 때의 색상
              return Colors.red; // 기본 색상
            }),
            foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Colors.yellow; // 버튼이 눌렸을 때의 텍스트 색상
              return Colors.white; // 기본 텍스트 색상
            }),
          ),
        )

      ),
    );
  }
}
