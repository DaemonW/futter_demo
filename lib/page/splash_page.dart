import 'package:flutter/material.dart';
import 'package:flutter_app/page/login_page.dart';
import 'package:flutter_app/page/apps_page.dart';
import 'dart:html';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() {
    // TODO: implement createState
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  bool _isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_isLogin) {
      return AppPage();
    } else {
      return LoginPage();
    }
    ;
  }

  checkLoginStatus() {
    getToken().then((String t) {
      if (t != null && t.isNotEmpty) {
        setState(() {
          _isLogin = true;
        });
      } else {
        setState(() {
          _isLogin = false;
        });
      }
    });
  }

  Future<String> getToken() async {
    print("get token");
    Storage storage = window.localStorage;
    return storage['token'];
  }
}
