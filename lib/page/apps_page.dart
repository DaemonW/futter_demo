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
        title: Text("全部应用"),
      ),
      body: Center(
        child: getBody(),
      ),
    );
  }

  loadData() async {
    try {
      String loadRUL = "http://192.168.3.15:8080/api/apps";
      http.Response response = await http.get(loadRUL);
      print(response.body);
      var resp = json.decode(response.body);
      var result = resp['result'];
      setState(() {
        _apps = result['apps'];
      });
    } catch (ex) {
      print("error: " + ex.toString());
    }
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
    String icon = app["Icon"];
    if (icon == null || icon.isEmpty) {
      icon ='http://192.168.3.15:8080/api/resource/app/downloads/icon_default.png';
    }
    double size = app['Size']/1024/1024;
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              icon,
              width: 60.0,
              height: 60.0,
              fit: BoxFit.scaleDown,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0),
            //height: 150.0,
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  app['Name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  maxLines: 1,
                ),
                Text(
                  app['Version']+'    '+size.toStringAsFixed(2)+"MB",
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            )),
          )
        ],
      ),
    );
    return Card(
      child: row,
    );
  }
}
