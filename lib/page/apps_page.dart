import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() {
    return _AppPageState();
  }
}

class _AppPageState extends State<AppPage> {
  List _apps = [];

  @override
  void initState() {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("apps"),
      ),
      body: Center(
        child: getBody(),
      ),
    );
  }

  loadData() async {
    print('request data');
    String loadRUL = "http://192.168.21.41:8080/api/apps?uuid=123";
    http.Response response = await http.get(loadRUL);
    print('request data');
    print(response.body);
    var resp = json.decode(response.body);
    var result = resp['apps'];
    setState(() {
      print('request data');
      _apps = result['apps'];
    });
  }

  getBody() {
    if (_apps.length != 0) {
      return ListView.builder(
          itemCount: _apps.length,
          itemBuilder: (BuildContext context, int position) {
            return getItem(_apps[position]);
          });
    } else {
      // 加载菊花
      return CupertinoActivityIndicator();
    }
  }

  getItem(var app) {
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              app['Icon'],
              width: 100.0,
              height: 150.0,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: 8.0),
            height: 150.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                    电影名称
                Text(
                  app['Name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  maxLines: 1,
                ),
//                    豆瓣评分
                Text(
                  app['Version'],
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ))
        ],
      ),
    );
    return Card(
      child: row,
    );
  }
}
