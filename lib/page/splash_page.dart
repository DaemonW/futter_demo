import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:VirtualStore/page/login_page.dart';
import 'package:VirtualStore/page/apps_page.dart';
import 'dart:html';

import '../config/config.dart';
import '../util/http_util.dart';
import '../widget/toast.dart';

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
  }

  checkLoginStatus() {
    getToken().then((bool success) {
      if (success) {
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

  Future<bool> getToken() async {
    Storage storage = window.localStorage;
    String token = storage['token'];
    if (token == null || token.isEmpty) {
      return false;
    }
    var userInfo = parseToken(token);
    if (userInfo == null) {
      return false;
    }
    var id = userInfo['jti'];
    var headers = Map<String, String>();
    headers['Authorization'] = token;
    try {
      var resp = await HttpUtil.request(
          Config.getInstance().endPointUserInfo + '/$id',
          requestHeaders: headers);
      if (resp.status == 401) {
        Toast.toast(context, '登录失效');
        storage.remove('token');
      }
      if (resp.status == 200) {
        return true;
      }
    } catch (e) {
      print('error: ' + e.toString());
    }
    return false;
  }

  dynamic parseToken(String t) {
    var fields = t.split('.');
    if (fields.length != 3) {
      return null;
    }
    var body = base64.normalize(fields[1]);
    try {
      var bodyStr = utf8.decode(base64Decode(body));
      return jsonDecode(bodyStr);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
