import 'package:flutter/material.dart';
import 'package:flutter_app/page/splash_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      home:SplashPage()
    );
  }
}
