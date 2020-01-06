import 'dart:html';
import 'dart:typed_data';

import 'package:VirtualStore/model/key_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:VirtualStore/page/apk_res.dart';
import 'package:VirtualStore/widget/toast.dart';

class AppUploadPage extends StatefulWidget {
  static final List<KeyValueItem> Categories = [
    KeyValueItem('0', '实用工具'),
    KeyValueItem('1', '影音视听'),
    KeyValueItem('2', '聊天社交'),
    KeyValueItem('3', '图书阅读'),
    KeyValueItem('4', '学习教育'),
    KeyValueItem('5', '时尚购物'),
    KeyValueItem('6', '旅行交通'),
    KeyValueItem('7', '摄影摄像'),
    KeyValueItem('8', '新闻资讯'),
    KeyValueItem('9', '居家生活'),
    KeyValueItem('10', '效率办公'),
    KeyValueItem('11', '医疗健康'),
    KeyValueItem('12', '体育运动'),
    KeyValueItem('13', '游戏娱乐'),
  ];

  @override
  _AppUploadState createState() {
    // TODO: implement createState
    return _AppUploadState();
  }
}

class _AppUploadState extends State<AppUploadPage> {
  String _appName = '';
  File _apk;
  File _icon;
  Uint8List _iconData;
  bool _encrypted = false;
  KeyValueItem _category;
  List<String> _countries = [];
  List<String> _languages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar:
        //     AppBar(title: Text('Upload App'), automaticallyImplyLeading: false),
        body: pageContent());
  }

  Widget pageContent() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            color: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 30,
                    alignment: Alignment.center,
                    child: Text('应用名称: '),
                  ),
                  Container(
                    width: 200,
                    height: 30,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        onChanged: (String value) => _appName = value,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(text: _appName)),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 60,
                    alignment: Alignment.center,
                    child: getIcon(),
                  ),
                  Container(
                    width: 200,
                    height: 30,
                    alignment: Alignment.center,
                    child: RaisedButton(
                      child: getApkFileName(),
                      onPressed: () {
                        //selectIcon();
                        selectApk();
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 200,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Text('应用加密'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Checkbox(
                            value: _encrypted,
                            onChanged: (v) {
                              setState(() {
                                _encrypted = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 200,
                      alignment: Alignment.center,
                      child: DropdownButton(
                        value: _category,
                        elevation: 16,
                        hint: Text('应用分类'),
                        //style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          width: 0,
                          height: 0,
                        ),
                        onChanged: (KeyValueItem newValue) {
                          setState(
                            () {
                              _category = newValue;
                            },
                          );
                        },
                        items: AppUploadPage.Categories.map<DropdownMenuItem<KeyValueItem>>(
                            (KeyValueItem item) {
                          return DropdownMenuItem<KeyValueItem>(
                            value: item,
                            child: Text(item.value),
                          );
                        }).toList(),
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 30,
                    alignment: Alignment.center,
                    child: RaisedButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 30,
                    alignment: Alignment.center,
                    child: RaisedButton(
                      child: Text('确定'),
                      onPressed: () {
                        checkSelect();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getApkFileName() {
    if (_apk == null) {
      return Text('选择应用');
    }
    return SizedBox(
      width: 100,
      child: Text(
        _apk.name,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget getIcon() {
    Image icon;
    if (_iconData != null) {
      icon = Image.memory(
        _iconData,
        width: 60,
        height: 60,
        fit: BoxFit.scaleDown,
      );
    } else {
      icon = Image.asset(
        'images/default_pic.png',
        width: 60,
        height: 60,
        fit: BoxFit.scaleDown,
      );
    }
    return IconButton(
      icon: icon,
      iconSize: 60,
      onPressed: () {
        selectIcon();
      },
    );
  }

  selectIcon() {
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = 'image/*';
    input.onChange.listen((e) async {
      var i = e.target as InputElement;
      final List<File> files = i.files;
      if (files == null || files.length == 0) {
        return;
      }
      final reader = new FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onError.listen((error) => print(error.toString()));
      await reader.onLoad.first;
      //completer.complete(input.value);
      setState(() {
        _icon = files[0];
        try {
          _iconData = new Uint8List.fromList(reader.result);
        } catch (ex) {
          print(ex.toString());
        }
      });
    });
    input.click();
    //return completer.future;
  }

  selectApk() {
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = 'application/vnd.android.package-archive/*';
    input.onChange.listen((e) {
      var i = e.target as InputElement;
      if (i.files == null) {
        return;
      }
      var files = i.files;
      if (files.length > 0) {
        var file = files[0];
        // if (!file.name.endsWith('.apk')) {
        //   Toast.toast(context, 'selected file is not an APK.');
        //   return;
        // }
        setState(() {
          //print('select : ${file.name}');
          _apk = file;
        });
      }
    });
    input.click();
    //return completer.future;
  }

  checkSelect() {
    if (_appName == null || _appName.isEmpty) {
      Toast.toast(context, 'empty app name!');
      return;
    }
    if (_apk == null) {
      Toast.toast(context, 'you need to select an apk file!');
      return;
    }
    if (_category == null) {
      Toast.toast(context, 'you need to configure app category!');
      return;
    }
    ApkRes apk = new ApkRes(_apk, _icon, _appName, _encrypted, _category.key);
    Navigator.of(context).pop(apk);
  }
}
