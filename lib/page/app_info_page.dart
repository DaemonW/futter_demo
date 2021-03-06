import 'dart:convert';

import 'package:VirtualStore/config/config.dart';
import 'package:VirtualStore/model/key_value.dart';
import 'package:VirtualStore/page/app_upload_page.dart';
import 'package:VirtualStore/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;

class AppInfoPage extends StatefulWidget {
  var _app;
  AppInfoPage(var app) {
    this._app = app;
  }

  @override
  _AppInfoPageState createState() {
    // TODO: implement createState
    return _AppInfoPageState();
  }
}

class _AppInfoPageState extends State<AppInfoPage> {
  var _appInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('详情'),
        ),
        body: getPageContent());
  }

  Widget getPageContent() {
    if (_appInfo == null) {
      return Container(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          constraints: BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Text('App Information hasn\'t been added yet'),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: Container(
              constraints: BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                children: <Widget>[
                  buildHeader(),
                  buildDetails(),
                  buildDescription()
                ],
              )),
        ),
      );
    }
  }

  Widget buildHeader() {
    Widget icon;
    String iconUrl = widget._app['Icon'];
    if (iconUrl.isEmpty) {
      icon = Image.asset('images/icon_default.png', fit: BoxFit.contain);
    } else {
      icon = Image.network(iconUrl, fit: BoxFit.contain);
    }
    return Container(
      constraints: BoxConstraints(maxWidth: 800),
      margin: EdgeInsets.only(top: 30),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            IconButton(
              iconSize: 60,
              icon: icon,
              onPressed: () {},
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('${widget._app['Name']}'),
                Text('${_appInfo['Vendor']}'),
                getCategory(widget._app['Category']),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getCategory(String category) {
    String intuitiveCategory = getintuitiveCategory(category);
    return Text('$intuitiveCategory');
  }

  String getintuitiveCategory(String category) {
    int len = AppUploadPage.Categories.length;
    for (int i = 0; i < len; i++) {
      KeyValueItem item=AppUploadPage.Categories[i];
      if (item.key == category) {
        return item.value;
      }
    }
    return 'Unknown';
  }

  Widget buildDetails() {
    String imageDetail = _appInfo['ImageDetail'];
    List<String> images = imageDetail.split(',');
    return Container(
        margin: EdgeInsets.only(top: 40),
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxWidth: 800),
              margin: EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                '图片详情',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 400,
              child: Swiper(
                itemHeight: 200,
                itemBuilder: (BuildContext context, int index) {
                  return new Image.network(
                    images[index],
                    fit: BoxFit.scaleDown,
                  );
                },
                itemCount: images.length,
                pagination: new SwiperPagination(),
                control: new SwiperControl(),
              ),
            )
          ],
        ));
  }

  Widget buildDescription() {
    return Container(
        constraints: BoxConstraints(maxWidth: 800),
        margin: EdgeInsets.only(top: 40, bottom: 40, left: 20, right: 20),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '关于应用',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '${_appInfo['Description']}',
              overflow: TextOverflow.visible,
            ),
          ],
        ));
  }

  loadInfo() async {
    try {
      String loadRUL = Config.getInstance().endPointAppInfo +
          '/${widget._app['Id']}?uuid=123';
      http.Response response = await http.get(loadRUL);
      var resp = json.decode(response.body);
      if (response.statusCode == 200) {
        var result = resp['result'];
        setState(() {
          _appInfo = result['info'];
        });
      } else {
        var err = resp['err'];
        Toast.toast(context, err['msg']);
      }
    } catch (ex) {
      print("error: " + ex.toString());
    }
  }
}
