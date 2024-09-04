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
  var _userInfo; // ユーザー情報を保存する変数
  TextEditingController _useridController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  int _selectedIndex = 2; // MyPageはナビゲーションバーの3番目の項目なので、基本インデックスは2

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

  Future<void> deleteUserAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');
    if (userid != null) {
      var url = Uri.parse('http://localhost:8080/api/details/$userid/delete');
      var response = await http.delete(url);
      if (response.statusCode == 200) {
        print('会員退会成功: ${response.body}');
        await prefs.clear();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        print('サーバーエラー: ${response.statusCode}');
      }
    }
  }

  void _navigateToSelectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    } else if (index == 1) {
      logout();
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyPage()));
    }
  }

  Future<void> logout() async {
    var url = Uri.parse('http://localhost:8080/api/logout');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userIdNumeric');

      setState(() {
        _userInfo = null;
      });

      print(data['success']);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    } else {
      print('ログアウト失敗: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _navItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'ホーム',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.exit_to_app),
        label: 'ログアウト',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '会員情報',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('会員情報'),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            userInfoTile('ID', _useridController.text),
            userInfoTile('NAME', _nameController.text),
            userInfoTile('PWD', _obscuredPassword(_pwdController.text)),
            SizedBox(height: 20),
            Divider(),
            updateButton(context, '情報修正', MyPageUpdate()),
            deleteUserButton(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _navigateToSelectedPage,
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

  String _obscuredPassword(String password) {
    return '*' * password.length;
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
          elevation: 1,
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
          child: Text('退会'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Colors.deepPurple; // ボタンが押されたときの色
                  return Colors.red; // 基本色
                }),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Colors.yellow; // ボタンが押されたときのテキスト色
                  return Colors.white; // 基本テキスト色
                }),
          ),
        ),
      ),
    );
  }
}
